//
//  FakeCuttlefish.swift
//  Security
//
//  Created by Ben Williamson on 5/23/18.
//

import CloudKitCode
import CloudKitCodeProtobuf
import Foundation

enum FakeCuttlefishOpinion {
    case trusts
    case trustsByPreapproval
    case excludes
}

struct FakeCuttlefishAssertion: CustomStringConvertible {
    let peer: String
    let opinion: FakeCuttlefishOpinion
    let target: String

    func check(peer: Peer?, target: Peer?) -> Bool {
        guard let peer = peer else {
            return false
        }

        guard peer.hasDynamicInfoAndSig else {
            // No opinions? You've failed this assertion.
            return false
        }

        let dynamicInfo = TPPeerDynamicInfo(data: peer.dynamicInfoAndSig.peerDynamicInfo, sig: peer.dynamicInfoAndSig.sig)
        guard let realDynamicInfo = dynamicInfo else {
            return false
        }

        let targetPermanentInfo: TPPeerPermanentInfo? =
            target != nil ? TPPeerPermanentInfo(peerID: self.target,
                                                data: target!.permanentInfoAndSig.peerPermanentInfo,
                                                sig: target!.permanentInfoAndSig.sig,
                                                keyFactory: TPECPublicKeyFactory())
                : nil

        switch self.opinion {
        case .trusts:
            return realDynamicInfo.includedPeerIDs.contains(self.target)
        case .trustsByPreapproval:
            guard let pubSignSPKI = targetPermanentInfo?.signingPubKey.spki() else {
                return false
            }
            let hash = TPHashBuilder.hash(with: .SHA256, of: pubSignSPKI)
            return realDynamicInfo.preapprovals.contains(hash)
        case .excludes:
            return realDynamicInfo.excludedPeerIDs.contains(self.target)
        }
    }

    var description: String {
        return "DCA:(\(self.peer)\(self.opinion)\(self.target))"
    }
}

@objc
class FakeCuttlefishNotify: NSObject {
    let pushes: (Data) -> Void
    let containerName: String

    @objc
    init(_ containerName: String, pushes: @escaping (Data) -> Void) {
        self.containerName = containerName
        self.pushes = pushes
    }

    @objc
    func notify(_ function: String) throws {
        let notification: [String: [String: Any]] = [
            "aps": ["content-available": 1],
            "cf": [
                "f": function,
                "c": self.containerName,
            ],
            ]
        let payload: Data
        do {
            payload = try JSONSerialization.data(withJSONObject: notification)
        } catch {
            throw error
        }
        self.pushes(payload)
    }
}

extension ViewKey {
    func fakeRecord(zoneID: CKRecordZone.ID) -> CKRecord {
        let recordID = CKRecord.ID(__recordName: self.uuid, zoneID: zoneID)
        let record = CKRecord(recordType: SecCKRecordIntermediateKeyType, recordID: recordID)

        record[SecCKRecordWrappedKeyKey] = self.wrappedkeyBase64

        switch self.keyclass {
        case .tlk:
            record[SecCKRecordKeyClassKey] = "tlk"
        case .classA:
            record[SecCKRecordKeyClassKey] = "classA"
        case .classC:
            record[SecCKRecordKeyClassKey] = "classC"
        case .UNRECOGNIZED:
            abort()
        }

        if !self.parentkeyUuid.isEmpty {
            // TODO: no idea how to tell it about the 'verify' action
            record[SecCKRecordParentKeyRefKey] = CKRecord.Reference(recordID: CKRecord.ID(__recordName: self.parentkeyUuid, zoneID: zoneID), action: .none)
        }

        return record
    }

    func fakeKeyPointer(zoneID: CKRecordZone.ID) -> CKRecord {
        let recordName: String
        switch self.keyclass {
        case .tlk:
            recordName = "tlk"
        case .classA:
            recordName = "classA"
        case .classC:
            recordName = "classC"
        case .UNRECOGNIZED:
            abort()
        }

        let recordID = CKRecord.ID(__recordName: recordName, zoneID: zoneID)
        let record = CKRecord(recordType: SecCKRecordCurrentKeyType, recordID: recordID)

        // TODO: no idea how to tell it about the 'verify' action
        record[SecCKRecordParentKeyRefKey] = CKRecord.Reference(recordID: CKRecord.ID(__recordName: self.uuid, zoneID: zoneID), action: .none)

        return record
    }
}

extension TLKShare {
    func fakeRecord(zoneID: CKRecordZone.ID) -> CKRecord {
        let recordID = CKRecord.ID(__recordName: "tlkshare-\(self.keyUuid)::\(self.receiver)::\(self.sender)", zoneID: zoneID)
        let record = CKRecord(recordType: SecCKRecordTLKShareType, recordID: recordID)

        record[SecCKRecordSenderPeerID] = self.sender
        record[SecCKRecordReceiverPeerID] = self.receiver
        record[SecCKRecordReceiverPublicEncryptionKey] = self.receiverPublicEncryptionKey
        record[SecCKRecordCurve] = self.curve
        record[SecCKRecordVersion] = self.version
        record[SecCKRecordEpoch] = self.epoch
        record[SecCKRecordPoisoned] = self.poisoned

        // TODO: no idea how to tell it about the 'verify' action
        record[SecCKRecordParentKeyRefKey] = CKRecord.Reference(recordID: CKRecord.ID(__recordName: self.keyUuid, zoneID: zoneID), action: .none)

        record[SecCKRecordWrappedKeyKey] = self.wrappedkey
        record[SecCKRecordSignature] = self.signature

        return record
    }
}

class FakeCuttlefishServer: CuttlefishAPIAsync {
    
    struct State {
        var peersByID: [String: Peer] = [:]
        var recoverySigningPubKey: Data?
        var recoveryEncryptionPubKey: Data?
        var bottles: [Bottle] = []
        var escrowRecords: [EscrowInformation] = []

        var viewKeys: [CKRecordZone.ID: ViewKeys] = [:]
        var tlkShares: [CKRecordZone.ID: [TLKShare]] = [:]

        init() {
        }

        func model(updating newPeer: Peer?) throws -> TPModel {
            let model = TPModel(decrypter: Decrypter())

            for existingPeer in self.peersByID.values {
                if let pi = existingPeer.permanentInfoAndSig.toPermanentInfo(peerID: existingPeer.peerID),
                   let si = existingPeer.stableInfoAndSig.toStableInfo(),
                   let di = existingPeer.dynamicInfoAndSig.toDynamicInfo() {
                    model.registerPeer(with: pi)
                    try model.update(si, forPeerWithID: existingPeer.peerID)
                    try model.update(di, forPeerWithID: existingPeer.peerID)
                }
            }

            if let peerUpdate = newPeer {
                // This peer needs to have been in the model before; on pain of throwing here
                if let si = peerUpdate.stableInfoAndSig.toStableInfo(),
                   let di = peerUpdate.dynamicInfoAndSig.toDynamicInfo() {
                    try model.update(si, forPeerWithID: peerUpdate.peerID)
                    try model.update(di, forPeerWithID: peerUpdate.peerID)
                }
            }

            return model
        }
    }

    var state = State()
    var snapshotsByChangeToken: [String: State] = [:]
    var currentChange: Int = 0
    var currentChangeToken: String = ""
    let notify: FakeCuttlefishNotify?

    //var fakeCKZones: [CKRecordZone.ID: FakeCKZone]
    var fakeCKZones: NSMutableDictionary

    // @property (nullable) NSMutableDictionary<CKRecordZoneID*, ZoneKeys*>* keys;
    var ckksZoneKeys: NSMutableDictionary

    var injectLegacyEscrowRecords: Bool = false
    var includeEscrowRecords: Bool = true

    var nextFetchErrors: [Error] = []
    var fetchViableBottlesError: [Error] = []
    var nextJoinErrors: [Error] = []
    var nextUpdateTrustErrors: [Error] = []
    var returnNoActionResponse: Bool = false
    var returnRepairAccountResponse: Bool = false
    var returnRepairEscrowResponse: Bool = false
    var returnResetOctagonResponse: Bool = false
    var returnLeaveTrustResponse: Bool = false
    var returnRepairErrorResponse: Error?
    var fetchChangesCalledCount: Int = 0
    var fetchChangesReturnEmptyResponse: Bool = false
        
    var fetchViableBottlesEscrowRecordCacheTimeout: TimeInterval = 2.0

    var nextEstablishReturnsMoreChanges: Bool = false

    var establishListener: ((EstablishRequest) -> NSError?)?
    var updateListener: ((UpdateTrustRequest) -> NSError?)?
    var fetchChangesListener: ((FetchChangesRequest) -> NSError?)?
    var joinListener: ((JoinWithVoucherRequest) -> NSError?)?
    var healthListener: ((GetRepairActionRequest) -> NSError?)?
    var fetchViableBottlesListener: ((FetchViableBottlesRequest) -> NSError?)?
    var resetListener: ((ResetRequest) -> NSError?)?
    var setRecoveryKeyListener: ((SetRecoveryKeyRequest) -> NSError?)?

    // Any policies in here will be returned by FetchPolicy before any inbuilt policies
    var policyOverlay: [TPPolicyDocument] = []

    var fetchViableBottlesDontReturnBottleWithID: String?

    init(_ notify: FakeCuttlefishNotify?, ckZones: NSMutableDictionary, ckksZoneKeys: NSMutableDictionary) {
        self.notify = notify
        self.fakeCKZones = ckZones
        self.ckksZoneKeys = ckksZoneKeys
    }

    func deleteAllPeers() {
        self.state.peersByID.removeAll()
        self.makeSnapshot()
    }

    func pushNotify(_ function: String) {
        if let notify = self.notify {
            do {
                try notify.notify(function)
            } catch {
            }
        }
    }

    static func makeCloudKitCuttlefishError(code: CuttlefishErrorCode, retryAfter: TimeInterval = 5) -> NSError {
        let cuttlefishError = CKPrettyError(domain: CuttlefishErrorDomain,
                                            code: code.rawValue,
                                            userInfo: [CuttlefishErrorRetryAfterKey: retryAfter])
        let internalError = CKPrettyError(domain: CKInternalErrorDomain,
                                          code: CKInternalErrorCode.errorInternalPluginError.rawValue,
                                          userInfo: [NSUnderlyingErrorKey: cuttlefishError, ])
        let ckError = CKPrettyError(domain: CKErrorDomain,
                                    code: CKError.serverRejectedRequest.rawValue,
                                    userInfo: [NSUnderlyingErrorKey: internalError,
                                               CKErrorServerDescriptionKey: "Fake: FunctionError domain: CuttlefishError, code: \(code),\(code.rawValue)",
                                               ])
        return ckError
    }

    func makeSnapshot() {
        self.currentChange += 1
        self.currentChangeToken = "change\(self.currentChange)"
        self.snapshotsByChangeToken[self.currentChangeToken] = self.state
    }

    func changesSince(snapshot: State) -> Changes {
        return Changes.with { changes in
            changes.changeToken = self.currentChangeToken

            changes.differences = self.state.peersByID.compactMap { (key: String, value: Peer) -> PeerDifference? in
                let old = snapshot.peersByID[key]
                if old == nil {
                    return PeerDifference.with {
                        $0.add = value
                    }
                } else if old != value {
                    return PeerDifference.with {
                        $0.update = value
                    }
                } else {
                    return nil
                }
            }
            snapshot.peersByID.forEach { (key: String, _: Peer) in
                if self.state.peersByID[key] == nil {
                    changes.differences.append(PeerDifference.with {
                        $0.remove = Peer.with {
                            $0.peerID = key
                        }
                    })
                }
            }

            if self.state.recoverySigningPubKey != snapshot.recoverySigningPubKey {
                changes.recoverySigningPubKey = self.state.recoverySigningPubKey ?? Data()
            }
            if self.state.recoveryEncryptionPubKey != snapshot.recoveryEncryptionPubKey {
                changes.recoveryEncryptionPubKey = self.state.recoveryEncryptionPubKey ?? Data()
            }
        }
    }

    func reset(_ request: ResetRequest, completion: @escaping (ResetResponse?, Error?) -> Void) {
        print("FakeCuttlefish: reset called")
        if let resetListener = self.resetListener {
            let possibleError = resetListener(request)
            guard possibleError == nil else {
                completion(nil, possibleError)
                return
            }
        }
        self.state = State()
        self.makeSnapshot()
        completion(ResetResponse.with {
            $0.changes = self.changesSince(snapshot: State())
        }, nil)
        self.pushNotify("reset")
    }

    func newKeysConflict(viewKeys: [ViewKeys]) -> Bool {
        #if OCTAGON_TEST_FILL_ZONEKEYS
        for keys in viewKeys {
            let rzid = CKRecordZone.ID(zoneName: keys.view)

            if let currentViewKeys = self.ckksZoneKeys[rzid] as? CKKSCurrentKeySet {
                // Uploading the current view keys is okay. Fail only if they don't match
                if keys.newTlk.uuid != currentViewKeys.tlk!.uuid ||
                    keys.newClassA.uuid != currentViewKeys.classA!.uuid ||
                    keys.newClassC.uuid != currentViewKeys.classC!.uuid {
                    return true
                }
            }
        }
        #endif

        return false
    }

    func store(viewKeys: [ViewKeys]) -> [CKRecord] {
        var allRecords: [CKRecord] = []

        viewKeys.forEach { viewKeys in
            let rzid = CKRecordZone.ID(zoneName: viewKeys.view)
            self.state.viewKeys[rzid] = viewKeys

            // Real cuttlefish makes these zones for you
            if self.fakeCKZones[rzid] == nil {
                self.fakeCKZones[rzid] = FakeCKZone(zone: rzid)
            }

            if let fakeZone = self.fakeCKZones[rzid] as? FakeCKZone {
                fakeZone.queue.sync {
                    let tlkRecord = viewKeys.newTlk.fakeRecord(zoneID: rzid)
                    let classARecord = viewKeys.newClassA.fakeRecord(zoneID: rzid)
                    let classCRecord = viewKeys.newClassC.fakeRecord(zoneID: rzid)

                    let tlkPointerRecord = viewKeys.newTlk.fakeKeyPointer(zoneID: rzid)
                    let classAPointerRecord = viewKeys.newClassA.fakeKeyPointer(zoneID: rzid)
                    let classCPointerRecord = viewKeys.newClassC.fakeKeyPointer(zoneID: rzid)

                    // Some tests don't link everything needed to make zonekeys
                    // Those tests don't get this nice behavior
                    #if OCTAGON_TEST_FILL_ZONEKEYS
                    let zoneKeys = self.ckksZoneKeys[rzid] as? ZoneKeys ?? ZoneKeys(forZoneName: rzid.zoneName)
                    self.ckksZoneKeys[rzid] = zoneKeys

                    zoneKeys.tlk = CKKSKey(ckRecord: tlkRecord)
                    zoneKeys.classA = CKKSKey(ckRecord: classARecord)
                    zoneKeys.classC = CKKSKey(ckRecord: classCRecord)

                    zoneKeys.currentTLKPointer = CKKSCurrentKeyPointer(ckRecord: tlkPointerRecord)
                    zoneKeys.currentClassAPointer = CKKSCurrentKeyPointer(ckRecord: classAPointerRecord)
                    zoneKeys.currentClassCPointer = CKKSCurrentKeyPointer(ckRecord: classCPointerRecord)
                    #endif

                    let zoneRecords = [tlkRecord,
                                       classARecord,
                                       classCRecord,
                                       tlkPointerRecord,
                                       classAPointerRecord,
                                       classCPointerRecord, ]
                    // TODO a rolled tlk too

                    zoneRecords.forEach { record in
                        fakeZone._onqueueAdd(toZone: record)
                    }
                    allRecords.append(contentsOf: zoneRecords)
                }
            } else {
                // we made the zone above, shoudn't ever get here
                print("Received an unexpected zone id: \(rzid)")
                abort()
            }
        }
        return allRecords
    }

    func store(tlkShares: [TLKShare]) -> [CKRecord] {
        var allRecords: [CKRecord] = []

        tlkShares.forEach { share in
            let rzid = CKRecordZone.ID(zoneName: share.view)

            var c = self.state.tlkShares[rzid] ?? []
            c.append(share)
            self.state.tlkShares[rzid] = c

            if let fakeZone = self.fakeCKZones[rzid] as? FakeCKZone {
                let record = share.fakeRecord(zoneID: rzid)
                fakeZone.add(toZone: record)
                allRecords.append(record)
            } else {
                print("Received an unexpected zone id: \(rzid)")
            }
        }

        return allRecords
    }

    func establish(_ request: EstablishRequest, completion: @escaping (EstablishResponse?, Error?) -> Void) {
        print("FakeCuttlefish: establish called")
        if !self.state.peersByID.isEmpty {
            completion(nil, FakeCuttlefishServer.makeCloudKitCuttlefishError(code: .establishFailed))
        }

        // Before performing write, check if we should error
        if let establishListener = self.establishListener {
            let possibleError = establishListener(request)
            guard possibleError == nil else {
                completion(nil, possibleError)
                return
            }
        }

        // Also check if we should bail due to conflicting viewKeys
        if self.newKeysConflict(viewKeys: request.viewKeys) {
            completion(nil, FakeCuttlefishServer.makeCloudKitCuttlefishError(code: .keyHierarchyAlreadyExists))
            return
        }

        self.state.peersByID[request.peer.peerID] = request.peer
        self.state.bottles.append(request.bottle)
        let escrowInformation = EscrowInformation.with {
            $0.label = "com.apple.icdp.record." + request.bottle.bottleID
            $0.creationDate = Google_Protobuf_Timestamp(date: Date())
            $0.remainingAttempts = 10
            $0.silentAttemptAllowed = 1
            $0.recordStatus = .valid
            let e = EscrowInformation.Metadata.with {
                $0.backupKeybagDigest = Data()
                $0.secureBackupUsesMultipleIcscs = 1
                $0.secureBackupTimestamp = Google_Protobuf_Timestamp(date: Date())
                $0.peerInfo = Data()
                $0.bottleID = request.bottle.bottleID
                $0.escrowedSpki = request.bottle.escrowedSigningSpki
                let cm = EscrowInformation.Metadata.ClientMetadata.with {
                    $0.deviceColor = "#202020"
                    $0.deviceEnclosureColor = "#020202"
                    $0.deviceModel = "model"
                    $0.deviceModelClass = "modelClass"
                    $0.deviceModelVersion = "modelVersion"
                    $0.deviceMid = "mid"
                    $0.deviceName = "my device"
                    $0.devicePlatform = 1
                    $0.secureBackupNumericPassphraseLength = 6
                    $0.secureBackupMetadataTimestamp = Google_Protobuf_Timestamp(date: Date())
                    $0.secureBackupUsesNumericPassphrase = 1
                    $0.secureBackupUsesComplexPassphrase = 1
                }
                $0.clientMetadata = cm
            }
            $0.escrowInformationMetadata = e
        }
        self.state.escrowRecords.append(escrowInformation)

        var keyRecords: [CKRecord] = []
        keyRecords.append(contentsOf: store(viewKeys: request.viewKeys))
        keyRecords.append(contentsOf: store(tlkShares: request.tlkShares))

        self.makeSnapshot()

        let response = EstablishResponse.with {
            if self.nextEstablishReturnsMoreChanges {
                $0.changes = Changes.with {
                    $0.more = true
                }
                self.nextEstablishReturnsMoreChanges = false
            } else {
                $0.changes = self.changesSince(snapshot: State())
            }
            $0.zoneKeyHierarchyRecords = keyRecords.map { try! CloudKitCode.Ckcode_RecordTransport($0) }
        }

        completion(response, nil)
        self.pushNotify("establish")
    }

    func joinWithVoucher(_ request: JoinWithVoucherRequest, completion: @escaping (JoinWithVoucherResponse?, Error?) -> Void) {
        print("FakeCuttlefish: joinWithVoucher called")

        if let joinListener = self.joinListener {
            let possibleError = joinListener(request)
            guard possibleError == nil else {
                completion(nil, possibleError)
                return
            }
        }

        if let injectedError = self.nextJoinErrors.first {
            print("FakeCuttlefish: erroring with injected error: ", String(describing: injectedError))
            self.nextJoinErrors.removeFirst()
            completion(nil, injectedError)
            return
        }

        // Also check if we should bail due to conflicting viewKeys
        if self.newKeysConflict(viewKeys: request.viewKeys) {
            completion(nil, FakeCuttlefishServer.makeCloudKitCuttlefishError(code: .keyHierarchyAlreadyExists))
            return
        }

        guard let snapshot = self.snapshotsByChangeToken[request.changeToken] else {
            completion(nil, FakeCuttlefishServer.makeCloudKitCuttlefishError(code: .changeTokenExpired))
            return
        }
        self.state.peersByID[request.peer.peerID] = request.peer
        self.state.bottles.append(request.bottle)
        let escrowInformation = EscrowInformation.with {
            $0.label = "com.apple.icdp.record." + request.bottle.bottleID
            $0.creationDate = Google_Protobuf_Timestamp(date: Date())
            $0.remainingAttempts = 10
            $0.silentAttemptAllowed = 1
            $0.recordStatus = .valid
            let e = EscrowInformation.Metadata.with {
                $0.backupKeybagDigest = Data()
                $0.secureBackupUsesMultipleIcscs = 1
                $0.secureBackupTimestamp = Google_Protobuf_Timestamp(date: Date())
                $0.peerInfo = Data()
                $0.bottleID = request.bottle.bottleID
                $0.escrowedSpki = request.bottle.escrowedSigningSpki
                let cm = EscrowInformation.Metadata.ClientMetadata.with {
                    $0.deviceColor = "#202020"
                    $0.deviceEnclosureColor = "#020202"
                    $0.deviceModel = "model"
                    $0.deviceModelClass = "modelClass"
                    $0.deviceModelVersion = "modelVersion"
                    $0.deviceMid = "mid"
                    $0.deviceName = "my device"
                    $0.devicePlatform = 1
                    $0.secureBackupNumericPassphraseLength = 6
                    $0.secureBackupMetadataTimestamp = Google_Protobuf_Timestamp(date: Date())
                    $0.secureBackupUsesNumericPassphrase = 1
                    $0.secureBackupUsesComplexPassphrase = 1
                }
                $0.clientMetadata = cm
            }
            $0.escrowInformationMetadata = e
        }
        self.state.escrowRecords.append(escrowInformation)
        var keyRecords: [CKRecord] = []
        keyRecords.append(contentsOf: store(viewKeys: request.viewKeys))
        keyRecords.append(contentsOf: store(tlkShares: request.tlkShares))

        self.makeSnapshot()

        completion(JoinWithVoucherResponse.with {
            $0.changes = self.changesSince(snapshot: snapshot)
            $0.zoneKeyHierarchyRecords = keyRecords.map { try! CloudKitCode.Ckcode_RecordTransport($0) }
        }, nil)
        self.pushNotify("joinWithVoucher")
    }

    func updateTrust(_ request: UpdateTrustRequest, completion: @escaping (UpdateTrustResponse?, Error?) -> Void) {
        print("FakeCuttlefish: updateTrust called: changeToken: ", request.changeToken, "peerID: ", request.peerID)

        if let injectedError = self.nextUpdateTrustErrors.first {
            print("FakeCuttlefish: updateTrust erroring with injected error: ", String(describing: injectedError))
            self.nextUpdateTrustErrors.removeFirst()
            completion(nil, injectedError)
            return
        }

        guard let snapshot = self.snapshotsByChangeToken[request.changeToken] else {
            completion(nil, FakeCuttlefishServer.makeCloudKitCuttlefishError(code: .changeTokenExpired))
            return
        }
        guard let existingPeer = self.state.peersByID[request.peerID] else {
            completion(nil, FakeCuttlefishServer.makeCloudKitCuttlefishError(code: .updateTrustPeerNotFound))
            return
        }

        // copy Peer so that we can update it safely
        var peer = try! Peer(serializedData: try! existingPeer.serializedData())

        // Before performing write, check if we should error
        if let updateListener = self.updateListener {
            let possibleError = updateListener(request)
            guard possibleError == nil else {
                completion(nil, possibleError)
                return
            }
        }

        if request.hasStableInfoAndSig {
            peer.stableInfoAndSig = request.stableInfoAndSig
        }
        if request.hasDynamicInfoAndSig {
            peer.dynamicInfoAndSig = request.dynamicInfoAndSig
        }

        // Will Cuttlefish reject this due to peer graph issues?
        do {
            let model = try self.state.model(updating: peer)

            // Is there any non-excluded peer that trusts itself?
            let nonExcludedPeerIDs = model.allPeerIDs().filter { !model.statusOfPeer(withID: $0).contains(.excluded) }
            let selfTrustedPeerIDs = nonExcludedPeerIDs.filter { model.statusOfPeer(withID: $0).contains(.selfTrust) }

            guard selfTrustedPeerIDs.count > 0 else {
                completion(nil, FakeCuttlefishServer.makeCloudKitCuttlefishError(code: .resultGraphHasNoPotentiallyTrustedPeers))
                return
            }
        } catch {
            print("FakeCuttlefish: updateTrust failed to make model: ", String(describing: error))
        }

        // Cuttlefish has accepted the write.
        self.state.peersByID[request.peerID] = peer

        // Also check if we should bail due to conflicting viewKeys
        if self.newKeysConflict(viewKeys: request.viewKeys) {
            completion(nil, FakeCuttlefishServer.makeCloudKitCuttlefishError(code: .keyHierarchyAlreadyExists))
            return
        }

        var keyRecords: [CKRecord] = []
        keyRecords.append(contentsOf: store(viewKeys: request.viewKeys))
        keyRecords.append(contentsOf: store(tlkShares: request.tlkShares))

        let newDynamicInfo = TPPeerDynamicInfo(data: peer.dynamicInfoAndSig.peerDynamicInfo,
                                               sig: peer.dynamicInfoAndSig.sig)
        print("FakeCuttlefish: new peer dynamicInfo: ", request.peerID, String(describing: newDynamicInfo?.dictionaryRepresentation()))

        self.makeSnapshot()
        let response = UpdateTrustResponse.with {
            $0.changes = self.changesSince(snapshot: snapshot)
            $0.zoneKeyHierarchyRecords = keyRecords.map { try! CloudKitCode.Ckcode_RecordTransport($0) }
        }

        completion(response, nil)
        self.pushNotify("updateTrust")
    }

    func setRecoveryKey(_ request: SetRecoveryKeyRequest, completion: @escaping (SetRecoveryKeyResponse?, Error?) -> Void) {
        print("FakeCuttlefish: setRecoveryKey called")

        if let listener = self.setRecoveryKeyListener {
            let operationError = listener(request)
            guard operationError == nil else {
                completion(nil, operationError)
                return
            }
        }

        guard let snapshot = self.snapshotsByChangeToken[request.changeToken] else {
            completion(nil, FakeCuttlefishServer.makeCloudKitCuttlefishError(code: .changeTokenExpired))
            return
        }
        self.state.recoverySigningPubKey = request.recoverySigningPubKey
        self.state.recoveryEncryptionPubKey = request.recoveryEncryptionPubKey
        self.state.peersByID[request.peerID]?.stableInfoAndSig = request.stableInfoAndSig

        var keyRecords: [CKRecord] = []
        //keyRecords.append(contentsOf: store(viewKeys: request.viewKeys))
        keyRecords.append(contentsOf: store(tlkShares: request.tlkShares))

        self.makeSnapshot()
        completion(SetRecoveryKeyResponse.with {
            $0.changes = self.changesSince(snapshot: snapshot)
            $0.zoneKeyHierarchyRecords = keyRecords.map { try! CloudKitCode.Ckcode_RecordTransport($0) }
        }, nil)
        self.pushNotify("setRecoveryKey")
    }

    func fetchChanges(_ request: FetchChangesRequest, completion: @escaping (FetchChangesResponse?, Error?) -> Void) {
        print("FakeCuttlefish: fetchChanges called: ", request.changeToken)

        self.fetchChangesCalledCount += 1

        if let fetchChangesListener = self.fetchChangesListener {
            let possibleError = fetchChangesListener(request)
            guard possibleError == nil else {
                completion(nil, possibleError)
                return
            }
            if fetchChangesReturnEmptyResponse == true {
                completion(FetchChangesResponse(), nil)
                return
            }
        }

        if let injectedError = self.nextFetchErrors.first {
            print("FakeCuttlefish: fetchChanges erroring with injected error: ", String(describing: injectedError))
            self.nextFetchErrors.removeFirst()
            completion(nil, injectedError)
            return
        }

        let snapshot: State
        if request.changeToken.isEmpty {
            snapshot = State()
        } else {
            guard let s = self.snapshotsByChangeToken[request.changeToken] else {
                completion(nil, FakeCuttlefishServer.makeCloudKitCuttlefishError(code: .changeTokenExpired))
                return
            }
            snapshot = s
        }
        let response = FetchChangesResponse.with {
            $0.changes = self.changesSince(snapshot: snapshot)
        }

        completion(response, nil)
    }

    func fetchViableBottles(_ request: FetchViableBottlesRequest, completion: @escaping (FetchViableBottlesResponse?, Error?) -> Void) {
        print("FakeCuttlefish: fetchViableBottles called")
        
        if let fetchViableBottlesListener = self.fetchViableBottlesListener {
            let possibleError = fetchViableBottlesListener(request)
            guard possibleError == nil else {
                completion(nil, possibleError)
                return
            }
        }

        if let injectedError = self.fetchViableBottlesError.first {
            print("FakeCuttlefish: fetchViableBottles erroring with injected error: ", String(describing: injectedError))
            self.fetchViableBottlesError.removeFirst()
            completion(nil, injectedError)
            return
        }

        var legacy: [EscrowInformation] = []
        if self.injectLegacyEscrowRecords {
            print("FakeCuttlefish: fetchViableBottles injecting legacy records")
            let record = EscrowInformation.with {
                $0.label = "fake-label"
            }
            legacy.append(record)
        }
        let bottles = self.state.bottles.filter { $0.bottleID != fetchViableBottlesDontReturnBottleWithID }

        completion(FetchViableBottlesResponse.with {
            $0.viableBottles = bottles.compactMap { bottle in
                EscrowPair.with {
                    $0.escrowRecordID = bottle.bottleID
                    $0.bottle = bottle
                    if self.includeEscrowRecords {
                        $0.record = self.state.escrowRecords.first { $0.escrowInformationMetadata.bottleID == bottle.bottleID } ?? EscrowInformation()
                    }
                }
            }
            if self.injectLegacyEscrowRecords {
                $0.legacyRecords = legacy
            }
        }, nil)
    }

    func fetchPolicyDocuments(_ request: FetchPolicyDocumentsRequest,
                              completion: @escaping (FetchPolicyDocumentsResponse?, Error?) -> Void) {
        print("FakeCuttlefish: fetchPolicyDocuments called")
        var response = FetchPolicyDocumentsResponse()

        let policies = builtInPolicyDocuments()
        let dummyPolicies = Dictionary(uniqueKeysWithValues: policies.map { ($0.version.versionNumber, ($0.version.policyHash, $0.protobuf)) })
        let overlayPolicies = Dictionary(uniqueKeysWithValues: self.policyOverlay.map { ($0.version.versionNumber, ($0.version.policyHash, $0.protobuf)) })

        for key in request.keys {
            if let (hash, data) = overlayPolicies[key.version], hash == key.hash {
                response.entries.append(PolicyDocumentMapEntry.with { $0.key = key; $0.value = data })
                continue
            }

            guard let (hash, data) = dummyPolicies[key.version] else {
                continue
            }
            if hash == key.hash {
                response.entries.append(PolicyDocumentMapEntry.with { $0.key = key; $0.value = data })
            }
        }
        completion(response, nil)
    }

    func assertCuttlefishState(_ assertion: FakeCuttlefishAssertion) -> Bool {
        return assertion.check(peer: self.state.peersByID[assertion.peer], target: self.state.peersByID[assertion.target])
    }

    func validatePeers(_: ValidatePeersRequest, completion: @escaping (ValidatePeersResponse?, Error?) -> Void) {
        var response = ValidatePeersResponse()
        response.validatorsHealth = 0.0
        response.results = []
        completion(response, nil)
    }
    func reportHealth(_: ReportHealthRequest, completion: @escaping (ReportHealthResponse?, Error?) -> Void) {
        completion(ReportHealthResponse(), nil)
    }
    func pushHealthInquiry(_: PushHealthInquiryRequest, completion: @escaping (PushHealthInquiryResponse?, Error?) -> Void) {
        completion(PushHealthInquiryResponse(), nil)
    }

    func getRepairAction(_ request: GetRepairActionRequest, completion: @escaping (GetRepairActionResponse?, Error?) -> Void) {
        print("FakeCuttlefish: getRepairAction called")

        if let healthListener = self.healthListener {
            let possibleError = healthListener(request)
            guard possibleError == nil else {
                completion(nil, possibleError)
                return
            }
        }

        if self.returnRepairEscrowResponse {
            let response = GetRepairActionResponse.with {
                $0.repairAction = .postRepairEscrow
            }
            completion(response, nil)
        } else if self.returnRepairAccountResponse {
            let response = GetRepairActionResponse.with {
                $0.repairAction = .postRepairAccount
            }
            completion(response, nil)
        } else if self.returnResetOctagonResponse {
            let response = GetRepairActionResponse.with {
                $0.repairAction = .resetOctagon
            }
            completion(response, nil)
        } else if returnLeaveTrustResponse {
            let response = GetRepairActionResponse.with {
                $0.repairAction = .leaveTrust
            }
            completion(response, nil)
        } else if self.returnNoActionResponse {
            let response = GetRepairActionResponse.with {
                $0.repairAction = .noAction
            }
            completion(response, nil)
        } else if self.returnRepairErrorResponse != nil {
            let response = GetRepairActionResponse.with {
                $0.repairAction = .noAction
            }
            completion(response, self.returnRepairErrorResponse)
        } else {
            completion(GetRepairActionResponse(), nil)
        }
    }

    func getClubCertificates(_: GetClubCertificatesRequest, completion: @escaping (GetClubCertificatesResponse?, Error?) -> Void) {
        completion(GetClubCertificatesResponse(), nil)
    }

    func getSupportAppInfo(_: GetSupportAppInfoRequest, completion: @escaping (GetSupportAppInfoResponse?, Error?) -> Void) {
        completion(GetSupportAppInfoResponse(), nil)
    }

    func fetchSosiCloudIdentity(_: FetchSOSiCloudIdentityRequest, completion: @escaping (FetchSOSiCloudIdentityResponse?, Error?) -> Void) {
        completion(FetchSOSiCloudIdentityResponse(), nil)
    }
    func addCustodianRecoveryKey(_: AddCustodianRecoveryKeyRequest, completion: @escaping (AddCustodianRecoveryKeyResponse?, Error?) -> Void) {
        completion(AddCustodianRecoveryKeyResponse(), nil)
    }
    func resetAccountCdpcontents(_: ResetAccountCDPContentsRequest, completion: @escaping (ResetAccountCDPContentsResponse?, Error?) -> Void) {
        completion(ResetAccountCDPContentsResponse(), nil)
    }
}

extension FakeCuttlefishServer: CloudKitCode.Invocable {
    func invoke<RequestType, ResponseType>(function: String,
                                           request: RequestType,
                                           completion: @escaping (ResponseType?, Error?) -> Void) {
        // Ideally we'd pattern match on both request and completion, but that crashes the swift compiler at this time (<rdar://problem/54412402>)
        switch request {
        case let request as ResetRequest:
            self.reset(request, completion: completion as! (ResetResponse?, Error?) -> Void)
            return
        case let request as EstablishRequest:
            self.establish(request, completion: completion as! (EstablishResponse?, Error?) -> Void)
            return
        case let request as JoinWithVoucherRequest:
            self.joinWithVoucher(request, completion: completion as! (JoinWithVoucherResponse?, Error?) -> Void)
            return
        case let request as UpdateTrustRequest:
            self.updateTrust(request, completion: completion as! (UpdateTrustResponse?, Error?) -> Void)
            return
        case let request as SetRecoveryKeyRequest:
            self.setRecoveryKey(request, completion: completion as! (SetRecoveryKeyResponse?, Error?) -> Void)
            return
        case let request as FetchChangesRequest:
            self.fetchChanges(request, completion: completion as! (FetchChangesResponse?, Error?) -> Void)
            return
        case let request as FetchViableBottlesRequest:
            self.fetchViableBottles(request, completion: completion as! (FetchViableBottlesResponse?, Error?) -> Void)
            return
        case let request as FetchPolicyDocumentsRequest:
            self.fetchPolicyDocuments(request, completion: completion as! (FetchPolicyDocumentsResponse?, Error?) -> Void)
            return
        case let request as ValidatePeersRequest:
            self.validatePeers(request, completion: completion as! (ValidatePeersResponse?, Error?) -> Void)
            return
        case let request as ReportHealthRequest:
            self.reportHealth(request, completion: completion as! (ReportHealthResponse?, Error?) -> Void)
            return
        case let request as PushHealthInquiryRequest:
            self.pushHealthInquiry(request, completion: completion as! (PushHealthInquiryResponse?, Error?) -> Void)
            return
        case let request as GetRepairActionRequest:
            self.getRepairAction(request, completion: completion as! (GetRepairActionResponse?, Error?) -> Void)
            return
        default:
            abort()
        }
    }
}
