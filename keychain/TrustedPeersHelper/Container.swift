/*
 * Copyright (c) 2018 Apple Inc. All Rights Reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */

import CloudKitCode
import CoreData
import Foundation
import os
import Security
import SecurityFoundation

let tplogDebug = OSLog(subsystem: "com.apple.security.trustedpeers", category: "debug")
let tplogTrace = OSLog(subsystem: "com.apple.security.trustedpeers", category: "trace")

let egoIdentitiesAccessGroup = "com.apple.security.egoIdentities"

extension ResetReason {
    static func from(cuttlefishResetReason: CuttlefishResetReason) -> ResetReason {
        switch cuttlefishResetReason {
        case .unknown:
            return ResetReason.unknown
        case .userInitiatedReset:
            return  ResetReason.userInitiatedReset
        case .healthCheck:
            return ResetReason.healthCheck
        case .noBottleDuringEscrowRecovery:
            return ResetReason.noBottleDuringEscrowRecovery
        case .legacyJoinCircle:
            return ResetReason.legacyJoinCircle
        case .recoveryKey:
            return ResetReason.recoveryKey
        case .testGenerated:
            return ResetReason.testGenerated
        @unknown default:
            fatalError()
        }
    }
}

public enum ContainerError: Error {
    case unableToCreateKeyPair
    case noPreparedIdentity
    case failedToStoreIdentity
    case needsAuthentication
    case missingStableInfo
    case missingDynamicInfo
    case nonMember
    case invalidPermanentInfoOrSig
    case invalidStableInfoOrSig
    case invalidVoucherOrSig
    case sponsorNotRegistered(String)
    case unknownPolicyVersion(UInt64)
    case preparedIdentityNotOnAllowedList(String)
    case couldNotLoadAllowedList
    case noPeersPreapprovePreparedIdentity
    case policyDocumentDoesNotValidate
    case tooManyBottlesForPeer
    case noBottleForPeer
    case restoreBottleFailed
    case noBottlesForEscrowRecordID
    case bottleDoesNotContainContents
    case bottleDoesNotContainEscrowKeySignature
    case bottleDoesNotContainerPeerKeySignature
    case bottleDoesNotContainPeerID
    case failedToCreateBottledPeer
    case signatureVerificationFailed
    case bottleDoesNotContainerEscrowKeySPKI
    case failedToFetchEscrowContents
    case failedToCreateRecoveryKey
    case untrustedRecoveryKeys
    case noBottlesPresent
    case recoveryKeysNotEnrolled
    case bottleCreatingPeerNotFound
    case unknownCloudKitError
    case cloudkitResponseMissing
    case failedToLoadSecret(errorCode: Int)
    case failedToLoadSecretDueToType
    case failedToAssembleBottle
    case invalidPeerID
    case failedToStoreSecret(errorCode: Int)
    case unknownSecurityFoundationError
    case failedToSerializeData
}

extension ContainerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unableToCreateKeyPair:
            return "unable to create key pair"
        case .noPreparedIdentity:
            return "no prepared identity"
        case .failedToStoreIdentity:
            return "failed to stored identity"
        case .needsAuthentication:
            return "needs authentication"
        case .missingStableInfo:
            return "missing stable info"
        case .missingDynamicInfo:
            return "missing dynamic info"
        case .nonMember:
            return "non member"
        case .invalidPermanentInfoOrSig:
            return "invalid permanent info or signature"
        case .invalidStableInfoOrSig:
            return "invalid stable info or signature"
        case .invalidVoucherOrSig:
            return "invalid voucher or signature"
        case .sponsorNotRegistered(let s):
            return "sponsor not registered: \(s)"
        case .unknownPolicyVersion(let v):
            return "unknown policy version: \(v)"
        case .preparedIdentityNotOnAllowedList(let id):
            return "prepared identity (\(id)) not on allowed machineID list"
        case .couldNotLoadAllowedList:
            return "could not load allowed machineID list"
        case .noPeersPreapprovePreparedIdentity:
            return "no peers preapprove prepared identity"
        case .policyDocumentDoesNotValidate:
            return "policy document from server doesn't validate"
        case .tooManyBottlesForPeer:
            return "too many bottles exist for peer"
        case .noBottleForPeer:
            return "no bottle exists for peer"
        case .restoreBottleFailed:
            return "failed to restore bottle"
        case .noBottlesForEscrowRecordID:
            return "0 bottles exist for escrow record id"
        case .bottleDoesNotContainContents:
            return "bottle does not contain encrypted contents"
        case .bottleDoesNotContainEscrowKeySignature:
            return "bottle does not contain escrow signature"
        case .bottleDoesNotContainerPeerKeySignature:
            return "bottle does not contain peer signature"
        case .bottleDoesNotContainPeerID:
            return "bottle does not contain peer id"
        case .failedToCreateBottledPeer:
            return "failed to create a bottled peer"
        case .signatureVerificationFailed:
            return "failed to verify signature"
        case .bottleDoesNotContainerEscrowKeySPKI:
            return "bottle does not contain escrowed key spki"
        case .failedToFetchEscrowContents:
            return "failed to fetch escrow contents"
        case .failedToCreateRecoveryKey:
            return "failed to create recovery keys"
        case .untrustedRecoveryKeys:
            return "untrusted recovery keys"
        case .noBottlesPresent:
            return "no bottle present"
        case .recoveryKeysNotEnrolled:
            return "recovery key is not enrolled with octagon"
        case .bottleCreatingPeerNotFound:
            return "The peer that created the bottle was not found"
        case .unknownCloudKitError:
            return "unknown error from cloudkit"
        case .cloudkitResponseMissing:
            return "Response missing from CloudKit"
        case .failedToLoadSecret(errorCode: let errorCode):
            return "failed to load secret: \(errorCode)"
        case .failedToLoadSecretDueToType:
            return "Failed to load secret due to type mismatch (value was not dictionary)"
        case .failedToAssembleBottle:
            return "failed to assemble bottle for peer"
        case .invalidPeerID:
            return "peerID is invalid"
        case .failedToStoreSecret(errorCode: let errorCode):
            return "failed to store the secret in the keychain \(errorCode)"
        case .unknownSecurityFoundationError:
            return "SecurityFoundation returned an unknown type"
        case .failedToSerializeData:
            return "Failed to encode protobuf data"
        }
    }
}

extension ContainerError: CustomNSError {

    public static var errorDomain: String {
        return "com.apple.security.trustedpeers.container"
    }

    public var errorCode: Int {
        switch self {
        case .unableToCreateKeyPair:
            return 0
        case .noPreparedIdentity:
            return 1
        case .failedToStoreIdentity:
            return 2
        case .needsAuthentication:
            return 3
        case .missingStableInfo:
            return 4
        case .missingDynamicInfo:
            return 5
        case .nonMember:
            return 6
        case .invalidPermanentInfoOrSig:
            return 7
        case .invalidVoucherOrSig:
            return 8
        case .invalidStableInfoOrSig:
            return 9
        case .sponsorNotRegistered:
            return 11
        case .unknownPolicyVersion:
            return 12
        case .preparedIdentityNotOnAllowedList:
            return 13
        case .noPeersPreapprovePreparedIdentity:
            return 14
        case .policyDocumentDoesNotValidate:
            return 15
        // 16 was invalidPeerID and failedToAssembleBottle
        case .tooManyBottlesForPeer:
            return 17
        case .noBottleForPeer:
            return 18
        case .restoreBottleFailed:
            return 19
        case .noBottlesForEscrowRecordID:
            return 20
        case .bottleDoesNotContainContents:
            return 21
        case .bottleDoesNotContainEscrowKeySignature:
            return 22
        case .bottleDoesNotContainerPeerKeySignature:
            return 23
        case .bottleDoesNotContainPeerID:
            return 24
        case .failedToCreateBottledPeer:
            return 25
        case .signatureVerificationFailed:
            return 26
        // 27 was failedToLoadSecret*
        case .bottleDoesNotContainerEscrowKeySPKI:
            return 28
        case .failedToFetchEscrowContents:
            return 29
        case .couldNotLoadAllowedList:
            return 30
        case .failedToCreateRecoveryKey:
            return 31
        case .untrustedRecoveryKeys:
            return 32
        case .noBottlesPresent:
            return 33
        case .recoveryKeysNotEnrolled:
            return 34
        case .bottleCreatingPeerNotFound:
            return 35
        case .unknownCloudKitError:
            return 36
        case .cloudkitResponseMissing:
            return 37
        case .failedToLoadSecret:
            return 38
        case .failedToLoadSecretDueToType:
            return 39
        case .failedToStoreSecret:
            return 40
        case .failedToAssembleBottle:
            return 41
        case .invalidPeerID:
            return 42
        case .unknownSecurityFoundationError:
            return 43
        case .failedToSerializeData:
            return 44
        }
    }

    public var underlyingError: NSError? {
        switch self {
        case .failedToLoadSecret(errorCode: let errorCode):
            return NSError(domain: "securityd", code: errorCode)
        case .failedToStoreSecret(errorCode: let errorCode):
            return NSError(domain: "securityd", code: errorCode)
        default:
            return nil
        }
    }

    public var errorUserInfo: [String: Any] {
        var ret = [String: Any]()
        if let desc = self.errorDescription {
            ret[NSLocalizedDescriptionKey] = desc
        }
        if let underlyingError = self.underlyingError {
            ret[NSUnderlyingErrorKey] = underlyingError
        }
        return ret
    }
}

internal func traceError(_ error: Error?) -> String {
    if let error = error {
        return "error: \(String(describing: error))"
    } else {
        return "success"
    }
}

func saveSecret(_ secret: Data, label: String) throws {

    let query: [CFString: Any] = [
        kSecClass: kSecClassInternetPassword,
        kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
        kSecUseDataProtectionKeychain: true,
        kSecAttrAccessGroup: "com.apple.security.octagon",
        kSecAttrSynchronizable: false,
        kSecAttrDescription: label,
        kSecAttrPath: label,
        kSecValueData: secret,
        ]

    var results: CFTypeRef?
    var status = SecItemAdd(query as CFDictionary, &results)

    if status == errSecSuccess {
        return
    }

    if status == errSecDuplicateItem {
        // Add every primary key attribute to this find dictionary
        var findQuery: [CFString: Any] = [:]
        findQuery[kSecClass]              = query[kSecClass]
        findQuery[kSecAttrSynchronizable] = query[kSecAttrSynchronizable]
        findQuery[kSecAttrAccessGroup]    = query[kSecAttrAccessGroup]
        findQuery[kSecAttrServer]         = query[kSecAttrDescription]
        findQuery[kSecAttrPath]           = query[kSecAttrPath]
        findQuery[kSecUseDataProtectionKeychain] = query[kSecUseDataProtectionKeychain]

        var updateQuery: [CFString: Any] = query
        updateQuery[kSecClass] = nil

        status = SecItemUpdate(findQuery as CFDictionary, updateQuery as CFDictionary)

        if status != errSecSuccess {
            throw ContainerError.failedToStoreSecret(errorCode: Int(status))
        }
    } else {
        throw ContainerError.failedToStoreSecret(errorCode: Int(status))
    }
}

func loadSecret(label: String) throws -> (Data?) {
    var secret: Data?

    let query: [CFString: Any] = [
        kSecClass: kSecClassInternetPassword,
        kSecAttrAccessGroup: "com.apple.security.octagon",
        kSecAttrDescription: label,
        kSecReturnAttributes: true,
        kSecReturnData: true,
        kSecAttrSynchronizable: false,
        kSecMatchLimit: kSecMatchLimitOne,
        ]

    var result: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    if status != errSecSuccess || result == nil {
        throw ContainerError.failedToLoadSecret(errorCode: Int(status))
    }

    if result != nil {
        if let dictionary = result as? [CFString: Any] {
            secret = dictionary[kSecValueData] as? Data
        } else {
            throw ContainerError.failedToLoadSecretDueToType
        }
    }
    return secret
}

func saveEgoKeyPair(_ keyPair: _SFECKeyPair, identifier: String, resultHandler: @escaping (Bool, Error?) -> Void) {
    let keychainManager = _SFKeychainManager.default()
    let signingIdentity = _SFIdentity(keyPair: keyPair)
    let accessibility = SFAccessibilityMakeWithMode(SFAccessibilityMode.accessibleWhenUnlocked)  // class A
    let accessPolicy = _SFAccessPolicy(accessibility: accessibility,
                                       sharingPolicy: SFSharingPolicy.thisDeviceOnly)
    accessPolicy.accessGroup = egoIdentitiesAccessGroup
    keychainManager.setIdentity(signingIdentity,
                                forIdentifier: identifier,
                                accessPolicy: accessPolicy,
                                resultHandler: resultHandler)
}

func loadEgoKeyPair(identifier: String, resultHandler: @escaping (_SFECKeyPair?, Error?) -> Void) {
    let keychainManager = _SFKeychainManager.default()

    // FIXME constrain to egoIdentitiesAccessGroup, <rdar://problem/39597940>
    keychainManager.identity(forIdentifier: identifier) { result in
        switch result.resultType {
        case .valueAvailable:
            resultHandler(result.value?.keyPair as? _SFECKeyPair, nil)
        case .needsAuthentication:
            resultHandler(nil, ContainerError.needsAuthentication)
        case .error:
            resultHandler(nil, result.error)
        @unknown default:
            resultHandler(nil, ContainerError.unknownSecurityFoundationError)
        }
    }
}

func loadEgoKeys(peerID: String, resultHandler: @escaping (OctagonSelfPeerKeys?, Error?) -> Void) {
    loadEgoKeyPair(identifier: signingKeyIdentifier(peerID: peerID)) { signingKey, error in
        guard let signingKey = signingKey else {
            os_log("Unable to load signing key: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "error missing")
            resultHandler(nil, error)
            return
        }

        loadEgoKeyPair(identifier: encryptionKeyIdentifier(peerID: peerID)) { encryptionKey, error in
            guard let encryptionKey = encryptionKey else {
                os_log("Unable to load encryption key: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "error missing")
                resultHandler(nil, error)
                return
            }

            do {
                resultHandler(try OctagonSelfPeerKeys(peerID: peerID, signingKey: signingKey, encryptionKey: encryptionKey), nil)
            } catch {
                resultHandler(nil, error)
            }
        }
    }
}

func removeEgoKeysSync(peerID: String) throws -> Bool {
    var resultSema = DispatchSemaphore(value: 0)

    let keychainManager = _SFKeychainManager.default()

    var retresultForSigningDeletion: Bool = false
    var reterrorForSigningDeletion: Error?

    //remove signing keys
    keychainManager.removeItem(withIdentifier: signingKeyIdentifier(peerID: peerID)) { result, error in
        retresultForSigningDeletion = result
        reterrorForSigningDeletion = error
        resultSema.signal()
    }

    resultSema.wait()

    if let error = reterrorForSigningDeletion {
        throw error
    }

    if retresultForSigningDeletion == false {
        return retresultForSigningDeletion
    }

    // now let's do the same thing with the encryption keys
    resultSema = DispatchSemaphore(value: 0)
    var retresultForEncryptionDeletion: Bool = false
    var reterrorForEncryptionDeletion: Error?

    keychainManager.removeItem(withIdentifier: encryptionKeyIdentifier(peerID: peerID)) { result, error in
        retresultForEncryptionDeletion = result
        reterrorForEncryptionDeletion = error
        resultSema.signal()
    }
    resultSema.wait()

    if let error = reterrorForEncryptionDeletion {
        throw error
    }

    return retresultForEncryptionDeletion && retresultForSigningDeletion
}

func loadEgoKeysSync(peerID: String) throws -> OctagonSelfPeerKeys {
    // Gotta promote to synchronous; 'antipattern' ahoy
    let resultSema = DispatchSemaphore(value: 0)

    var result: OctagonSelfPeerKeys?
    var reserror: Error?

    loadEgoKeys(peerID: peerID) { keys, error in
        result = keys
        reserror = error
        resultSema.signal()
    }
    resultSema.wait()

    if let error = reserror {
        throw error
    }

    if let result = result {
        return result
    }

    abort()
}

func signingKeyIdentifier(peerID: String) -> String {
    return "signing-key " + peerID
}

func encryptionKeyIdentifier(peerID: String) -> String {
    return "encryption-key " + peerID
}

func makeTLKShares(ckksTLKs: [CKKSKeychainBackedKey]?, asPeer: CKKSSelfPeer, toPeer: CKKSPeer, epoch: Int) throws -> [TLKShare] {
    return try (ckksTLKs ?? []).map { tlk in
        os_log("Making TLKShare for %@ for key %@", log: tplogDebug, type: .default, toPeer.description, tlk)
        // Not being able to convert a TLK to a TLKShare is a failure, but not having a TLK is only half bad
        do {
            return TLKShare.convert(ckksTLKShare: try CKKSTLKShare(tlk, as: asPeer, to: toPeer, epoch: epoch, poisoned: 0))
        } catch {
            let nserror = error as NSError
            if nserror.domain == "securityd" && nserror.code == errSecItemNotFound {
                os_log("No TLK contents for %@, no TLK share possible", log: tplogDebug, type: .default, tlk)
                return nil
            } else {
                throw error
            }
        }
    }.compactMap { $0 }
}

func extract(tlkShares: [CKKSTLKShare], peer: CKKSSelfPeer) {
    os_log("Attempting to recover %d TLK shares for peer %@", log: tplogDebug, type: .default, tlkShares.count, peer.peerID)
    for share in tlkShares {
        guard share.receiverPeerID == peer.peerID else {
            os_log("Skipping %@ (wrong peerID)", log: tplogDebug, type: .default, share)
            continue
        }

        do {
            // TODO: how should we handle peer sets here?
            let key = try share.recoverTLK(peer,
                                           trustedPeers: [peer as! AnyHashable],
                                           ckrecord: nil)

            try key.saveMaterialToKeychain()
            os_log("Recovered %@ (from %@)", log: tplogDebug, type: .default, key, share)
        } catch {
            os_log("Failed to recover share %@: %@", log: tplogDebug, type: .default, share, error as CVarArg)
        }
    }

}

struct ContainerState {
    var egoPeerID: String?
    var peers: [String: TPPeer] = [:]
    var vouchers: [TPVoucher] = []
    var bottles = Set<BottleMO>()
    var recoverySigningKey: Data?
    var recoveryEncryptionKey: Data?
}

internal struct StableChanges {
    let deviceName: String?
    let serialNumber: String?
    let osVersion: String?
    let policyVersion: UInt64?
    let policySecrets: [String: Data]?
    let recoverySigningPubKey: Data?
    var recoveryEncryptionPubKey: Data?
}

// CoreData doesn't handle creating an identical model from an identical URL. Help it out.
private var nsObjectModels: [URL: NSManagedObjectModel] = [:]
private let nsObjectModelsQueue = DispatchQueue(label: "com.apple.security.TrustedPeersHelper.nsObjectModels")
func getOrMakeModel(url: URL) -> NSManagedObjectModel {
    return nsObjectModelsQueue.sync {
        if let model = nsObjectModels[url] {
            return model
        }
        let newModel = NSManagedObjectModel(contentsOf: url)!
        nsObjectModels[url] = newModel
        return newModel
    }
}

struct ContainerName: Hashable, CustomStringConvertible {
    let container: String
    let context: String

    func asSingleString() -> String {
        // Just to be nice, hide the fact that multiple contexts exist on most machines
        if self.context == OTDefaultContext {
            return self.container
        } else {
            return self.container + "-" + self.context
        }
    }

    var description: String {
        return "Container(\(self.container),\(self.context))"
    }
}

/// This maps to a Cuttlefish service backed by a CloudKit container,
/// and a corresponding local Core Data persistent container.
///
/// Methods may be invoked concurrently.
class Container: NSObject {
    let name: ContainerName

    private let cuttlefish: CuttlefishAPIAsync

    // Only one request (from Client) is permitted to be in progress at a time.
    // That includes while waiting for network, i.e. one request must complete
    // before the next can begin. Otherwise two requests could in parallel be
    // fetching updates from Cuttlefish, with ensuing changeToken overwrites etc.
    // This applies for mutating requests -- requests that can only read the current
    // state (on the moc queue) do not need to.
    internal let semaphore = DispatchSemaphore(value: 1)

    // All Core Data access happens through moc: NSManagedObjectContext. The
    // moc insists on having its own queue, and all operations must happen on
    // that queue.
    internal let moc: NSManagedObjectContext

    // Rather than Container having its own dispatch queue, we use moc's queue
    // to synchronise access to our own state as well. So the following instance
    // variables must only be accessed within blocks executed by calling
    // moc.perform() or moc.performAndWait().
    internal var containerMO: ContainerMO
    internal var model: TPModel

    /**
     Construct a Container.

     - Parameter name: The name the CloudKit container to which requests will be routed.

     The "real" container that drives CKKS etc should be named `"com.apple.security.keychain"`.
     Use other names for test containers such as for rawfish (rawhide-style testing for cuttlefish)

     - Parameter persistentStoreURL: The location the local Core Data database for this container will be stored.

     - Parameter cuttlefish: Interface to cuttlefish.
     */
    init(name: ContainerName, persistentStoreDescription: NSPersistentStoreDescription, cuttlefish: CuttlefishAPIAsync) throws {
        var initError: Error?
        var containerMO: ContainerMO?
        var model: TPModel?

        // Set up Core Data stack
        let url = Bundle(for: type(of: self)).url(forResource: "TrustedPeersHelper", withExtension: "momd")!
        let mom = getOrMakeModel(url: url)
        let persistentContainer = NSPersistentContainer(name: "TrustedPeersHelper", managedObjectModel: mom)
        persistentContainer.persistentStoreDescriptions = [persistentStoreDescription]

        persistentContainer.loadPersistentStores { _, error in
            initError = error
        }
        if let initError = initError {
            throw initError
        }

        let moc = persistentContainer.newBackgroundContext()
        moc.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump

        moc.performAndWait {
            // Fetch an existing ContainerMO record if it exists, or create and save one
            do {
                let containerFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Container")
                containerFetch.predicate = NSPredicate(format: "name == %@", name.asSingleString())
                let fetchedContainers = try moc.fetch(containerFetch)
                if let container = fetchedContainers.first as? ContainerMO {
                    containerMO = container
                } else {
                    containerMO = ContainerMO(context: moc)
                    containerMO!.name = name.asSingleString()
                }

                // Perform upgrades as needed
                Container.onqueueUpgradeMachineIDSetToModel(container: containerMO!, moc: moc)
                Container.onqueueUpgradeMachineIDSetToUseStatus(container: containerMO!, moc: moc)

                model = Container.loadModel(from: containerMO!)
                Container.ensureEgoConsistency(from: containerMO!, model: model!)
                try moc.save()
            } catch {
                initError = error
                return
            }
        }
        if let initError = initError {
            throw initError
        }

        self.name = name
        self.moc = moc
        self.containerMO = containerMO!
        self.cuttlefish = cuttlefish
        self.model = model!

        super.init()
    }

    // Must be on containerMO's moc queue to call this
    internal static func loadModel(from containerMO: ContainerMO) -> TPModel {
        // Populate model from persistent store
        let model = TPModel(decrypter: Decrypter())
        let keyFactory = TPECPublicKeyFactory()
        let peers = containerMO.peers as? Set<PeerMO>
        peers?.forEach { peer in
            guard let permanentInfo = TPPeerPermanentInfo(peerID: peer.peerID!,
                                                          data: peer.permanentInfo! as Data,
                                                          sig: peer.permanentInfoSig! as Data,
                                                          keyFactory: keyFactory) else {
                                                            return
            }
            model.registerPeer(with: permanentInfo)
            if let data = peer.stableInfo, let sig = peer.stableInfoSig {
                if let stableInfo = TPPeerStableInfo(data: data as Data, sig: sig as Data) {
                    do {
                        try model.update(stableInfo, forPeerWithID: permanentInfo.peerID)
                    } catch {
                        os_log("loadModel unable to update stable info for peer(%@): %@", log: tplogDebug, type: .default, peer, error as CVarArg)
                    }
                } else {
                    os_log("loadModel: peer %@ has unparseable stable info", log: tplogDebug, type: .default, permanentInfo.peerID)
                }
            } else {
                os_log("loadModel: peer %@ has no stable info", log: tplogDebug, type: .default, permanentInfo.peerID)
            }
            if let data = peer.dynamicInfo, let sig = peer.dynamicInfoSig {
                if let dynamicInfo = TPPeerDynamicInfo(data: data as Data, sig: sig as Data) {
                    do {
                        try model.update(dynamicInfo, forPeerWithID: permanentInfo.peerID)
                    } catch {
                        os_log("loadModel unable to update dynamic info for peer(%@): %@", log: tplogDebug, type: .default, peer, error as CVarArg)
                    }
                } else {
                    os_log("loadModel: peer %@ has unparseable dynamic info", log: tplogDebug, type: .default, permanentInfo.peerID)
                }
            } else {
                os_log("loadModel: peer %@ has no dynamic info", log: tplogDebug, type: .default, permanentInfo.peerID)
            }
            peer.vouchers?.forEach {
                let v = $0 as! VoucherMO
                if let data = v.voucherInfo, let sig = v.voucherInfoSig {
                    if let voucher = TPVoucher(infoWith: data, sig: sig) {
                        model.register(voucher)
                    }
                }
            }
        }

        // Register persisted policies (cached from cuttlefish)
        let policies = containerMO.policies as? Set<PolicyMO>
        policies?.forEach { policyMO in
            if let policyHash = policyMO.policyHash,
                let policyData = policyMO.policyData {
                if let policyDoc = TPPolicyDocument.policyDoc(withHash: policyHash, data: policyData) {
                    model.register(policyDoc)
                }
            }
        }

        // Register built-in policies
        builtInPolicyDocuments().forEach { policyDoc in
            model.register(policyDoc)
        }

        let knownMachines = containerMO.machines as? Set<MachineMO> ?? Set()
        let allowedMachineIDs = Set(knownMachines.filter { $0.status == TPMachineIDStatus.allowed.rawValue }.compactMap { $0.machineID })
        let disallowedMachineIDs = Set(knownMachines.filter { $0.status == TPMachineIDStatus.disallowed.rawValue }.compactMap { $0.machineID })

        os_log("loadModel: allowedMachineIDs: %@", log: tplogDebug, type: .default, allowedMachineIDs)
        os_log("loadModel: disallowedMachineIDs: %@", log: tplogDebug, type: .default, disallowedMachineIDs)

        if allowedMachineIDs.count == 0 {
            os_log("loadModel: no allowedMachineIDs?", log: tplogDebug, type: .default)
        }

        return model
    }

    // Must be on containerMO's moc queue to call this
    internal static func ensureEgoConsistency(from containerMO: ContainerMO, model: TPModel) {
        guard let egoPeerID = containerMO.egoPeerID,
            let egoStableData = containerMO.egoPeerStableInfo,
            let egoStableSig = containerMO.egoPeerStableInfoSig
            else {
                os_log("ensureEgoConsistency failed to find ego peer information", log: tplogDebug, type: .error)
                return
        }

        guard let containerEgoStableInfo = TPPeerStableInfo(data: egoStableData, sig: egoStableSig) else {
            os_log("ensureEgoConsistency failed to create TPPeerStableInfo from container", log: tplogDebug, type: .error)
            return
        }

        guard let modelStableInfo = model.getStableInfoForPeer(withID: egoPeerID) else {
            os_log("ensureEgoConsistency failed to create TPPeerStableInfo from model", log: tplogDebug, type: .error)
            return
        }

        if modelStableInfo.clock > containerEgoStableInfo.clock {
            containerMO.egoPeerStableInfo = modelStableInfo.data
            containerMO.egoPeerStableInfoSig = modelStableInfo.sig
        }

    }

    static func dictionaryRepresentation(bottle: BottleMO) -> [String: Any] {
        var dict: [String: String] = [:]

        dict["bottleID"] = bottle.bottleID
        dict["peerID"] = bottle.peerID
        dict["signingSPKI"] = bottle.escrowedSigningSPKI?.base64EncodedString()
        dict["signatureUsingPeerKey"] = bottle.signatureUsingPeerKey?.base64EncodedString()
        dict["signatureUsingSPKI"] = bottle.signatureUsingEscrowKey?.base64EncodedString()
        // ignore the bottle contents; they're mostly unreadable

        return dict
    }

    static func peerdictionaryRepresentation(peer: TPPeer) -> [String: Any] {
        var peerDict: [String: Any] = [
            "permanentInfo": peer.permanentInfo.dictionaryRepresentation(),
            "peerID": peer.peerID,
            ]
        if let stableInfo = peer.stableInfo {
            peerDict["stableInfo"] = stableInfo.dictionaryRepresentation()
        }
        if let dynamicInfo = peer.dynamicInfo {
            peerDict["dynamicInfo"] = dynamicInfo.dictionaryRepresentation()
        }

        return peerDict
    }

    func onQueueDetermineLocalTrustStatus(reply: @escaping (TrustedPeersHelperEgoPeerStatus, Error?) -> Void) {
        let viablePeerCountsByModelID = self.model.viablePeerCountsByModelID()
        let peerCountsByMachineID = self.model.peerCountsByMachineID()

        if let egoPeerID = self.containerMO.egoPeerID {
            var status = self.model.statusOfPeer(withID: egoPeerID)
            var isExcluded: Bool = (status == .excluded)

            loadEgoKeys(peerID: egoPeerID) { egoPeerKeys, loadError in
                var returnError = loadError

                guard returnError == nil else {
                    var isLocked = false
                    if let error = (loadError as NSError?) {
                        os_log("trust status: Unable to load ego keys: %@", log: tplogDebug, type: .default, error as CVarArg)
                        if error.code == errSecItemNotFound && error.domain == NSOSStatusErrorDomain {
                            os_log("trust status: Lost the ego key pair, returning 'excluded' in hopes of fixing up the identity", log: tplogDebug, type: .debug)
                            isExcluded = true
                            status = .excluded
                        } else if error.code == errSecInteractionNotAllowed && error.domain == NSOSStatusErrorDomain {
                            // we have an item, but can't read it, suppressing error
                            isLocked = true
                            returnError = nil
                        }
                    }

                    let egoStatus = TrustedPeersHelperEgoPeerStatus(egoPeerID: egoPeerID,
                                                                    status: status,
                                                                    viablePeerCountsByModelID: viablePeerCountsByModelID,
                                                                    peerCountsByMachineID: peerCountsByMachineID,
                                                                    isExcluded: isExcluded,
                                                                    isLocked: isLocked)
                    reply(egoStatus, returnError)
                    return
                }

                //ensure egoPeerKeys are populated
                guard egoPeerKeys != nil else {
                    os_log("trust status: No error but Ego Peer Keys are nil", log: tplogDebug, type: .default)
                    let egoStatus = TrustedPeersHelperEgoPeerStatus(egoPeerID: egoPeerID,
                                                                    status: .excluded,
                                                                    viablePeerCountsByModelID: viablePeerCountsByModelID,
                                                                    peerCountsByMachineID: peerCountsByMachineID,
                                                                    isExcluded: true,
                                                                    isLocked: false)

                    reply(egoStatus, loadError)
                    return
                }

                let egoStatus = TrustedPeersHelperEgoPeerStatus(egoPeerID: egoPeerID,
                                                                status: status,
                                                                viablePeerCountsByModelID: viablePeerCountsByModelID,
                                                                peerCountsByMachineID: peerCountsByMachineID,
                                                                isExcluded: isExcluded,
                                                                isLocked: false)
                reply(egoStatus, nil)
                return
            }

        } else {
            // With no ego peer ID, either return 'excluded' if there are extant peers, or 'unknown' to signal no peers at all
            if self.model.allPeerIDs().isEmpty {
                os_log("No existing peers in account", log: tplogDebug, type: .debug)
                let egoStatus = TrustedPeersHelperEgoPeerStatus(egoPeerID: nil,
                                                                status: .unknown,
                                                                viablePeerCountsByModelID: viablePeerCountsByModelID,
                                                                peerCountsByMachineID: peerCountsByMachineID,
                                                                isExcluded: false,
                                                                isLocked: false)
                reply(egoStatus, nil)
                return
            } else {
                os_log("Existing peers in account, but we don't have a peer ID. We are excluded.", log: tplogDebug, type: .debug)
                let egoStatus = TrustedPeersHelperEgoPeerStatus(egoPeerID: nil,
                                                                status: .excluded,
                                                                viablePeerCountsByModelID: viablePeerCountsByModelID,
                                                                peerCountsByMachineID: peerCountsByMachineID,
                                                                isExcluded: true,
                                                                isLocked: false)
                reply(egoStatus, nil)
                return
            }
        }
    }

    func trustStatus(reply: @escaping (TrustedPeersHelperEgoPeerStatus, Error?) -> Void) {
        self.semaphore.wait()
        let reply: (TrustedPeersHelperEgoPeerStatus, Error?) -> Void = {
            // Suppress logging of successful replies here; it's not that useful
            let logType: OSLogType = $1 == nil ? .debug : .info
            os_log("trustStatus complete: %@ %@",
                   log: tplogTrace, type: logType, TPPeerStatusToString($0.egoStatus), traceError($1))

            self.semaphore.signal()
            reply($0, $1)
        }
        self.moc.performAndWait {
            // Knowledge of your peer status only exists if you know about other peers. If you haven't fetched, fetch.
            if self.containerMO.changeToken == nil {
                self.fetchAndPersistChanges { fetchError in
                    guard fetchError == nil else {
                        if let error = fetchError {
                            os_log("Unable to fetch changes, trust status is unknown: %@", log: tplogDebug, type: .default, error as CVarArg)
                        }

                        let egoStatus = TrustedPeersHelperEgoPeerStatus(egoPeerID: nil,
                                                                        status: .unknown,
                                                                        viablePeerCountsByModelID: [:],
                                                                        peerCountsByMachineID: [:],
                                                                        isExcluded: false,
                                                                        isLocked: false)
                        reply(egoStatus, fetchError)
                        return
                    }

                    self.moc.performAndWait {
                        self.onQueueDetermineLocalTrustStatus(reply: reply)
                    }
                }
            } else {
                self.onQueueDetermineLocalTrustStatus(reply: reply)
            }
        }
    }

    func fetchTrustState(reply: @escaping (TrustedPeersHelperPeerState?, [TrustedPeersHelperPeer]?, Error?) -> Void) {
        let reply: (TrustedPeersHelperPeerState?, [TrustedPeersHelperPeer]?, Error?) -> Void = {
            os_log("fetch trust state complete: %@ %@",
                   log: tplogTrace, type: .info, String(reflecting: $0), traceError($2))
            reply($0, $1, $2)
        }

        self.moc.performAndWait {
            if let egoPeerID = self.containerMO.egoPeerID,
               let egoPermData = self.containerMO.egoPeerPermanentInfo,
               let egoPermSig = self.containerMO.egoPeerPermanentInfoSig {

                let keyFactory = TPECPublicKeyFactory()
                guard let permanentInfo = TPPeerPermanentInfo(peerID: egoPeerID, data: egoPermData, sig: egoPermSig, keyFactory: keyFactory) else {
                    os_log("fetchTrustState failed to create TPPeerPermanentInfo", log: tplogDebug, type: .error)
                    reply(nil, nil, ContainerError.invalidPermanentInfoOrSig)
                    return
                }

                let isPreapproved = self.model.hasPotentiallyTrustedPeerPreapprovingKey(permanentInfo.signingPubKey.spki())
                os_log("fetchTrustState: ego peer is %@", log: tplogDebug, type: .default, isPreapproved ? "preapproved" : "not yet preapproved")

                let egoStableInfo = self.model.getStableInfoForPeer(withID: egoPeerID)

                let egoPeerStatus = TrustedPeersHelperPeerState(peerID: egoPeerID,
                                                                isPreapproved: isPreapproved,
                                                                status: self.model.statusOfPeer(withID: egoPeerID),
                                                                memberChanges: false,
                                                                unknownMachineIDs: self.onqueueFullIDMSListWouldBeHelpful(),
                                                                osVersion: egoStableInfo?.osVersion)

                var tphPeers: [TrustedPeersHelperPeer] = []

                if let egoPeer = self.model.peer(withID: egoPeerID) {
                    egoPeer.trustedPeerIDs.forEach { trustedPeerID in
                        if let peer = self.model.peer(withID: trustedPeerID) {
                            let peerViews = try? self.model.getViewsForPeer(peer.permanentInfo,
                                                                            stableInfo: peer.stableInfo,
                                                                            inViews: Set())

                            tphPeers.append(TrustedPeersHelperPeer(peerID: trustedPeerID,
                                                                   signingSPKI: peer.permanentInfo.signingPubKey.spki(),
                                                                   encryptionSPKI: peer.permanentInfo.encryptionPubKey.spki(),
                                                                   viewList: peerViews ?? Set()))
                        } else {
                            os_log("No peer for trusted ID %@", log: tplogDebug, type: .default, trustedPeerID)
                        }
                    }
                } else {
                    os_log("No ego peer in model; no trusted peers", log: tplogDebug, type: .default)
                }

                os_log("Returning trust state: %@ %@", log: tplogDebug, type: .default, egoPeerStatus, tphPeers)
                reply(egoPeerStatus, tphPeers, nil)
            } else {
                // With no ego peer ID, there are no trusted peers
                os_log("No peer ID => no trusted peers", log: tplogDebug, type: .debug)
                reply(TrustedPeersHelperPeerState(peerID: nil, isPreapproved: false, status: .unknown, memberChanges: false, unknownMachineIDs: false, osVersion: nil), [], nil)
            }
        }
    }

    func dump(reply: @escaping ([AnyHashable: Any]?, Error?) -> Void) {
        let reply: ([AnyHashable: Any]?, Error?) -> Void = {
            os_log("dump complete: %@",
                   log: tplogTrace, type: .info, traceError($1))
            reply($0, $1)
       }
       self.moc.performAndWait {
            var d: [AnyHashable: Any] = [:]

            if let egoPeerID = self.containerMO.egoPeerID {
                if let peer = self.model.peer(withID: egoPeerID) {
                    d["self"] = Container.peerdictionaryRepresentation(peer: peer)
                } else {
                    d["self"] = ["peerID": egoPeerID]
                }
            } else {
                d["self"] = [:]
            }

            d["peers"] = self.model.allPeers().filter { $0.peerID != self.containerMO.egoPeerID }.map { peer in
                Container.peerdictionaryRepresentation(peer: peer)
            }

            d["vouchers"] = self.model.allVouchers().map { $0.dictionaryRepresentation() }

            if let bottles = self.containerMO.bottles as? Set<BottleMO> {
                d["bottles"] = bottles.map { Container.dictionaryRepresentation(bottle: $0) }
            } else {
                d["bottles"] = []
            }

            let midList = self.onqueueCurrentMIDList()
            d["machineIDsAllowed"] = midList.machineIDs(in: .allowed).sorted()
            d["machineIDsDisallowed"] = midList.machineIDs(in: .disallowed).sorted()
            d["modelRecoverySigningPublicKey"] = self.model.recoverySigningPublicKey()
            d["modelRecoveryEncryptionPublicKey"] = self.model.recoveryEncryptionPublicKey()

            reply(d, nil)
        }
    }

    func dumpEgoPeer(reply: @escaping (String?, TPPeerPermanentInfo?, TPPeerStableInfo?, TPPeerDynamicInfo?, Error?) -> Void) {
       let reply: (String?, TPPeerPermanentInfo?, TPPeerStableInfo?, TPPeerDynamicInfo?, Error?) -> Void = {
           os_log("dumpEgoPeer complete: %@", log: tplogTrace, type: .info, traceError($4))
           reply($0, $1, $2, $3, $4)
       }
       self.moc.performAndWait {
            guard let egoPeerID = self.containerMO.egoPeerID else {
                reply(nil, nil, nil, nil, ContainerError.noPreparedIdentity)
                return
            }

            guard let peer = self.model.peer(withID: egoPeerID) else {
                reply(egoPeerID, nil, nil, nil, nil)
                return
            }

            reply(egoPeerID, peer.permanentInfo, peer.stableInfo, peer.dynamicInfo, nil)
        }
    }

    func validatePeers(request: ValidatePeersRequest, reply: @escaping ([AnyHashable: Any]?, Error?) -> Void) {
        self.semaphore.wait()
        let reply: ([AnyHashable: Any]?, Error?) -> Void = {
            os_log("validatePeers complete %@", log: tplogTrace, type: .info, traceError($1))
            self.semaphore.signal()
            reply($0, $1)
        }

        self.cuttlefish.validatePeers(request) { response, error in
            os_log("ValidatePeers(%@): %@, error: %@", log: tplogDebug, "\(String(describing: request))", "\(String(describing: response))", "\(String(describing: error))")
            guard let response = response, error == nil else {
                os_log("validatePeers failed: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                reply(nil, error ?? ContainerError.cloudkitResponseMissing)
                return
            }

            var info: [AnyHashable: Any]  = [:]
            info["health"] = response.validatorsHealth as AnyObject
            info["results"] = try? JSONSerialization.jsonObject(with: response.jsonUTF8Data())

            reply(info, nil)
        }
    }

    func getViews(inViews: [String], reply: @escaping ([String]?, Error?) -> Void) {
        let reply: ([String]?, Error?) -> Void = {
            os_log("getViews complete %@", log: tplogTrace, type: .info, traceError($1))
            reply($0, $1)
        }
        self.moc.performAndWait {
            guard let egoPeerID = self.containerMO.egoPeerID,
                let egoPermData = self.containerMO.egoPeerPermanentInfo,
                let egoPermSig = self.containerMO.egoPeerPermanentInfoSig,
                let egoStableData = self.containerMO.egoPeerStableInfo,
                let egoStableSig = self.containerMO.egoPeerStableInfoSig
            else {
                 os_log("getViews failed to find ego peer information", log: tplogDebug, type: .error)
                 reply(nil, ContainerError.noPreparedIdentity)
                 return
            }
            guard let stableInfo = TPPeerStableInfo(data: egoStableData, sig: egoStableSig) else {
                 os_log("getViews failed to create TPPeerStableInfo", log: tplogDebug, type: .error)
                 reply(nil, ContainerError.invalidStableInfoOrSig)
                 return
            }

            let keyFactory = TPECPublicKeyFactory()
            guard let permanentInfo = TPPeerPermanentInfo(peerID: egoPeerID, data: egoPermData, sig: egoPermSig, keyFactory: keyFactory) else {
                 os_log("getViews failed to create TPPeerPermanentInfo", log: tplogDebug, type: .error)
                 reply(nil, ContainerError.invalidPermanentInfoOrSig)
                 return
            }

            do {
                let views = try self.model.getViewsForPeer(permanentInfo, stableInfo: stableInfo, inViews: Set(inViews))
                reply(Array(views), nil)
            } catch {
                reply(nil, error)
                return
            }
        }
    }

    func reset(resetReason: CuttlefishResetReason, reply: @escaping (Error?) -> Void) {
        self.semaphore.wait()
        let reply: (Error?) -> Void = {
            os_log("reset complete %@", log: tplogTrace, type: .info, traceError($0))
            self.semaphore.signal()
            reply($0)
        }

        self.moc.performAndWait {
            let resetReason = ResetReason.from(cuttlefishResetReason: resetReason)
            let request = ResetRequest.with {
                $0.resetReason = resetReason
            }
            self.cuttlefish.reset(request) { response, error in
                os_log("Reset(%@): %@, error: %@", log: tplogDebug, "\(String(describing: request))", "\(String(describing: response))", "\(String(describing: error))")
                guard let response = response, error == nil else {
                    os_log("reset failed: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                    reply(error ?? ContainerError.cloudkitResponseMissing)
                    return
                }

                // Erase container's persisted state
                self.moc.performAndWait {
                    self.moc.delete(self.containerMO)
                    self.containerMO = ContainerMO(context: self.moc)
                    self.containerMO.name = self.name.asSingleString()
                    self.model = Container.loadModel(from: self.containerMO)
                    do {
                        try self.onQueuePersist(changes: response.changes)
                        os_log("reset succeded", log: tplogDebug, type: .default)
                        reply(nil)
                    } catch {
                        os_log("reset persist failed: %@", log: tplogDebug, type: .default, (error as CVarArg))
                        reply(error)
                    }
                }
            }
        }
    }

    func localReset(reply: @escaping (Error?) -> Void) {
        self.semaphore.wait()
        let reply: (Error?) -> Void = {
            os_log("localReset complete %@", log: tplogTrace, type: .info, traceError($0))
            self.semaphore.signal()
            reply($0)
        }

        self.moc.performAndWait {
            do {
                // Erase container's persisted state
                self.moc.delete(self.containerMO)
                self.containerMO = ContainerMO(context: self.moc)
                self.containerMO.name = self.name.asSingleString()
                self.model = Container.loadModel(from: self.containerMO)
                try self.moc.save()
            } catch {
                reply(error)
                return
            }
            reply(nil)
        }
    }

    func loadOrCreateKeyPair(privateKeyPersistentRef: Data?) throws -> _SFECKeyPair {
        if let privateKeyPersistentRef = privateKeyPersistentRef {
            return try TPHObjectiveC.fetchKeyPair(withPrivateKeyPersistentRef: privateKeyPersistentRef)
        } else {
            let keySpecifier = _SFECKeySpecifier(curve: SFEllipticCurve.nistp384)
            guard let keyPair = _SFECKeyPair(randomKeyPairWith: keySpecifier) else {
                throw ContainerError.unableToCreateKeyPair
            }
            return keyPair
        }
    }

    // policyVersion should only be non-nil for testing, to override prevailingPolicyVersion
    func prepare(epoch: UInt64,
                 machineID: String,
                 bottleSalt: String,
                 bottleID: String,
                 modelID: String,
                 deviceName: String?,
                 serialNumber: String,
                 osVersion: String,
                 policyVersion: UInt64?,
                 policySecrets: [String: Data]?,
                 signingPrivateKeyPersistentRef: Data?,
                 encryptionPrivateKeyPersistentRef: Data?,
                 reply: @escaping (String?, Data?, Data?, Data?, Data?, Error?) -> Void) {
        self.semaphore.wait()
        let reply: (String?, Data?, Data?, Data?, Data?, Error?) -> Void = {
            os_log("prepare complete peerID: %@ %@",
                   log: tplogTrace, type: .info, ($0 ?? "NULL") as CVarArg, traceError($5))
            self.semaphore.signal()
            reply($0, $1, $2, $3, $4, $5)
        }

        // Create a new peer identity with random keys, and store the keys in keychain
        let permanentInfo: TPPeerPermanentInfo
        let signingKeyPair: _SFECKeyPair
        let encryptionKeyPair: _SFECKeyPair
        do {
            signingKeyPair = try self.loadOrCreateKeyPair(privateKeyPersistentRef: signingPrivateKeyPersistentRef)
            encryptionKeyPair = try self.loadOrCreateKeyPair(privateKeyPersistentRef: encryptionPrivateKeyPersistentRef)

            permanentInfo = try TPPeerPermanentInfo(machineID: machineID,
                                                    modelID: modelID,
                                                    epoch: 1,
                                                    signing: signingKeyPair,
                                                    encryptionKeyPair: encryptionKeyPair,
                                                    peerIDHashAlgo: TPHashAlgo.SHA256)

        } catch {
            reply(nil, nil, nil, nil, nil, error)
            return
        }

        let peerID = permanentInfo.peerID

        let bottle: BottledPeer
        do {
            bottle = try BottledPeer(peerID: peerID,
                                     bottleID: bottleID,
                                     peerSigningKey: signingKeyPair,
                                     peerEncryptionKey: encryptionKeyPair,
                                     bottleSalt: bottleSalt)

            _ = try saveSecret(bottle.secret, label: peerID)
        } catch {
            os_log("bottle creation failed: %@", log: tplogDebug, type: .default, error as CVarArg)
            reply(nil, nil, nil, nil, nil, error)
            return
        }

        saveEgoKeyPair(signingKeyPair, identifier: signingKeyIdentifier(peerID: peerID)) { success, error in
            guard success else {
                os_log("Unable to save signing key: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "error missing")
                reply(nil, nil, nil, nil, nil, error ?? ContainerError.failedToStoreIdentity)
                return
            }
            saveEgoKeyPair(encryptionKeyPair, identifier: encryptionKeyIdentifier(peerID: peerID)) { success, error in
                guard success else {
                    os_log("Unable to save encryption key: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "error missing")
                    reply(nil, nil, nil, nil, nil, error ?? ContainerError.failedToStoreIdentity)
                    return
                }

                // Save the prepared identity as containerMO.egoPeer* and its bottle
                self.moc.performAndWait {
                    do {
                        let policyVersion = policyVersion ?? prevailingPolicyVersion
                        let policyDoc = try self.getPolicyDoc(policyVersion)

                        let stableInfo = TPPeerStableInfo(clock: 1,
                                                          policyVersion: policyDoc.policyVersion,
                                                          policyHash: policyDoc.policyHash,
                                                          policySecrets: policySecrets,
                                                          deviceName: deviceName,
                                                          serialNumber: serialNumber,
                                                          osVersion: osVersion,
                                                          signing: signingKeyPair,
                                                          recoverySigningPubKey: nil,
                                                          recoveryEncryptionPubKey: nil,
                                                          error: nil)

                        self.containerMO.egoPeerID = permanentInfo.peerID
                        self.containerMO.egoPeerPermanentInfo = permanentInfo.data
                        self.containerMO.egoPeerPermanentInfoSig = permanentInfo.sig
                        self.containerMO.egoPeerStableInfo = stableInfo.data
                        self.containerMO.egoPeerStableInfoSig = stableInfo.sig

                        let bottleMO = BottleMO(context: self.moc)
                        bottleMO.peerID = bottle.peerID
                        bottleMO.bottleID = bottle.bottleID
                        bottleMO.escrowedSigningSPKI = bottle.escrowSigningSPKI
                        bottleMO.signatureUsingEscrowKey = bottle.signatureUsingEscrowKey
                        bottleMO.signatureUsingPeerKey = bottle.signatureUsingPeerKey
                        bottleMO.contents = bottle.contents

                        self.containerMO.addToBottles(bottleMO)

                        try self.moc.save()

                        reply(permanentInfo.peerID, permanentInfo.data, permanentInfo.sig, stableInfo.data, stableInfo.sig, nil)
                    } catch {
                        reply(nil, nil, nil, nil, nil, error)
                    }
                }
            }
        }
    }
    func getEgoEpoch(reply: @escaping (UInt64, Error?) -> Void) {
        let reply: (UInt64, Error?) -> Void = {
            os_log("getEgoEpoch complete: %d %@", log: tplogTrace, type: .info, $0, traceError($1))
            reply($0, $1)
        }

        self.moc.performAndWait {
            guard let egoPeerID = self.containerMO.egoPeerID else {
                reply(0, ContainerError.noPreparedIdentity)
                return
            }
            guard let egoPeer = self.model.peer(withID: egoPeerID) else {
                reply(0, ContainerError.noPreparedIdentity)
                return
            }

            reply(egoPeer.permanentInfo.epoch, nil)
        }
    }
    func establish(ckksKeys: [CKKSKeychainBackedKeySet],
                   tlkShares: [CKKSTLKShare],
                   preapprovedKeys: [Data]?,
                   reply: @escaping (String?, [CKRecord], Error?) -> Void) {
        self.semaphore.wait()
        let reply: (String?, [CKRecord], Error?) -> Void = {
            os_log("establish complete peer: %@ %@",
                   log: tplogTrace, type: .default, ($0 ?? "NULL") as CVarArg, traceError($2))
            self.semaphore.signal()
            reply($0, $1, $2)
        }

        self.moc.performAndWait {
            self.onqueueEstablish(ckksKeys: ckksKeys,
                                  tlkShares: tlkShares,
                                  preapprovedKeys: preapprovedKeys,
                                  reply: reply)
        }
    }

    func onqueueTTRUntrusted() {
        let ttr = SecTapToRadar(tapToRadar: "Device not IDMS trusted",
                                description: "Device not IDMS trusted",
                                radar: "52874119")
        ttr.trigger()
    }

    func onqueueEstablish(ckksKeys: [CKKSKeychainBackedKeySet],
                          tlkShares: [CKKSTLKShare],
                          preapprovedKeys: [Data]?,
                          reply: @escaping (String?, [CKRecord], Error?) -> Void) {
        // Fetch ego peer identity from local storage.
        guard let egoPeerID = self.containerMO.egoPeerID,
            let egoPermData = self.containerMO.egoPeerPermanentInfo,
            let egoPermSig = self.containerMO.egoPeerPermanentInfoSig,
            let egoStableData = self.containerMO.egoPeerStableInfo,
            let egoStableSig = self.containerMO.egoPeerStableInfoSig
            else {
                reply(nil, [], ContainerError.noPreparedIdentity)
                return
        }

        let keyFactory = TPECPublicKeyFactory()
        guard let selfPermanentInfo = TPPeerPermanentInfo(peerID: egoPeerID, data: egoPermData, sig: egoPermSig, keyFactory: keyFactory) else {
            reply(nil, [], ContainerError.invalidPermanentInfoOrSig)
            return
        }
        guard let selfStableInfo = TPPeerStableInfo(data: egoStableData, sig: egoStableSig) else {
            os_log("cannot create TPPeerStableInfo", log: tplogDebug, type: .default)
            reply(nil, [], ContainerError.invalidStableInfoOrSig)
            return
        }
        guard self.onqueueMachineIDAllowedByIDMS(machineID: selfPermanentInfo.machineID) else {
            os_log("establish: self machineID %@ not on list", log: tplogDebug, type: .debug, selfPermanentInfo.machineID)
            self.onqueueTTRUntrusted()
            reply(nil, [], ContainerError.preparedIdentityNotOnAllowedList(selfPermanentInfo.machineID))
            return
        }

        loadEgoKeys(peerID: egoPeerID) { egoPeerKeys, error in
             guard let egoPeerKeys = egoPeerKeys else {
                os_log("Don't have my own peer keys; can't establish: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "error missing")
                reply(nil, [], error)
                return
            }
            self.moc.performAndWait {
                let viewKeys: [ViewKeys] = ckksKeys.map(ViewKeys.convert)
                let allTLKShares: [TLKShare]
                do {
                    let octagonShares = try makeTLKShares(ckksTLKs: ckksKeys.map { $0.tlk }, asPeer: egoPeerKeys, toPeer: egoPeerKeys, epoch: Int(selfPermanentInfo.epoch))
                    let sosShares = tlkShares.map { TLKShare.convert(ckksTLKShare: $0) }

                    allTLKShares = octagonShares + sosShares
                } catch {
                    os_log("Unable to make TLKShares for self: %@", log: tplogDebug, type: .default, error as CVarArg)
                    reply(nil, [], error)
                    return
                }

                let dynamicInfo: TPPeerDynamicInfo
                do {
                    dynamicInfo = try self.model.dynamicInfo(forJoiningPeerID: egoPeerID,
                                                             peerPermanentInfo: selfPermanentInfo,
                                                             peerStableInfo: selfStableInfo,
                                                             sponsorID: nil,
                                                             preapprovedKeys: preapprovedKeys,
                                                             signing: egoPeerKeys.signingKey,
                                                             currentMachineIDs: self.onqueueCurrentMIDList())

                    os_log("dynamic info: %@", log: tplogDebug, type: .default, dynamicInfo)
                } catch {
                    reply(nil, [], error)
                    return
                }

                let peer = Peer.with {
                    $0.peerID = egoPeerID
                    $0.permanentInfoAndSig.peerPermanentInfo = egoPermData
                    $0.permanentInfoAndSig.sig = egoPermSig
                    $0.stableInfoAndSig.peerStableInfo = egoStableData
                    $0.stableInfoAndSig.sig = egoStableSig
                    $0.dynamicInfoAndSig = SignedPeerDynamicInfo(dynamicInfo)
                }

                let bottle: Bottle
                do {
                    bottle = try self.assembleBottle(egoPeerID: egoPeerID)
                } catch {
                    reply(nil, [], error)
                    return
                }
                os_log("Beginning establish for peer %@", log: tplogDebug, type: .default, egoPeerID)
                os_log("Establish permanentInfo: %@", log: tplogDebug, type: .debug, egoPermData.base64EncodedString())
                os_log("Establish permanentInfoSig: %@", log: tplogDebug, type: .debug, egoPermSig.base64EncodedString())
                os_log("Establish stableInfo: %@", log: tplogDebug, type: .debug, egoStableData.base64EncodedString())
                os_log("Establish stableInfoSig: %@", log: tplogDebug, type: .debug, egoStableSig.base64EncodedString())
                os_log("Establish dynamicInfo: %@", log: tplogDebug, type: .debug, peer.dynamicInfoAndSig.peerDynamicInfo.base64EncodedString())
                os_log("Establish dynamicInfoSig: %@", log: tplogDebug, type: .debug, peer.dynamicInfoAndSig.sig.base64EncodedString())

                os_log("Establish introducing %d key sets, %d tlk shares", log: tplogDebug, type: .default, viewKeys.count, allTLKShares.count)

                do {
                    os_log("Establish bottle: %@", log: tplogDebug, type: .debug, try bottle.serializedData().base64EncodedString())
                    os_log("Establish peer: %@", log: tplogDebug, type: .debug, try peer.serializedData().base64EncodedString())
                } catch {
                    os_log("Establish unable to encode bottle/peer: %@", log: tplogDebug, type: .debug, error as CVarArg)
                }

                let request = EstablishRequest.with {
                    $0.peer = peer
                    $0.bottle = bottle
                    $0.viewKeys = viewKeys
                    $0.tlkShares = allTLKShares
                }
                self.cuttlefish.establish(request) { response, error in
                    os_log("Establish(%@): %@, error: %@", log: tplogDebug, "\(String(describing: request))", "\(String(describing: response))", "\(String(describing: error))")
                    os_log("Establish: viewKeys: %@", String(describing: viewKeys))
                    guard let response = response, error == nil else {
                        os_log("establish failed: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                        reply(nil, [], error ?? ContainerError.cloudkitResponseMissing)
                        return
                    }

                    do {
                        os_log("Establish returned changes: %@", log: tplogDebug, type: .default, try response.changes.jsonString())
                    } catch {
                        os_log("Establish returned changes, but they can't be serialized", log: tplogDebug, type: .default)
                    }

                    let keyHierarchyRecords = response.zoneKeyHierarchyRecords.compactMap { CKRecord($0) }

                    do {
                        try self.persist(changes: response.changes)

                        guard response.changes.more == false else {
                            os_log("establish succeeded, but more changes need fetching...", log: tplogDebug, type: .default)

                            self.fetchAndPersistChanges { fetchError in
                                guard fetchError == nil else {
                                    // This is an odd error condition: we might be able to fetch again and be in a good state...
                                    os_log("fetch-after-establish failed: %@", log: tplogDebug, type: .default, (fetchError as CVarArg?) ?? "no error")
                                    reply(nil, keyHierarchyRecords, fetchError)
                                    return
                                }

                                os_log("fetch-after-establish succeeded", log: tplogDebug, type: .default)
                                reply(egoPeerID, keyHierarchyRecords, nil)
                            }
                            return
                        }

                        os_log("establish succeeded", log: tplogDebug, type: .default)
                        reply(egoPeerID, keyHierarchyRecords, nil)
                    } catch {
                        os_log("establish handling failed: %@", log: tplogDebug, type: .default, (error as CVarArg))
                        reply(nil, keyHierarchyRecords, error)
                    }
                }
            }
        }
    }

    func setRecoveryKey(recoveryKey: String, salt: String, ckksKeys: [CKKSKeychainBackedKeySet], reply: @escaping (Error?) -> Void) {
        self.semaphore.wait()
        let reply: (Error?) -> Void = {
            os_log("setRecoveryKey complete: %@", log: tplogTrace, type: .info, traceError($0))
            self.semaphore.signal()
            reply($0)
        }

        os_log("beginning a setRecoveryKey", log: tplogDebug, type: .default)

        self.moc.performAndWait {
            guard let egoPeerID = self.containerMO.egoPeerID else {
                os_log("no prepared identity, cannot set recovery key", log: tplogDebug, type: .default)
                reply(ContainerError.noPreparedIdentity)
                return
            }

            var recoveryKeys: RecoveryKey
            do {
                recoveryKeys = try RecoveryKey(recoveryKeyString: recoveryKey, recoverySalt: salt)
            } catch {
                os_log("failed to create recovery keys: %@", log: tplogDebug, type: .default, error as CVarArg)
                reply(ContainerError.failedToCreateRecoveryKey)
                return
            }

            let signingPublicKey: Data = recoveryKeys.peerKeys.signingVerificationKey.keyData
            let encryptionPublicKey: Data = recoveryKeys.peerKeys.encryptionVerificationKey.keyData

            os_log("setRecoveryKey signingPubKey: %@", log: tplogDebug, type: .debug, signingPublicKey.base64EncodedString())
            os_log("setRecoveryKey encryptionPubKey: %@", log: tplogDebug, type: .debug, encryptionPublicKey.base64EncodedString())

            guard let stableInfoData = self.containerMO.egoPeerStableInfo else {
                os_log("stableInfo does not exist", log: tplogDebug, type: .default)
                reply(ContainerError.nonMember)
                return
            }
            guard let stableInfoSig = self.containerMO.egoPeerStableInfoSig else {
                os_log("stableInfoSig does not exist", log: tplogDebug, type: .default)
                reply(ContainerError.nonMember)
                return
            }
            guard let permInfoData = self.containerMO.egoPeerPermanentInfo else {
                os_log("permanentInfo does not exist", log: tplogDebug, type: .default)
                reply(ContainerError.nonMember)
                return
            }
            guard let permInfoSig = self.containerMO.egoPeerPermanentInfoSig else {
                os_log("permInfoSig does not exist", log: tplogDebug, type: .default)
                reply(ContainerError.nonMember)
                return
            }
            guard let stableInfo = TPPeerStableInfo(data: stableInfoData, sig: stableInfoSig) else {
                os_log("cannot create TPPeerStableInfo", log: tplogDebug, type: .default)
                reply(ContainerError.invalidStableInfoOrSig)
                return
            }
            let keyFactory = TPECPublicKeyFactory()
            guard let permanentInfo = TPPeerPermanentInfo(peerID: egoPeerID, data: permInfoData, sig: permInfoSig, keyFactory: keyFactory) else {
                os_log("cannot create TPPeerPermanentInfo", log: tplogDebug, type: .default)
                reply(ContainerError.invalidStableInfoOrSig)
                return
            }

            loadEgoKeyPair(identifier: signingKeyIdentifier(peerID: egoPeerID)) { signingKeyPair, error in
                guard let signingKeyPair = signingKeyPair else {
                    os_log("handle: no signing key pair: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                    reply(error)
                    return
                }
                self.moc.performAndWait {
                    do {
                        let tlkShares = try makeTLKShares(ckksTLKs: ckksKeys.map { $0.tlk },
                                                          asPeer: recoveryKeys.peerKeys,
                                                          toPeer: recoveryKeys.peerKeys,
                                                          epoch: Int(permanentInfo.epoch))

                        let policyVersion = stableInfo.policyVersion
                        let policyDoc = try self.getPolicyDoc(policyVersion)

                        let updatedStableInfo = TPPeerStableInfo(clock: stableInfo.clock + 1,
                                                                 policyVersion: policyDoc.policyVersion,
                                                                 policyHash: policyDoc.policyHash,
                                                                 policySecrets: stableInfo.policySecrets,
                                                                 deviceName: stableInfo.deviceName,
                                                                 serialNumber: stableInfo.serialNumber,
                                                                 osVersion: stableInfo.osVersion,
                                                                 signing: signingKeyPair,
                                                                 recoverySigningPubKey: signingPublicKey,
                                                                 recoveryEncryptionPubKey: encryptionPublicKey,
                                                                 error: nil)
                        let signedStableInfo = SignedPeerStableInfo(updatedStableInfo)

                        let request = SetRecoveryKeyRequest.with {
                            $0.peerID = egoPeerID
                            $0.recoverySigningPubKey = signingPublicKey
                            $0.recoveryEncryptionPubKey = encryptionPublicKey
                            $0.stableInfoAndSig = signedStableInfo
                            $0.tlkShares = tlkShares
                            $0.changeToken = self.containerMO.changeToken ?? ""
                        }

                        self.cuttlefish.setRecoveryKey(request) { response, error in
                            os_log("SetRecoveryKey(%@): %@, error: %@", log: tplogDebug, "\(String(describing: request))", "\(String(describing: response))", "\(String(describing: error))")
                            guard let response = response, error == nil else {
                                os_log("setRecoveryKey failed: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                                reply(error ?? ContainerError.cloudkitResponseMissing)
                                return
                            }

                            self.moc.performAndWait {
                                do {
                                    self.containerMO.egoPeerStableInfo = updatedStableInfo.data
                                    self.containerMO.egoPeerStableInfoSig = updatedStableInfo.sig
                                    try self.onQueuePersist(changes: response.changes)

                                    os_log("setRecoveryKey succeeded", log: tplogDebug, type: .default)
                                    reply(nil)
                                } catch {
                                    os_log("setRecoveryKey handling failed: %@", log: tplogDebug, type: .default, (error as CVarArg))
                                    reply(error)
                                }
                            }
                        }
                    } catch {
                        reply(error)
                    }
                }
            }
        }
    }

    func currentSetContainerBottleID(bottleMOs: Set<BottleMO>, bottleID: String) -> (Bool) {
        let bmos = bottleMOs.filter {
            $0.bottleID == bottleID
        }
        return !bmos.isEmpty
    }

    func onqueueFindBottle(bottleID: String, reply: @escaping (BottleMO?, Error?) -> Void) {

        var bmo: BottleMO?
        var bottles: Set<BottleMO> = []
        var shouldPerformFetch = false

        if let containerBottles = self.containerMO.bottles as? Set<BottleMO> {
            if self.currentSetContainerBottleID(bottleMOs: containerBottles, bottleID: bottleID) == false {
                shouldPerformFetch = true
            } else {
                bottles = containerBottles
            }
        } else {
            shouldPerformFetch = true
        }

        if shouldPerformFetch == true {
            self.fetchViableBottlesWithSemaphore { _, _, error in
                guard error == nil else {
                    os_log("fetchViableBottles failed: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                    reply(nil, error)
                    return
                }

                guard let newBottles = self.containerMO.bottles as? Set<BottleMO> else {
                    os_log("no bottles on container: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                    reply(nil, ContainerError.noBottlesPresent)
                    return
                }

                guard self.currentSetContainerBottleID(bottleMOs: newBottles, bottleID: bottleID) == true else {
                    reply(nil, ContainerError.noBottlesForEscrowRecordID)
                    return
                }

                os_log("onqueueFindBottle found bottle: %@", log: tplogDebug, type: .default, newBottles)

                bottles = newBottles.filter {
                    $0.bottleID == bottleID
                }
                if bottles.count > 1 {
                    reply(nil, ContainerError.tooManyBottlesForPeer)
                    return
                }
                bmo = bottles.removeFirst()
                reply(bmo, nil)
            }
        } else {
            var filteredBottles = bottles.filter {
                $0.bottleID == bottleID
            }
            if filteredBottles.count > 1 {
                reply(nil, ContainerError.tooManyBottlesForPeer)
                return
            }
            bmo = filteredBottles.removeFirst()
            reply(bmo, nil)
        }
    }

    func onqueueRecoverBottle(managedBottle: BottleMO, entropy: Data, bottleSalt: String) throws -> BottledPeer {
        guard let bottledContents = managedBottle.contents else {
            throw ContainerError.bottleDoesNotContainContents
        }
        guard let signatureUsingEscrowKey = managedBottle.signatureUsingEscrowKey else {
            throw ContainerError.bottleDoesNotContainEscrowKeySignature
        }

        guard let signatureUsingPeerKey = managedBottle.signatureUsingPeerKey else {
            throw ContainerError.bottleDoesNotContainerPeerKeySignature
        }
        guard let sponsorPeerID = managedBottle.peerID else {
            throw ContainerError.bottleDoesNotContainPeerID
        }

        //verify bottle signature using peer
        do {
            guard let sponsorPeer = self.model.peer(withID: sponsorPeerID) else {
                os_log("recover bottle: Unable to find peer that created the bottle", log: tplogDebug, type: .default)
                throw ContainerError.bottleCreatingPeerNotFound
            }
            guard let signingKey: _SFECPublicKey = sponsorPeer.permanentInfo.signingPubKey as? _SFECPublicKey else {
                os_log("recover bottle: Unable to create a sponsor public key", log: tplogDebug, type: .default)
                throw ContainerError.signatureVerificationFailed
            }

            _ = try BottledPeer.verifyBottleSignature(data: bottledContents, signature: signatureUsingPeerKey, pubKey: signingKey)
        } catch {
            os_log("Verification of bottled signature failed: %@", log: tplogDebug, type: .default, error as CVarArg)
            throw ContainerError.failedToCreateBottledPeer
        }

        do {
            return try BottledPeer(contents: bottledContents,
                                   secret: entropy,
                                   bottleSalt: bottleSalt,
                                   signatureUsingEscrow: signatureUsingEscrowKey,
                                   signatureUsingPeerKey: signatureUsingPeerKey)
        } catch {
            os_log("Creation of Bottled Peer failed with bottle salt: %@,\nAttempting with empty bottle salt", bottleSalt)

            do {
                return try BottledPeer(contents: bottledContents,
                                       secret: entropy,
                                       bottleSalt: "",
                                       signatureUsingEscrow: signatureUsingEscrowKey,
                                       signatureUsingPeerKey: signatureUsingPeerKey)
            } catch {
                os_log("Creation of Bottled Peer failed: %@", log: tplogDebug, type: .default, error as CVarArg)
                throw ContainerError.failedToCreateBottledPeer
            }
        }
    }

    func preflightVouchWithBottle(bottleID: String,
                                  reply: @escaping (String?, Error?) -> Void) {
        self.semaphore.wait()
        let reply: (String?, Error?) -> Void = {
            os_log("preflightVouchWithBottle complete: %@",
                   log: tplogTrace, type: .info, traceError($1))
            self.semaphore.signal()
            reply($0, $1)
        }

        self.moc.performAndWait {
            self.onqueueFindBottle(bottleID: bottleID) { bottleMO, error in
                guard let bottleMO = bottleMO else {
                    os_log("preflightVouchWithBottle found no bottle: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "")
                    reply(nil, error)
                    return
                }

                reply(bottleMO.peerID, nil)
            }
        }
    }

    func vouchWithBottle(bottleID: String,
                         entropy: Data,
                         bottleSalt: String,
                         tlkShares: [CKKSTLKShare],
                         reply: @escaping (Data?, Data?, Error?) -> Void) {
        self.semaphore.wait()
        let reply: (Data?, Data?, Error?) -> Void = {
            os_log("vouchWithBottle complete: %@",
                   log: tplogTrace, type: .info, traceError($2))
            self.semaphore.signal()
            reply($0, $1, $2)
        }

        self.fetchAndPersistChanges { error in
            guard error == nil else {
                os_log("vouchWithBottle unable to fetch changes: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "")
                reply(nil, nil, error)
                return
            }

            self.onqueueFindBottle(bottleID: bottleID) { returnedBMO, error in
                self.moc.performAndWait {
                    guard error == nil else {
                        os_log("vouchWithBottle unable to find bottle for escrow record id: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "")
                        reply(nil, nil, error)
                        return
                    }

                    guard let bmo: BottleMO = returnedBMO else {
                        os_log("vouchWithBottle bottle is nil: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "")
                        reply(nil, nil, error)
                        return
                    }

                    guard let bottledContents = bmo.contents else {
                        reply(nil, nil, ContainerError.bottleDoesNotContainContents)
                        return
                    }
                    guard let signatureUsingEscrowKey = bmo.signatureUsingEscrowKey else {
                        reply(nil, nil, ContainerError.bottleDoesNotContainEscrowKeySignature)
                        return
                    }

                    guard let signatureUsingPeerKey = bmo.signatureUsingPeerKey else {
                        reply(nil, nil, ContainerError.bottleDoesNotContainerPeerKeySignature)
                        return
                    }
                    guard let sponsorPeerID = bmo.peerID else {
                        reply(nil, nil, ContainerError.bottleDoesNotContainPeerID)
                        return
                    }

                    //verify bottle signature using peer
                    do {
                        guard let sponsorPeer = self.model.peer(withID: sponsorPeerID) else {
                            os_log("vouchWithBottle: Unable to find peer that created the bottle", log: tplogDebug, type: .default)
                            reply(nil, nil, ContainerError.bottleCreatingPeerNotFound)
                            return
                        }
                        guard let signingKey: _SFECPublicKey = sponsorPeer.permanentInfo.signingPubKey as? _SFECPublicKey else {
                            os_log("vouchWithBottle: Unable to create a sponsor public key", log: tplogDebug, type: .default)
                            reply(nil, nil, ContainerError.signatureVerificationFailed)
                            return
                        }

                        _ = try BottledPeer.verifyBottleSignature(data: bottledContents, signature: signatureUsingPeerKey, pubKey: signingKey)
                    } catch {
                        os_log("vouchWithBottle: Verification of bottled signature failed: %@", log: tplogDebug, type: .default, error as CVarArg)
                        reply(nil, nil, ContainerError.failedToCreateBottledPeer)
                        return
                    }

                    //create bottled peer
                    let bottledPeer: BottledPeer
                    do {
                        bottledPeer = try BottledPeer(contents: bottledContents,
                                                      secret: entropy,
                                                      bottleSalt: bottleSalt,
                                                      signatureUsingEscrow: signatureUsingEscrowKey,
                                                      signatureUsingPeerKey: signatureUsingPeerKey)
                    } catch {
                        os_log("Creation of Bottled Peer failed with bottle salt: %@,\nAttempting with empty bottle salt", bottleSalt)

                        do {
                            bottledPeer = try BottledPeer(contents: bottledContents,
                                                          secret: entropy,
                                                          bottleSalt: "",
                                                          signatureUsingEscrow: signatureUsingEscrowKey,
                                                          signatureUsingPeerKey: signatureUsingPeerKey)
                        } catch {

                            os_log("Creation of Bottled Peer failed: %@", log: tplogDebug, type: .default, error as CVarArg)
                            reply(nil, nil, ContainerError.failedToCreateBottledPeer)
                            return
                        }
                    }

                    os_log("Have a bottle for peer %@", log: tplogDebug, type: .default, bottledPeer.peerID)

                    // Extract any TLKs we have been given
                    extract(tlkShares: tlkShares, peer: bottledPeer.peerKeys)

                    self.moc.performAndWait {
                        // I must have an ego identity in order to vouch using bottle
                        guard let egoPeerID = self.containerMO.egoPeerID else {
                            os_log("As a nonmember, can't vouch for someone else", log: tplogDebug, type: .default)
                            reply(nil, nil, ContainerError.nonMember)
                            return
                        }
                        guard let permanentInfo = self.containerMO.egoPeerPermanentInfo else {
                            os_log("permanentInfo does not exist", log: tplogDebug, type: .default)
                            reply(nil, nil, ContainerError.nonMember)
                            return
                        }
                        guard let permanentInfoSig = self.containerMO.egoPeerPermanentInfoSig else {
                            os_log("permanentInfoSig does not exist", log: tplogDebug, type: .default)
                            reply(nil, nil, ContainerError.nonMember)
                            return
                        }
                        guard let stableInfo = self.containerMO.egoPeerStableInfo else {
                            os_log("stableInfo does not exist", log: tplogDebug, type: .default)
                            reply(nil, nil, ContainerError.nonMember)
                            return
                        }
                        guard let stableInfoSig = self.containerMO.egoPeerStableInfoSig else {
                            os_log("stableInfoSig does not exist", log: tplogDebug, type: .default)
                            reply(nil, nil, ContainerError.nonMember)
                            return
                        }
                        let keyFactory = TPECPublicKeyFactory()
                        guard let beneficiaryPermanentInfo = TPPeerPermanentInfo(peerID: egoPeerID, data: permanentInfo, sig: permanentInfoSig, keyFactory: keyFactory) else {
                            os_log("Invalid permenent info or signature; can't vouch for them", log: tplogDebug, type: .default)
                            reply(nil, nil, ContainerError.invalidPermanentInfoOrSig)
                            return
                        }
                        guard let beneficiaryStableInfo = TPPeerStableInfo(data: stableInfo, sig: stableInfoSig) else {
                            os_log("Invalid stableinfo or signature; van't vouch for them", log: tplogDebug, type: .default)
                            reply(nil, nil, ContainerError.invalidStableInfoOrSig)
                            return
                        }

                        do {
                            let voucher = try self.model.createVoucher(forCandidate: beneficiaryPermanentInfo,
                                                                       stableInfo: beneficiaryStableInfo,
                                                                       withSponsorID: sponsorPeerID,
                                                                       reason: TPVoucherReason.restore,
                                                                       signing: bottledPeer.peerKeys.signingKey)
                            reply(voucher.data, voucher.sig, nil)
                            return
                        } catch {
                            os_log("Error creating voucher: %@", log: tplogDebug, type: .default, error as CVarArg)
                            reply(nil, nil, error)
                            return
                        }
                    }
                }
            }
        }
    }

    func vouchWithRecoveryKey(recoveryKey: String,
                              salt: String,
                              tlkShares: [CKKSTLKShare],
                              reply: @escaping (Data?, Data?, Error?) -> Void) {
        self.semaphore.wait()
        let reply: (Data?, Data?, Error?) -> Void = {
            os_log("vouchWithRecoveryKey complete: %@",
                   log: tplogTrace, type: .info, traceError($2))
            self.semaphore.signal()
            reply($0, $1, $2)
        }

        self.moc.performAndWait {
            os_log("beginning a vouchWithRecoveryKey", log: tplogDebug, type: .default)

            // I must have an ego identity in order to vouch using bottle
            guard let egoPeerID = self.containerMO.egoPeerID else {
                os_log("As a nonmember, can't vouch for someone else", log: tplogDebug, type: .default)
                reply(nil, nil, ContainerError.nonMember)
                return
            }
            guard let permanentInfo = self.containerMO.egoPeerPermanentInfo else {
                os_log("permanentInfo does not exist", log: tplogDebug, type: .default)
                reply(nil, nil, ContainerError.nonMember)
                return
            }
            guard let permanentInfoSig = self.containerMO.egoPeerPermanentInfoSig else {
                os_log("permanentInfoSig does not exist", log: tplogDebug, type: .default)
                reply(nil, nil, ContainerError.nonMember)
                return
            }
            guard let stableInfo = self.containerMO.egoPeerStableInfo else {
                os_log("stableInfo does not exist", log: tplogDebug, type: .default)
                reply(nil, nil, ContainerError.nonMember)
                return
            }
            guard let stableInfoSig = self.containerMO.egoPeerStableInfoSig else {
                os_log("stableInfoSig does not exist", log: tplogDebug, type: .default)
                reply(nil, nil, ContainerError.nonMember)
                return
            }
            let keyFactory = TPECPublicKeyFactory()
            guard let beneficiaryPermanentInfo = TPPeerPermanentInfo(peerID: egoPeerID, data: permanentInfo, sig: permanentInfoSig, keyFactory: keyFactory) else {
                os_log("Invalid permenent info or signature; can't vouch for them", log: tplogDebug, type: .default)
                reply(nil, nil, ContainerError.invalidPermanentInfoOrSig)
                return
            }
            guard let beneficiaryStableInfo = TPPeerStableInfo(data: stableInfo, sig: stableInfoSig) else {
                os_log("Invalid stableinfo or signature; van't vouch for them", log: tplogDebug, type: .default)
                reply(nil, nil, ContainerError.invalidStableInfoOrSig)
                return
            }

            //create recovery key set
            var recoveryKeys: RecoveryKey
            do {
                recoveryKeys = try RecoveryKey(recoveryKeyString: recoveryKey, recoverySalt: salt)
            } catch {
                os_log("failed to create recovery keys: %@", log: tplogDebug, type: .default, error as CVarArg)
                reply(nil, nil, ContainerError.failedToCreateRecoveryKey)
                return
            }

            extract(tlkShares: tlkShares, peer: recoveryKeys.peerKeys)

            let signingPublicKey: Data = recoveryKeys.peerKeys.signingKey.publicKey.keyData
            let encryptionPublicKey: Data = recoveryKeys.peerKeys.encryptionKey.publicKey.keyData

            os_log("vouchWithRecoveryKey signingPubKey: %@", log: tplogDebug, type: .debug, signingPublicKey.base64EncodedString())
            os_log("vouchWithRecoveryKey encryptionPubKey: %@", log: tplogDebug, type: .debug, encryptionPublicKey.base64EncodedString())

            guard self.model.isRecoveryKeyEnrolled() else {
                os_log("Recovery Key is not enrolled", log: tplogDebug, type: .default)
                reply(nil, nil, ContainerError.recoveryKeysNotEnrolled)
                return
            }

            //find matching peer containing recovery keys
            guard let sponsorPeerID = self.model.peerIDThatTrustsRecoveryKeys(TPRecoveryKeyPair(signingSPKI: signingPublicKey, encryptionSPKI: encryptionPublicKey)) else {
                os_log("Untrusted recovery key set", log: tplogDebug, type: .default)
                reply(nil, nil, ContainerError.untrustedRecoveryKeys)
                return
            }

            do {
                let voucher = try self.model.createVoucher(forCandidate: beneficiaryPermanentInfo,
                                                           stableInfo: beneficiaryStableInfo,
                                                           withSponsorID: sponsorPeerID,
                                                           reason: TPVoucherReason.recoveryKey,
                                                           signing: recoveryKeys.peerKeys.signingKey)
                reply(voucher.data, voucher.sig, nil)
                return
            } catch {
                os_log("Error creating voucher using recovery key set: %@", log: tplogDebug, type: .default, error as CVarArg)
                reply(nil, nil, error)
                return
            }
        }
    }

    func vouch(peerID: String,
               permanentInfo: Data,
               permanentInfoSig: Data,
               stableInfo: Data,
               stableInfoSig: Data,
               ckksKeys: [CKKSKeychainBackedKeySet],
               reply: @escaping (Data?, Data?, Error?) -> Void) {
        self.semaphore.wait()
        let reply: (Data?, Data?, Error?) -> Void = {
            os_log("vouch complete: %@", log: tplogTrace, type: .info, traceError($2))
            self.semaphore.signal()
            reply($0, $1, $2)
        }

        self.moc.performAndWait {
            // I must have an ego identity in order to vouch for someone else.
            guard let egoPeerID = self.containerMO.egoPeerID,
                let egoPermData = self.containerMO.egoPeerPermanentInfo,
                let egoPermSig = self.containerMO.egoPeerPermanentInfoSig else {
                    os_log("As a nonmember, can't vouch for someone else", log: tplogDebug, type: .default)
                    reply(nil, nil, ContainerError.nonMember)
                    return
            }

            let keyFactory = TPECPublicKeyFactory()

            guard let selfPermanentInfo = TPPeerPermanentInfo(peerID: egoPeerID, data: egoPermData, sig: egoPermSig, keyFactory: keyFactory) else {
                reply(nil, nil, ContainerError.invalidPermanentInfoOrSig)
                return
            }

            guard let beneficiaryPermanentInfo = TPPeerPermanentInfo(peerID: peerID, data: permanentInfo, sig: permanentInfoSig, keyFactory: keyFactory) else {
                os_log("Invalid permenent info or signature; can't vouch for them", log: tplogDebug, type: .default)
                reply(nil, nil, ContainerError.invalidPermanentInfoOrSig)
                return
            }

            guard let beneficiaryStableInfo = TPPeerStableInfo(data: stableInfo, sig: stableInfoSig) else {
                os_log("Invalid stableinfo or signature; van't vouch for them", log: tplogDebug, type: .default)
                reply(nil, nil, ContainerError.invalidStableInfoOrSig)
                return
            }

            loadEgoKeys(peerID: egoPeerID) { egoPeerKeys, error in
                guard let egoPeerKeys = egoPeerKeys else {
                    os_log("Don't have my own keys: can't vouch for %@: %@", log: tplogDebug, type: .default, beneficiaryPermanentInfo, (error as CVarArg?) ?? "no error")
                    reply(nil, nil, error)
                    return
                }
                self.moc.performAndWait {
                    let voucher: TPVoucher
                    do {
                        voucher = try self.model.createVoucher(forCandidate: beneficiaryPermanentInfo,
                                                               stableInfo: beneficiaryStableInfo,
                                                               withSponsorID: egoPeerID,
                                                               reason: TPVoucherReason.secureChannel,
                                                               signing: egoPeerKeys.signingKey)

                    } catch {
                        os_log("Error creating voucher: %@", log: tplogDebug, type: .default, error as CVarArg)
                        reply(nil, nil, error)
                        return
                    }

                    // And generate and upload any tlkShares
                    // Note that this might not be the whole list: <rdar://problem/47899980> Octagon: Limited Peers
                    let tlkShares: [TLKShare]
                    do {
                        // Note: we only want to send up TLKs for uploaded ckks zones
                        let ckksTLKs = ckksKeys.filter { !$0.newUpload }.map { $0.tlk }

                        tlkShares = try makeTLKShares(ckksTLKs: ckksTLKs,
                                                      asPeer: egoPeerKeys,
                                                      toPeer: beneficiaryPermanentInfo,
                                                      epoch: Int(selfPermanentInfo.epoch))
                    } catch {
                        os_log("Unable to make TLKShares for beneficiary %@: %@", log: tplogDebug, type: .default, beneficiaryPermanentInfo, error as CVarArg)
                        reply(nil, nil, error)
                        return
                    }

                    guard !tlkShares.isEmpty else {
                        os_log("No TLKShares to upload for new peer, returning voucher", log: tplogDebug, type: .default)
                        reply(voucher.data, voucher.sig, nil)
                        return
                    }

                    self.cuttlefish.updateTrust(changeToken: self.containerMO.changeToken ?? "",
                                                peerID: egoPeerID,
                                                stableInfoAndSig: nil,
                                                dynamicInfoAndSig: nil,
                                                tlkShares: tlkShares,
                                                viewKeys: []) { response, error in
                                                    guard let response = response, error == nil else {
                                                        os_log("Unable to upload new tlkshares: %@", log: tplogDebug, type: .default, error as CVarArg? ?? "no error")
                                                        reply(voucher.data, voucher.sig, error ?? ContainerError.cloudkitResponseMissing)
                                                        return
                                                    }

                                                    let newKeyRecords = response.zoneKeyHierarchyRecords.map(CKRecord.init)
                                                    os_log("Uploaded new tlkshares: %@", log: tplogDebug, type: .default, newKeyRecords)
                                                    // We don't need to save these; CKKS will refetch them as needed

                                                    reply(voucher.data, voucher.sig, nil)
                    }
                }
            }
        }
    }

    func departByDistrustingSelf(reply: @escaping (Error?) -> Void) {
        self.semaphore.wait()
        let reply: (Error?) -> Void = {
            os_log("departByDistrustingSelf complete: %@", log: tplogTrace, type: .info, traceError($0))
            self.semaphore.signal()
            reply($0)
        }

        self.moc.performAndWait {
            guard let egoPeerID = self.containerMO.egoPeerID else {
                os_log("No dynamic info for self?", log: tplogDebug, type: .default)
                reply(ContainerError.noPreparedIdentity)
                return
            }

            self.onqueueDistrust(peerIDs: [egoPeerID], reply: reply)
        }
    }

    func distrust(peerIDs: Set<String>,
                  reply: @escaping (Error?) -> Void) {
        self.semaphore.wait()
        let reply: (Error?) -> Void = {
            os_log("distrust complete: %@", log: tplogTrace, type: .info, traceError($0))
            self.semaphore.signal()
            reply($0)
        }

        self.moc.performAndWait {
            guard let egoPeerID = self.containerMO.egoPeerID else {
                os_log("No dynamic info for self?", log: tplogDebug, type: .default)
                reply(ContainerError.noPreparedIdentity)
                return
            }

            guard !peerIDs.contains(egoPeerID) else {
                os_log("Self-distrust via peerID not allowed", log: tplogDebug, type: .default)
                reply(ContainerError.invalidPeerID)
                return
            }

            self.onqueueDistrust(peerIDs: peerIDs, reply: reply)
        }
    }

    func onqueueDistrust(peerIDs: Set<String>,
                         reply: @escaping (Error?) -> Void) {

        guard let egoPeerID = self.containerMO.egoPeerID else {
            os_log("No dynamic info for self?", log: tplogDebug, type: .default)
            reply(ContainerError.noPreparedIdentity)
            return
        }

        loadEgoKeyPair(identifier: signingKeyIdentifier(peerID: egoPeerID)) { signingKeyPair, error in
            guard let signingKeyPair = signingKeyPair else {
                os_log("No longer have signing key pair; can't sign distrust: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "nil")
                reply(error)
                return
            }

            self.moc.performAndWait {
                let dynamicInfo: TPPeerDynamicInfo
                do {
                    dynamicInfo = try self.model.calculateDynamicInfoForPeer(withID: egoPeerID,
                                                                             addingPeerIDs: nil,
                                                                             removingPeerIDs: Array(peerIDs),
                                                                             preapprovedKeys: nil,
                                                                             signing: signingKeyPair,
                                                                             currentMachineIDs: self.onqueueCurrentMIDList())

                } catch {
                    os_log("Error preparing dynamic info: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "nil")
                    reply(error)
                    return
                }

                let signedDynamicInfo = SignedPeerDynamicInfo(dynamicInfo)
                os_log("attempting distrust for %@ with: %@", log: tplogDebug, type: .default, peerIDs, dynamicInfo)

                let request = UpdateTrustRequest.with {
                    $0.changeToken = self.containerMO.changeToken ?? ""
                    $0.peerID = egoPeerID
                    $0.dynamicInfoAndSig = signedDynamicInfo
                }
                self.cuttlefish.updateTrust(request) { response, error in
                    os_log("UpdateTrust(%@): %@, error: %@", log: tplogDebug, "\(String(describing: request))", "\(String(describing: response))", "\(String(describing: error))")
                    guard let response = response, error == nil else {
                        os_log("updateTrust failed: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                        reply(error ?? ContainerError.cloudkitResponseMissing)
                        return
                    }

                    do {
                        try self.persist(changes: response.changes)
                        os_log("distrust succeeded", log: tplogDebug, type: .default)
                        reply(nil)
                    } catch {
                        os_log("distrust handling failed: %@", log: tplogDebug, type: .default, (error as CVarArg))
                        reply(error)
                    }
                }
            }
        }
    }

    func fetchEscrowContents(reply: @escaping (Data?, String?, Data?, Error?) -> Void) {
        self.semaphore.wait()
        let reply: (Data?, String?, Data?, Error?) -> Void = {
            os_log("fetchEscrowContents complete: %@", log: tplogTrace, type: .info, traceError($3))
            self.semaphore.signal()
            reply($0, $1, $2, $3)
        }
        os_log("beginning a fetchEscrowContents", log: tplogDebug, type: .default)

        self.moc.performAndWait {
            guard let egoPeerID = self.containerMO.egoPeerID else {
                os_log("fetchEscrowContents failed", log: tplogDebug, type: .default)
                reply(nil, nil, nil, ContainerError.noPreparedIdentity)
                return
            }

            guard let bottles = self.containerMO.bottles as? Set<BottleMO> else {
                os_log("fetchEscrowContents failed", log: tplogDebug, type: .default)
                reply(nil, nil, nil, ContainerError.noBottleForPeer)
                return
            }

            var bmoSet = bottles.filter { $0.peerID == egoPeerID }
            let bmo = bmoSet.removeFirst()
            let bottleID = bmo.bottleID
            var entropy: Data

            do {
                guard let loaded = try loadSecret(label: egoPeerID) else {
                    os_log("fetchEscrowContents failed to load entropy", log: tplogDebug, type: .default)
                    reply(nil, nil, nil, ContainerError.failedToFetchEscrowContents)
                    return
                }
                entropy = loaded
            } catch {
                os_log("fetchEscrowContents failed to load entropy: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                reply(nil, nil, nil, error)
                return
            }

            guard let signingPublicKey = bmo.escrowedSigningSPKI else {
                os_log("fetchEscrowContents no escrow signing spki", log: tplogDebug, type: .default)
                reply(nil, nil, nil, ContainerError.bottleDoesNotContainerEscrowKeySPKI)
                return
            }
            reply(entropy, bottleID, signingPublicKey, nil)
        }
    }

    func fetchViableBottles(reply: @escaping ([String]?, [String]?, Error?) -> Void) {
        self.semaphore.wait()
        let reply: ([String]?, [String]?, Error?) -> Void = {
            os_log("fetchViableBottles complete: %@", log: tplogTrace, type: .info, traceError($2))
            self.semaphore.signal()
            reply($0, $1, $2)
        }

        self.fetchViableBottlesWithSemaphore(reply: reply)
    }

    func onqueueCachedBottlesContainEgoPeerBottle(cachedBottles: TPCachedViableBottles) -> Bool {
        guard let egoPeerID = self.containerMO.egoPeerID else {
            os_log("bottleForEgoPeer: No identity.", log: tplogDebug, type: .default)
            return false
        }
        guard let bottles: Set<BottleMO> = self.containerMO.bottles as? Set<BottleMO>  else {
            os_log("bottleForEgoPeer: No Bottles.", log: tplogDebug, type: .default)
            return false
        }
        var matchesCached: Bool = false
        for bottle in bottles {
            guard let bottleID: String = bottle.bottleID else {
                continue
            }
            if bottle.peerID == egoPeerID && (cachedBottles.viableBottles.contains(bottleID) || cachedBottles.partialBottles.contains(bottleID)) {
                matchesCached = true
                break
            }
        }
        return matchesCached
    }

    func fetchViableBottlesWithSemaphore(reply: @escaping ([String]?, [String]?, Error?) -> Void) {
        os_log("beginning a fetchViableBottles", log: tplogDebug, type: .default)

        let cachedBottles: TPCachedViableBottles = self.model.currentCachedViableBottlesSet()
        self.moc.performAndWait {
            if self.onqueueCachedBottlesContainEgoPeerBottle(cachedBottles: cachedBottles)
                && (cachedBottles.viableBottles.count > 0 || cachedBottles.partialBottles.count > 0) {
                os_log("returning from fetchViableBottles, using cached bottles", log: tplogDebug, type: .default)
                reply(cachedBottles.viableBottles, cachedBottles.partialBottles, nil)
                return
            }

            self.cuttlefish.fetchViableBottles { response, error in
                guard error == nil else {
                    os_log("fetchViableBottles failed: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                    reply(nil, nil, error)
                    return
                }

                self.moc.performAndWait {

                    guard let escrowPairs = response?.viableBottles else {
                        os_log("fetchViableBottles returned no viable bottles: %@", log: tplogDebug, type: .default)
                        reply([], [], nil)
                        return
                    }

                    var partialPairs: [EscrowPair] = []
                    if let partial = response?.partialBottles {
                        partialPairs = partial
                    } else {
                        os_log("fetchViableBottles returned no partially viable bottles, but that's ok: %@", log: tplogDebug, type: .default)
                    }

                    let viableBottleIDs = escrowPairs.compactMap { $0.bottle.bottleID }
                    os_log("fetchViableBottles returned viable bottles: %@", log: tplogDebug, type: .default, viableBottleIDs)

                    let partialBottleIDs = partialPairs.compactMap { $0.bottle.bottleID }
                    os_log("fetchViableBottles returned partial bottles: %@", log: tplogDebug, type: .default, partialBottleIDs)

                    escrowPairs.forEach { pair in
                        let bottle = pair.bottle

                        // Save this bottle only if we don't already have it
                        if let existingBottles = self.containerMO.bottles as? Set<BottleMO> {
                            let matchingBottles: Set<BottleMO> = existingBottles.filter { existing in
                                existing.peerID == bottle.peerID &&
                                    existing.bottleID == bottle.bottleID &&
                                    existing.escrowedSigningSPKI == bottle.escrowedSigningSpki &&
                                    existing.signatureUsingEscrowKey == bottle.signatureUsingEscrowKey &&
                                    existing.signatureUsingPeerKey == bottle.signatureUsingPeerKey &&
                                    existing.contents == bottle.contents
                            }
                            if !matchingBottles.isEmpty {
                                os_log("fetchViableBottles already knows about bottle", log: tplogDebug, type: .default, bottle.bottleID)
                                return
                            }
                        }

                        let bmo = BottleMO(context: self.moc)
                        bmo.peerID = bottle.peerID
                        bmo.bottleID = bottle.bottleID
                        bmo.escrowedSigningSPKI = bottle.escrowedSigningSpki
                        bmo.signatureUsingEscrowKey = bottle.signatureUsingEscrowKey
                        bmo.signatureUsingPeerKey = bottle.signatureUsingPeerKey
                        bmo.contents = bottle.contents

                        os_log("fetchViableBottles saving new bottle: %@", log: tplogDebug, type: .default, bmo)
                        self.containerMO.addToBottles(bmo)
                    }

                    partialPairs.forEach { pair in
                        let bottle = pair.bottle

                        // Save this bottle only if we don't already have it
                        if let existingBottles = self.containerMO.bottles as? Set<BottleMO> {
                            let matchingBottles: Set<BottleMO> = existingBottles.filter { existing in
                                existing.peerID == bottle.peerID &&
                                    existing.bottleID == bottle.bottleID &&
                                    existing.escrowedSigningSPKI == bottle.escrowedSigningSpki &&
                                    existing.signatureUsingEscrowKey == bottle.signatureUsingEscrowKey &&
                                    existing.signatureUsingPeerKey == bottle.signatureUsingPeerKey &&
                                    existing.contents == bottle.contents
                            }
                            if !matchingBottles.isEmpty {
                                os_log("fetchViableBottles already knows about bottle", log: tplogDebug, type: .default, bottle.bottleID)
                                return
                            }
                        }

                        let bmo = BottleMO(context: self.moc)
                        bmo.peerID = bottle.peerID
                        bmo.bottleID = bottle.bottleID
                        bmo.escrowedSigningSPKI = bottle.escrowedSigningSpki
                        bmo.signatureUsingEscrowKey = bottle.signatureUsingEscrowKey
                        bmo.signatureUsingPeerKey = bottle.signatureUsingPeerKey
                        bmo.contents = bottle.contents

                        os_log("fetchViableBottles saving new bottle: %@", log: tplogDebug, type: .default, bmo)
                        self.containerMO.addToBottles(bmo)
                    }

                    do {
                        try self.moc.save()
                        os_log("fetchViableBottles saved bottles", log: tplogDebug, type: .default)
                        let cached = TPCachedViableBottles(viableBottles: viableBottleIDs, partialBottles: partialBottleIDs)
                        self.model.setViableBottles(cached)
                        reply(viableBottleIDs, partialBottleIDs, nil)
                    } catch {
                        os_log("fetchViableBottles unable to save bottles: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                        reply(nil, nil, error)
                    }

                }
            }
        }
    }

    func fetchPolicy(reply: @escaping (TPPolicy?, Error?) -> Void) {
        self.semaphore.wait()
        let reply: (TPPolicy?, Error?) -> Void = {
            os_log("fetchPolicy complete: %@", log: tplogTrace, type: .info, traceError($1))
            self.semaphore.signal()
            reply($0, $1)
        }

        self.moc.performAndWait {
            var keys: [NSNumber: String] = [:]

             guard let stableInfoData = self.containerMO.egoPeerStableInfo,
                 let stableInfoSig = self.containerMO.egoPeerStableInfoSig else {
                 os_log("fetchPolicy failed to find ego peer stableinfodata/sig", log: tplogDebug, type: .error)
                 reply(nil, ContainerError.noPreparedIdentity)
                 return
             }
             guard let stableInfo = TPPeerStableInfo(data: stableInfoData, sig: stableInfoSig) else {
                 os_log("fetchPolicy failed to create TPPeerStableInfo", log: tplogDebug, type: .error)
                 reply(nil, ContainerError.invalidStableInfoOrSig)
                 return
             }

             let policyVersionCounter = stableInfo.policyVersion
             let policyVersion = NSNumber(value: policyVersionCounter)
             keys[policyVersion] = stableInfo.policyHash

            if let policyDocument = self.model.policy(withVersion: policyVersionCounter) {
                os_log("fetchPolicy: have a local version of policy %@: %@", log: tplogDebug, type: .default, policyVersion, policyDocument)
                do {
                    let policy = try policyDocument.policy(withSecrets: stableInfo.policySecrets, decrypter: Decrypter())
                    reply(policy, nil)
                    return
                } catch {
                    os_log("TPPolicyDocument failed: %@", log: tplogDebug, type: .default, error as CVarArg)
                    reply(nil, error)
                    return
                }
            }

            self.fetchPolicyDocuments(keys: keys) { result, error in
                guard error == nil else {
                    reply(nil, error)
                    return
                }
                guard let result = result else {
                    os_log("fetchPolicy: nil policies returned")
                    reply(nil, ContainerError.policyDocumentDoesNotValidate)
                    return
                }
                guard result.count == 1 else {
                    os_log("fetchPolicy: wrong length returned")
                    reply(nil, ContainerError.policyDocumentDoesNotValidate)
                    return
                }
                guard let r = result[policyVersion] else {
                    os_log("fetchPolicy: version not found")
                    reply(nil, ContainerError.unknownPolicyVersion(policyVersion.uint64Value))
                    return
                }
                guard let data = r[1].data(using: .utf8) else {
                    os_log("fetchPolicy: failed to convert data")
                    reply(nil, ContainerError.unknownPolicyVersion(policyVersion.uint64Value))
                    return
                }
                guard let pd = TPPolicyDocument.policyDoc(withHash: r[0], data: data) else {
                    os_log("fetchPolicy: pd is nil")
                    reply(nil, ContainerError.policyDocumentDoesNotValidate)
                    return
                }
                do {
                    let policy = try pd.policy(withSecrets: stableInfo.policySecrets, decrypter: Decrypter())
                    reply(policy, nil)
                } catch {
                    os_log("TPPolicyDocument: %@", log: tplogDebug, type: .default, error as CVarArg)
                    reply(nil, error)
                }
            }
        }
    }

    // All-or-nothing: return an error in case full list cannot be returned.
    // Completion handler data format: [version : [hash, data]]
    func fetchPolicyDocuments(keys: [NSNumber: String],
                              reply: @escaping ([NSNumber: [String]]?, Error?) -> Void) {
        self.semaphore.wait()
        let reply: ([NSNumber: [String]]?, Error?) -> Void = {
            os_log("fetchPolicyDocuments complete: %@", log: tplogTrace, type: .info, traceError($1))
            self.semaphore.signal()
            reply($0, $1)
        }

        var keys = keys
        var docs: [NSNumber: [String]] = [:]

        self.moc.performAndWait {
            for (version, hash) in keys {
                if let policydoc = try? self.getPolicyDoc(version.uint64Value), policydoc.policyHash == hash {
                    docs[version] = [policydoc.policyHash, policydoc.protobuf.base64EncodedString()]
                    keys[version] = nil
                }
            }
        }

        if keys.isEmpty {
            reply(docs, nil)
            return
        }

        let request = FetchPolicyDocumentsRequest.with {
            $0.keys = keys.map { key, value in
                PolicyDocumentKey.with { $0.version = key.uint64Value; $0.hash = value }}
        }

        self.cuttlefish.fetchPolicyDocuments(request) { response, error in
            os_log("FetchPolicyDocuments(%@): %@, error: %@", log: tplogDebug, "\(String(describing: request))", "\(String(describing: response))", "\(String(describing: error))")
            guard let response = response, error == nil else {
                os_log("FetchPolicyDocuments failed: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                reply(nil, error ?? ContainerError.cloudkitResponseMissing)
                return
            }

            self.moc.performAndWait {
                for mapEntry in response.entries {
                    // TODO: validate the policy's signature

                    guard let doc = TPPolicyDocument.policyDoc(withHash: mapEntry.key.hash, data: mapEntry.value) else {
                        os_log("Can't make policy document with hash %@ and data %@",
                               log: tplogDebug, type: .default, mapEntry.key.hash, mapEntry.value.base64EncodedString())
                        reply(nil, ContainerError.policyDocumentDoesNotValidate)
                        return
                    }

                    guard let hash = keys[NSNumber(value: doc.policyVersion)], hash == doc.policyHash else {
                        os_log("Requested hash %@ does not match fetched hash %@", log: tplogDebug, type: .default,
                               keys[NSNumber(value: doc.policyVersion)] ?? "<nil>", doc.policyHash)
                        reply(nil, ContainerError.policyDocumentDoesNotValidate)
                        return
                    }
                    keys[NSNumber(value: doc.policyVersion)] = nil  // Server responses should be unique, let's enforce
                    docs[NSNumber(value: doc.policyVersion)] = [doc.policyHash, doc.protobuf.base64EncodedString()]
                    self.model.register(doc)
                }

                do {
                    try self.moc.save()     // if this fails callers might make bad data assumptions
                } catch {
                    reply(nil, error)
                    return
                }

                if !keys.isEmpty {
                    let (unknownVersion, _) = keys.first!
                    reply(nil, ContainerError.unknownPolicyVersion(unknownVersion.uint64Value))
                    return
                }

                reply(docs, nil)
            }
        }
    }

    // Must be on moc queue to call this.
    // Caller is responsible for saving the moc afterwards.
    @discardableResult
    private func registerPeerMO(permanentInfo: TPPeerPermanentInfo,
                                stableInfo: TPPeerStableInfo? = nil,
                                dynamicInfo: TPPeerDynamicInfo? = nil,
                                vouchers: [TPVoucher]? = nil,
                                isEgoPeer: Bool = false) throws -> PeerMO {
        let peerID = permanentInfo.peerID

        let peer = PeerMO(context: self.moc)
        peer.peerID = peerID
        peer.permanentInfo = permanentInfo.data
        peer.permanentInfoSig = permanentInfo.sig
        peer.stableInfo = stableInfo?.data
        peer.stableInfoSig = stableInfo?.sig
        peer.dynamicInfo = dynamicInfo?.data
        peer.dynamicInfoSig = dynamicInfo?.sig
        peer.isEgoPeer = isEgoPeer
        self.containerMO.addToPeers(peer)

        self.model.registerPeer(with: permanentInfo)
        if let stableInfo = stableInfo {
            try self.model.update(stableInfo, forPeerWithID: peerID)
        }
        if let dynamicInfo = dynamicInfo {
            try self.model.update(dynamicInfo, forPeerWithID: peerID)
        }
        vouchers?.forEach { voucher in
            self.model.register(voucher)
            let voucherMO = VoucherMO(context: self.moc)
            voucherMO.voucherInfo = voucher.data
            voucherMO.voucherInfoSig = voucher.sig
            peer.addToVouchers(voucherMO)
        }
        return peer
    }

    /* Returns any new CKKS keys that need uploading, as well as any TLKShares necessary for those keys */
    func makeSharesForNewKeySets(ckksKeys: [CKKSKeychainBackedKeySet],
                                tlkShares: [CKKSTLKShare],
                                egoPeerKeys: OctagonSelfPeerKeys,
                                egoPeerDynamicInfo: TPPeerDynamicInfo,
                                epoch: Int) throws -> ([ViewKeys], [TLKShare]) {
        let newCKKSKeys = ckksKeys.filter { $0.newUpload }
        let newViewKeys: [ViewKeys] = newCKKSKeys.map(ViewKeys.convert)

        let octagonSelfShares = try makeTLKShares(ckksTLKs: ckksKeys.map { $0.tlk },
                                                  asPeer: egoPeerKeys,
                                                  toPeer: egoPeerKeys,
                                                  epoch: epoch)
        let extraShares = tlkShares.map { TLKShare.convert(ckksTLKShare: $0) }

        var peerShares: [TLKShare] = []

        for keyset in newCKKSKeys {
            do {
                let peerIDsWithAccess = try self.model.getPeerIDsTrustedByPeer(with: egoPeerDynamicInfo,
                                                                               toAccessView: keyset.tlk.zoneID.zoneName)
                os_log("Planning to share %@ with peers %@", log: tplogDebug, type: .default, String(describing: keyset.tlk), peerIDsWithAccess)

                let peers = peerIDsWithAccess.compactMap { self.model.peer(withID: $0) }
                let viewPeerShares = try peers.map { receivingPeer in
                    TLKShare.convert(ckksTLKShare: try CKKSTLKShare(keyset.tlk,
                                                                    as: egoPeerKeys,
                                                                    to: receivingPeer.permanentInfo,
                                                                    epoch: epoch,
                                                                    poisoned: 0))
                }

                peerShares = peerShares + viewPeerShares

            } catch {
                os_log("Unable to create TLKShares for keyset %@: %@", log: tplogDebug, type: .default, String(describing: keyset), error as CVarArg)
            }
        }

        return (newViewKeys, octagonSelfShares + peerShares + extraShares)
    }

    func onqueuePreparePeerForJoining(egoPeerID: String,
                                      peerPermanentInfo: TPPeerPermanentInfo,
                                      stableInfo: TPPeerStableInfo,
                                      sponsorID: String?,
                                      preapprovedKeys: [Data]?,
                                      vouchers: [SignedVoucher],
                                      egoPeerKeys: OctagonSelfPeerKeys) throws -> (Peer, TPPeerDynamicInfo) {
        let dynamicInfo = try self.model.dynamicInfo(forJoiningPeerID: egoPeerID,
                                                     peerPermanentInfo: peerPermanentInfo,
                                                     peerStableInfo: stableInfo,
                                                     sponsorID: sponsorID,
                                                     preapprovedKeys: preapprovedKeys,
                                                     signing: egoPeerKeys.signingKey,
                                                     currentMachineIDs: self.onqueueCurrentMIDList())

        let newStableInfo = try self.createNewStableInfoIfNeeded(stableChanges: nil,
                                                                 egoPeerID: egoPeerID,
                                                                 dynamicInfo: dynamicInfo,
                                                                 signingKeyPair: egoPeerKeys.signingKey)

        let peer = Peer.with {
            $0.peerID = egoPeerID
            $0.permanentInfoAndSig = SignedPeerPermanentInfo(peerPermanentInfo)
            $0.stableInfoAndSig = SignedPeerStableInfo(newStableInfo ?? stableInfo)
            $0.dynamicInfoAndSig = SignedPeerDynamicInfo(dynamicInfo)
            $0.vouchers = vouchers
        }

        return (peer, dynamicInfo)
    }

    func join(voucherData: Data,
              voucherSig: Data,
              ckksKeys: [CKKSKeychainBackedKeySet],
              tlkShares: [CKKSTLKShare],
              preapprovedKeys: [Data]?,
              reply: @escaping (String?, [CKRecord], Error?) -> Void) {
        self.semaphore.wait()
        let reply: (String?, [CKRecord], Error?) -> Void = {
            os_log("join complete: %@", log: tplogTrace, type: .info, traceError($2))
            self.semaphore.signal()
            reply($0, $1, $2)
        }

        self.fetchAndPersistChanges { error in
            guard error == nil else {
                reply(nil, [], error)
                return
            }
            self.moc.performAndWait {
                guard let voucher = TPVoucher(infoWith: voucherData, sig: voucherSig) else {
                    reply(nil, [], ContainerError.invalidVoucherOrSig)
                    return
                }
                guard let sponsor = self.model.peer(withID: voucher.sponsorID) else {
                    reply(nil, [], ContainerError.sponsorNotRegistered(voucher.sponsorID))
                    return
                }

                // Fetch ego peer identity from local storage.
                guard let egoPeerID = self.containerMO.egoPeerID,
                    let egoPermData = self.containerMO.egoPeerPermanentInfo,
                    let egoPermSig = self.containerMO.egoPeerPermanentInfoSig,
                    let egoStableData = self.containerMO.egoPeerStableInfo,
                    let egoStableSig = self.containerMO.egoPeerStableInfoSig
                    else {
                        reply(nil, [], ContainerError.noPreparedIdentity)
                        return
                }

                let keyFactory = TPECPublicKeyFactory()
                guard let selfPermanentInfo = TPPeerPermanentInfo(peerID: egoPeerID, data: egoPermData, sig: egoPermSig, keyFactory: keyFactory) else {
                    reply(nil, [], ContainerError.invalidPermanentInfoOrSig)
                    return
                }
                guard let selfStableInfo = TPPeerStableInfo(data: egoStableData, sig: egoStableSig) else {
                    reply(nil, [], ContainerError.invalidStableInfoOrSig)
                    return
                }
                guard self.onqueueMachineIDAllowedByIDMS(machineID: selfPermanentInfo.machineID) else {
                    os_log("join: self machineID %@ not on list", log: tplogDebug, type: .debug, selfPermanentInfo.machineID)
                    self.onqueueTTRUntrusted()
                    reply(nil, [], ContainerError.preparedIdentityNotOnAllowedList(selfPermanentInfo.machineID))
                    return
                }

                loadEgoKeys(peerID: egoPeerID) { egoPeerKeys, error in
                    guard let egoPeerKeys = egoPeerKeys else {
                        os_log("Don't have my own peer keys; can't join: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "error missing")
                        reply(nil, [], error)
                        return
                    }
                    self.moc.performAndWait {
                        let peer: Peer
                        let newDynamicInfo: TPPeerDynamicInfo
                        do {
                            (peer, newDynamicInfo) = try self.onqueuePreparePeerForJoining(egoPeerID: egoPeerID,
                                                                                           peerPermanentInfo: selfPermanentInfo,
                                                                                           stableInfo: selfStableInfo,
                                                                                           sponsorID: sponsor.peerID,
                                                                                           preapprovedKeys: preapprovedKeys,
                                                                                           vouchers: [SignedVoucher.with {
                                                                                               $0.voucher = voucher.data
                                                                                               $0.sig = voucher.sig
                                                                                               }, ],
                                                                                           egoPeerKeys: egoPeerKeys)
                        } catch {
                            os_log("Unable to create peer for joining: %@", log: tplogDebug, type: .default, error as CVarArg)
                            reply(nil, [], error)
                            return
                        }

                        let allTLKShares: [TLKShare]
                        let viewKeys: [ViewKeys]
                        do {
                            (viewKeys, allTLKShares) = try self.makeSharesForNewKeySets(ckksKeys: ckksKeys,
                                                                                        tlkShares: tlkShares,
                                                                                        egoPeerKeys: egoPeerKeys,
                                                                                        egoPeerDynamicInfo: newDynamicInfo,
                                                                                        epoch: Int(selfPermanentInfo.epoch))
                        } catch {
                            os_log("Unable to process keys before joining: %@", log: tplogDebug, type: .default, error as CVarArg)
                            reply(nil, [], error)
                            return
                        }

                        do {
                            try self.model.checkIntroduction(forCandidate: selfPermanentInfo,
                                                             stableInfo: peer.stableInfoAndSig.toStableInfo(),
                                                             withSponsorID: sponsor.peerID)
                        } catch {
                            os_log("Error checking introduction: %@", log: tplogDebug, type: .default, error as CVarArg)
                            reply(nil, [], error)
                            return
                        }

                        var bottle: Bottle
                        do {
                            bottle = try self.assembleBottle(egoPeerID: egoPeerID)
                        } catch {
                            reply(nil, [], error)
                            return
                        }

                        os_log("Beginning join for peer %@", log: tplogDebug, type: .default, egoPeerID)
                        os_log("Join permanentInfo: %@", log: tplogDebug, type: .debug, egoPermData.base64EncodedString())
                        os_log("Join permanentInfoSig: %@", log: tplogDebug, type: .debug, egoPermSig.base64EncodedString())
                        os_log("Join stableInfo: %@", log: tplogDebug, type: .debug, peer.stableInfoAndSig.peerStableInfo.base64EncodedString())
                        os_log("Join stableInfoSig: %@", log: tplogDebug, type: .debug, peer.stableInfoAndSig.sig.base64EncodedString())
                        os_log("Join dynamicInfo: %@", log: tplogDebug, type: .debug, peer.dynamicInfoAndSig.peerDynamicInfo.base64EncodedString())
                        os_log("Join dynamicInfoSig: %@", log: tplogDebug, type: .debug, peer.dynamicInfoAndSig.sig.base64EncodedString())

                        os_log("Join vouchers: %@", log: tplogDebug, type: .debug, peer.vouchers.map { $0.voucher.base64EncodedString() })
                        os_log("Join voucher signatures: %@", log: tplogDebug, type: .debug, peer.vouchers.map { $0.sig.base64EncodedString() })

                        os_log("Uploading %d tlk shares", log: tplogDebug, type: .default, allTLKShares.count)

                        do {
                            os_log("Join peer: %@", log: tplogDebug, type: .debug, try peer.serializedData().base64EncodedString())
                        } catch {
                            os_log("Join unable to encode peer: %@", log: tplogDebug, type: .debug, error as CVarArg)
                        }

                        let changeToken = self.containerMO.changeToken ?? ""
                        let request = JoinWithVoucherRequest.with {
                            $0.changeToken = changeToken
                            $0.peer = peer
                            $0.bottle = bottle
                            $0.tlkShares = allTLKShares
                            $0.viewKeys = viewKeys
                        }
                        self.cuttlefish.joinWithVoucher(request) { response, error in
                            os_log("JoinWithVoucher(%@): %@, error: %@", log: tplogDebug, "\(String(describing: request))", "\(String(describing: response))", "\(String(describing: error))")
                            guard let response = response, error == nil else {
                                os_log("joinWithVoucher failed: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                                reply(nil, [], error ?? ContainerError.cloudkitResponseMissing)
                                return
                            }

                            self.moc.performAndWait {
                                do {
                                    self.containerMO.egoPeerStableInfo = peer.stableInfoAndSig.peerStableInfo
                                    self.containerMO.egoPeerStableInfoSig = peer.stableInfoAndSig.sig
                                    try self.onQueuePersist(changes: response.changes)
                                    os_log("JoinWithVoucher succeeded", log: tplogDebug)

                                    let keyHierarchyRecords = response.zoneKeyHierarchyRecords.compactMap { CKRecord($0) }
                                    reply(egoPeerID, keyHierarchyRecords, nil)
                                } catch {
                                    os_log("JoinWithVoucher failed: %@", log: tplogDebug, String(describing: error))
                                    reply(nil, [], error)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func requestHealthCheck(requiresEscrowCheck: Bool, reply: @escaping (Bool, Bool, Bool, Error?) -> Void) {
        self.semaphore.wait()
        let reply: (Bool, Bool, Bool, Error?) -> Void = {
            os_log("health check complete: %@", log: tplogTrace, type: .info, traceError($3))
            self.semaphore.signal()
            reply($0, $1, $2, $3)
        }

        os_log("requestHealthCheck requiring escrow check: %d", log: tplogDebug, type: .default, requiresEscrowCheck)

        self.moc.performAndWait {
            guard let egoPeerID = self.containerMO.egoPeerID else {
                // No identity, nothing to do
                os_log("requestHealthCheck: No identity.", log: tplogDebug, type: .default)
                reply(false, false, false, ContainerError.noPreparedIdentity)
                return
            }
            let request = GetRepairActionRequest.with {
                $0.peerID = egoPeerID
                $0.requiresEscrowCheck = requiresEscrowCheck
            }

            self.cuttlefish.getRepairAction(request) { response, error in
                guard error == nil else {
                    reply(false, false, false, error)
                    return
                }
                guard let action = response?.repairAction else {
                    os_log("repair response is empty, returning false: %@", log: tplogDebug, type: .default)
                    reply(false, false, false, nil)
                    return
                }
                var postRepairAccount: Bool = false
                var postRepairEscrow: Bool = false
                var resetOctagon: Bool = false

                switch action {
                case .noAction:
                    break
                case .postRepairAccount:
                    postRepairAccount = true
                    break
                case .postRepairEscrow:
                    postRepairEscrow = true
                    break
                case .resetOctagon:
                    resetOctagon = true
                    break
                case .UNRECOGNIZED:
                    break
                }
                reply(postRepairAccount, postRepairEscrow, resetOctagon, nil)
            }
        }
    }

    func getSupportAppInfo(reply: @escaping (Data?, Error?) -> Void) {
        self.semaphore.wait()
        let reply: (Data?, Error?) -> Void = {
            os_log("getSupportAppInfo complete: %@", log: tplogTrace, type: .info, traceError($1))
            self.semaphore.signal()
            reply($0, $1)
        }

        self.cuttlefish.getSupportAppInfo { response, error in
            os_log("getSupportAppInfo(): %@, error: %@", log: tplogDebug,
                   "(\(String(describing: response))", "\(String(describing: error))")
            guard let response = response, error == nil else {
                os_log("getSupportAppInfo failed: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                reply(nil, error ?? ContainerError.cloudkitResponseMissing)
                return
            }

            guard let data = try? response.serializedData() else {
                reply(nil, ContainerError.failedToSerializeData)
                return
            }

            reply(data, nil)
        }

    }

    func preflightPreapprovedJoin(reply: @escaping (Bool, Error?) -> Void) {
        self.semaphore.wait()
        let reply: (Bool, Error?) -> Void = {
            os_log("preflightPreapprovedJoin complete: %@", log: tplogTrace, type: .info, traceError($1))
            self.semaphore.signal()
            reply($0, $1)
        }

        self.fetchAndPersistChanges { error in
            guard error == nil else {
                os_log("preflightPreapprovedJoin unable to fetch changes: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "")
                reply(false, error)
                return
            }

            // We explicitly ignore the machine ID list here; we're only interested in the peer states: do they preapprove us?

            guard !self.model.allPeerIDs().isEmpty else {
                // If, after fetch and handle changes, there's no peers, then we can likely establish.
                reply(true, nil)
                return
            }

            guard let egoPeerID = self.containerMO.egoPeerID,
                let egoPermData = self.containerMO.egoPeerPermanentInfo,
                let egoPermSig = self.containerMO.egoPeerPermanentInfoSig
                else {
                    os_log("preflightPreapprovedJoin: no prepared identity", log: tplogDebug, type: .debug)
                    reply(false, ContainerError.noPreparedIdentity)
                    return
            }

            let keyFactory = TPECPublicKeyFactory()
            guard let egoPermanentInfo = TPPeerPermanentInfo(peerID: egoPeerID, data: egoPermData, sig: egoPermSig, keyFactory: keyFactory) else {
                os_log("preflightPreapprovedJoin: invalid permanent info", log: tplogDebug, type: .debug)
                reply(false, ContainerError.invalidPermanentInfoOrSig)
                return
            }

            guard self.model.hasPotentiallyTrustedPeerPreapprovingKey(egoPermanentInfo.signingPubKey.spki()) else {
                os_log("preflightPreapprovedJoin: no peers preapprove our key", log: tplogDebug, type: .debug)
                reply(false, ContainerError.noPeersPreapprovePreparedIdentity)
                return
            }

            reply(true, nil)
        }
    }

    func preapprovedJoin(ckksKeys: [CKKSKeychainBackedKeySet],
                         tlkShares: [CKKSTLKShare],
                         preapprovedKeys: [Data]?,
                         reply: @escaping (String?, [CKRecord], Error?) -> Void) {
        self.semaphore.wait()
        let reply: (String?, [CKRecord], Error?) -> Void = {
            os_log("preapprovedJoin complete: %@", log: tplogTrace, type: .info, traceError($2))
            self.semaphore.signal()
            reply($0, $1, $2)
        }

        self.fetchAndPersistChangesIfNeeded { error in
            guard error == nil else {
                os_log("preapprovedJoin unable to fetch changes: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "")
                reply(nil, [], error)
                return
            }
            self.moc.performAndWait {
                // If, after fetch and handle changes, there's no peers, then fire off an establish
                // Note that if the establish fails, retrying this call might work.
                // That's up to the caller.
                if self.model.allPeerIDs().isEmpty {
                    os_log("preapprovedJoin but no existing peers, attempting establish", log: tplogDebug, type: .debug)
                    self.onqueueEstablish(ckksKeys: ckksKeys,
                        tlkShares: tlkShares,
                        preapprovedKeys: preapprovedKeys,
                        reply: reply)
                    return
                }

                // Fetch ego peer identity from local storage.
                guard let egoPeerID = self.containerMO.egoPeerID,
                    let egoPermData = self.containerMO.egoPeerPermanentInfo,
                    let egoPermSig = self.containerMO.egoPeerPermanentInfoSig,
                    let egoStableData = self.containerMO.egoPeerStableInfo,
                    let egoStableSig = self.containerMO.egoPeerStableInfoSig
                    else {
                        os_log("preapprovedJoin: no prepared identity", log: tplogDebug, type: .debug)
                        reply(nil, [], ContainerError.noPreparedIdentity)
                        return
                }

                let keyFactory = TPECPublicKeyFactory()
                guard let selfPermanentInfo = TPPeerPermanentInfo(peerID: egoPeerID, data: egoPermData, sig: egoPermSig, keyFactory: keyFactory) else {
                    reply(nil, [], ContainerError.invalidPermanentInfoOrSig)
                    return
                }
                guard let selfStableInfo = TPPeerStableInfo(data: egoStableData, sig: egoStableSig) else {
                    reply(nil, [], ContainerError.invalidStableInfoOrSig)
                    return
                }

                guard self.onqueueMachineIDAllowedByIDMS(machineID: selfPermanentInfo.machineID) else {
                    os_log("preapprovedJoin: self machineID %@ (me) not on list", log: tplogDebug, type: .debug, selfPermanentInfo.machineID)
                    self.onqueueTTRUntrusted()
                    reply(nil, [], ContainerError.preparedIdentityNotOnAllowedList(selfPermanentInfo.machineID))
                    return
                }
                loadEgoKeys(peerID: egoPeerID) { egoPeerKeys, error in
                    guard let egoPeerKeys = egoPeerKeys else {
                        os_log("preapprovedJoin: Don't have my own keys: can't join", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                        reply(nil, [], error)
                        return
                    }

                    guard self.model.hasPotentiallyTrustedPeerPreapprovingKey(egoPeerKeys.signingKey.publicKey().spki()) else {
                        os_log("preapprovedJoin: no peers preapprove our key", log: tplogDebug, type: .debug)
                        reply(nil, [], ContainerError.noPeersPreapprovePreparedIdentity)
                        return
                    }

                    self.moc.performAndWait {

                        let peer: Peer
                        let newDynamicInfo: TPPeerDynamicInfo
                        do {
                            (peer, newDynamicInfo) = try self.onqueuePreparePeerForJoining(egoPeerID: egoPeerID,
                                                                                           peerPermanentInfo: selfPermanentInfo,
                                                                                           stableInfo: selfStableInfo,
                                                                                           sponsorID: nil,
                                                                                           preapprovedKeys: preapprovedKeys,
                                                                                           vouchers: [],
                                                                                           egoPeerKeys: egoPeerKeys)
                        } catch {
                            os_log("Unable to create peer for joining: %@", log: tplogDebug, type: .default, error as CVarArg)
                            reply(nil, [], error)
                            return
                        }

                        let allTLKShares: [TLKShare]
                        let viewKeys: [ViewKeys]
                        do {
                            (viewKeys, allTLKShares) = try self.makeSharesForNewKeySets(ckksKeys: ckksKeys,
                                                                                   tlkShares: tlkShares,
                                                                                   egoPeerKeys: egoPeerKeys,
                                                                                   egoPeerDynamicInfo: newDynamicInfo,
                                                                                   epoch: Int(selfPermanentInfo.epoch))
                        } catch {
                            os_log("Unable to process keys before joining: %@", log: tplogDebug, type: .default, error as CVarArg)
                            reply(nil, [], error)
                            return
                        }

                        var bottle: Bottle
                        do {
                            bottle = try self.assembleBottle(egoPeerID: egoPeerID)
                        } catch {
                            reply(nil, [], error)
                            return
                        }

                        os_log("Beginning preapprovedJoin for peer %@", log: tplogDebug, type: .default, egoPeerID)
                        os_log("preapprovedJoin permanentInfo: %@", log: tplogDebug, type: .debug, egoPermData.base64EncodedString())
                        os_log("preapprovedJoin permanentInfoSig: %@", log: tplogDebug, type: .debug, egoPermSig.base64EncodedString())
                        os_log("preapprovedJoin stableInfo: %@", log: tplogDebug, type: .debug, egoStableData.base64EncodedString())
                        os_log("preapprovedJoin stableInfoSig: %@", log: tplogDebug, type: .debug, egoStableSig.base64EncodedString())
                        os_log("preapprovedJoin dynamicInfo: %@", log: tplogDebug, type: .debug, peer.dynamicInfoAndSig.peerDynamicInfo.base64EncodedString())
                        os_log("preapprovedJoin dynamicInfoSig: %@", log: tplogDebug, type: .debug, peer.dynamicInfoAndSig.sig.base64EncodedString())

                        os_log("preapprovedJoin vouchers: %@", log: tplogDebug, type: .debug, peer.vouchers.map { $0.voucher.base64EncodedString() })
                        os_log("preapprovedJoin voucher signatures: %@", log: tplogDebug, type: .debug, peer.vouchers.map { $0.sig.base64EncodedString() })

                        os_log("preapprovedJoin: uploading %d tlk shares", log: tplogDebug, type: .default, allTLKShares.count)

                        do {
                            os_log("preapprovedJoin peer: %@", log: tplogDebug, type: .debug, try peer.serializedData().base64EncodedString())
                        } catch {
                            os_log("preapprovedJoin unable to encode peer: %@", log: tplogDebug, type: .debug, error as CVarArg)
                        }

                        let changeToken = self.containerMO.changeToken ?? ""
                        let request = JoinWithVoucherRequest.with {
                            $0.changeToken = changeToken
                            $0.peer = peer
                            $0.bottle = bottle
                            $0.tlkShares = allTLKShares
                            $0.viewKeys = viewKeys
                        }
                        self.cuttlefish.joinWithVoucher(request) { response, error in
                            os_log("preapprovedJoin(%@): %@, error: %@", log: tplogDebug, "\(String(describing: request))", "\(String(describing: response))", "\(String(describing: error))")
                            guard let response = response, error == nil else {
                                os_log("preapprovedJoin failed: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                                reply(nil, [], error ?? ContainerError.cloudkitResponseMissing)
                                return
                            }

                            self.moc.performAndWait {
                                do {
                                    self.containerMO.egoPeerStableInfo = peer.stableInfoAndSig.peerStableInfo
                                    self.containerMO.egoPeerStableInfoSig = peer.stableInfoAndSig.sig
                                    try self.onQueuePersist(changes: response.changes)
                                    os_log("preapprovedJoin succeeded", log: tplogDebug)

                                    let keyHierarchyRecords = response.zoneKeyHierarchyRecords.compactMap { CKRecord($0) }
                                    reply(egoPeerID, keyHierarchyRecords, nil)
                                } catch {
                                    os_log("preapprovedJoin failed: %@", log: tplogDebug, String(describing: error))
                                    reply(nil, [], error)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func update(deviceName: String?,
                serialNumber: String?,
                osVersion: String?,
                policyVersion: UInt64?,
                policySecrets: [String: Data]?,
                reply: @escaping (TrustedPeersHelperPeerState?, Error?) -> Void) {
        self.semaphore.wait()
        let reply: (TrustedPeersHelperPeerState?, Error?) -> Void = {
            os_log("update complete: %@", log: tplogTrace, type: .info, traceError($1))
            self.semaphore.signal()
            reply($0, $1)
        }

        // Get (and save) the latest from cuttlefish
        let stableChanges = StableChanges(deviceName: deviceName,
                                          serialNumber: serialNumber,
                                          osVersion: osVersion,
                                          policyVersion: policyVersion,
                                          policySecrets: policySecrets,
                                          recoverySigningPubKey: nil,
                                          recoveryEncryptionPubKey: nil)
        self.fetchChangesAndUpdateTrustIfNeeded(stableChanges: stableChanges, reply: reply)
    }

    func set(preapprovedKeys: [Data],
             reply: @escaping (Error?) -> Void) {
        self.semaphore.wait()
        let reply: (Error?) -> Void = {
            os_log("setPreapprovedKeys complete: %@", log: tplogTrace, type: .info, traceError($0))
            self.semaphore.signal()
            reply($0)
        }

        self.moc.performAndWait {
            os_log("setPreapprovedKeys: %@", log: tplogDebug, type: .default, preapprovedKeys)

            guard let egoPeerID = self.containerMO.egoPeerID else {
                // No identity, nothing to do
                os_log("setPreapprovedKeys: No identity.", log: tplogDebug, type: .default)
                reply(ContainerError.noPreparedIdentity)
                return
            }
            loadEgoKeyPair(identifier: signingKeyIdentifier(peerID: egoPeerID)) { signingKeyPair, error in
                guard let signingKeyPair = signingKeyPair else {
                    os_log("setPreapprovedKeys: no signing key pair: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                    reply(error ?? ContainerError.unableToCreateKeyPair)
                    return
                }

                self.moc.performAndWait {
                    let dynamicInfo: TPPeerDynamicInfo
                    do {
                        dynamicInfo = try self.model.calculateDynamicInfoForPeer(withID: egoPeerID,
                                                                                 addingPeerIDs: nil,
                                                                                 removingPeerIDs: nil,
                                                                                 preapprovedKeys: preapprovedKeys,
                                                                                 signing: signingKeyPair,
                                                                                 currentMachineIDs: self.onqueueCurrentMIDList())
                    } catch {
                        os_log("setPreapprovedKeys: couldn't calculate dynamic info: %@", log: tplogDebug, type: .default, error as CVarArg)
                        reply(error)
                        return
                    }

                    os_log("setPreapprovedKeys: produced a dynamicInfo: %@", log: tplogDebug, type: .default, dynamicInfo)

                    if dynamicInfo == self.model.peer(withID: egoPeerID)?.dynamicInfo {
                        os_log("setPreapprovedKeys: no change; nothing to do.", log: tplogDebug, type: .default)
                        reply(nil)
                        return
                    }

                    os_log("setPreapprovedKeys: attempting updateTrust for %@ with: %@", log: tplogDebug, type: .default, egoPeerID, dynamicInfo)
                    let request = UpdateTrustRequest.with {
                        $0.changeToken = self.containerMO.changeToken ?? ""
                        $0.peerID = egoPeerID
                        $0.dynamicInfoAndSig = SignedPeerDynamicInfo(dynamicInfo)
                    }

                    self.cuttlefish.updateTrust(request) { response, error in
                        os_log("setPreapprovedKeys(%@): %@, error: %@", log: tplogDebug, "\(String(describing: request))", "\(String(describing: response))", "\(String(describing: error))")
                        guard let response = response, error == nil else {
                            os_log("setPreapprovedKeys failed: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                            reply(error ?? ContainerError.cloudkitResponseMissing)
                            return
                        }
                        os_log("setPreapprovedKeys: updateTrust suceeded", log: tplogDebug, type: .default)

                        do {
                            try self.persist(changes: response.changes)
                        } catch {
                            os_log("setPreapprovedKeys: could not persist changes: %@", log: tplogDebug, type: .default, error as CVarArg)
                            reply(error)
                            return
                        }

                        reply(nil)
                    }
                }
            }
        }
    }

    func updateTLKs(ckksKeys: [CKKSKeychainBackedKeySet],
                    tlkShares: [CKKSTLKShare],
                    reply: @escaping ([CKRecord]?, Error?) -> Void) {
        self.semaphore.wait()
        let reply: ([CKRecord]?, Error?) -> Void = {
            os_log("updateTLKs complete: %@", log: tplogTrace, type: .info, traceError($1))
            self.semaphore.signal()
            reply($0, $1)
        }

        os_log("Uploading some new TLKs: %@", log: tplogDebug, type: .default, ckksKeys)

        self.moc.performAndWait {
            guard let egoPeerID = self.containerMO.egoPeerID,
                let egoPermData = self.containerMO.egoPeerPermanentInfo,
                let egoPermSig = self.containerMO.egoPeerPermanentInfoSig
                else {
                    os_log("Have no self identity, can't make tlk shares", log: tplogDebug, type: .default)
                    reply(nil, ContainerError.noPreparedIdentity)
                    return
            }

            guard let selfPermanentInfo = TPPeerPermanentInfo(peerID: egoPeerID, data: egoPermData, sig: egoPermSig, keyFactory: TPECPublicKeyFactory()) else {
                os_log("Couldn't parse self identity", log: tplogDebug, type: .default, ckksKeys)
                reply(nil, ContainerError.invalidPermanentInfoOrSig)
                return
            }

            loadEgoKeys(peerID: egoPeerID) { egoPeerKeys, error in
                guard let egoPeerKeys = egoPeerKeys else {
                    os_log("Don't have my own peer keys; can't upload new TLKs: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "error missing")
                    reply(nil, error)
                    return
                }
                self.moc.performAndWait {
                    guard let egoPeerDynamicInfo = self.model.getDynamicInfoForPeer(withID: egoPeerID) else {
                        os_log("Unable to fetch dynamic info for self", log: tplogDebug, type: .default)
                        reply(nil, ContainerError.missingDynamicInfo)
                        return
                    }

                    let allTLKShares: [TLKShare]
                    let viewKeys: [ViewKeys]
                    do {
                        (viewKeys, allTLKShares) = try self.makeSharesForNewKeySets(ckksKeys: ckksKeys,
                                                                                    tlkShares: tlkShares,
                                                                                    egoPeerKeys: egoPeerKeys,
                                                                                    egoPeerDynamicInfo: egoPeerDynamicInfo,
                                                                                    epoch: Int(selfPermanentInfo.epoch))
                    } catch {
                        os_log("Unable to process keys before uploading: %@", log: tplogDebug, type: .default, error as CVarArg)
                        reply(nil, error)
                        return
                    }

                    let request = UpdateTrustRequest.with {
                        $0.changeToken = self.containerMO.changeToken ?? ""
                        $0.peerID = egoPeerID
                        $0.tlkShares = allTLKShares
                        $0.viewKeys = viewKeys
                    }

                    self.cuttlefish.updateTrust(request) { response, error in
                        os_log("UpdateTrust(%@): %@, error: %@", log: tplogDebug, "\(String(describing: request))", "\(String(describing: response))", "\(String(describing: error))")

                        guard error == nil else {
                            reply(nil, error)
                            return
                        }

                        let keyHierarchyRecords = response?.zoneKeyHierarchyRecords.compactMap { CKRecord($0) } ?? []
                        os_log("Recevied %d CKRecords back", log: tplogDebug, type: .default, keyHierarchyRecords.count)
                        reply(keyHierarchyRecords, nil)
                    }
                }
            }
        }
    }

    func getState(reply: @escaping (ContainerState) -> Void) {
        self.semaphore.wait()
        let reply: (ContainerState) -> Void = {
            os_log("getState complete: %@", log: tplogTrace, type: .info, $0.egoPeerID ?? "<NULL>")
            self.semaphore.signal()
            reply($0)
        }

        self.moc.performAndWait {
            var state = ContainerState()
            state.egoPeerID = self.containerMO.egoPeerID

            if self.containerMO.bottles != nil {
                self.containerMO.bottles!.forEach { bottle in
                    state.bottles.insert(bottle as! BottleMO)
                }
            }

            self.model.allPeers().forEach { peer in
                state.peers[peer.peerID] = peer
            }
            state.vouchers = Array(self.model.allVouchers())
            reply(state)
        }
    }

    // This will only fetch changes if no changes have ever been fetched before
    private func fetchAndPersistChangesIfNeeded(reply: @escaping (Error?) -> Void) {
        self.moc.performAndWait {
            if self.containerMO.changeToken == nil {
                self.onqueueFetchAndPersistChanges(reply: reply)
            } else {
                reply(nil)
            }
        }
    }

    private func fetchAndPersistChanges(reply: @escaping (Error?) -> Void) {
        self.moc.performAndWait {
            self.onqueueFetchAndPersistChanges(reply: reply)
        }
    }

    private func onqueueFetchAndPersistChanges(reply: @escaping (Error?) -> Void) {
        let request = FetchChangesRequest.with {
            $0.changeToken = self.containerMO.changeToken ?? ""
        }
        os_log("Fetching with change token: %@", log: tplogDebug, type: .default, request.changeToken.count > 0 ? request.changeToken : "empty")

        self.cuttlefish.fetchChanges(request) { response, error in
            os_log("FetchChanges(%@): %@, error: %@", log: tplogDebug, "\(String(describing: request))", "\(String(describing: response))", "\(String(describing: error))")
            guard let response = response, error == nil else {
                switch error {
                case CuttlefishErrorMatcher(code: CuttlefishErrorCode.changeTokenExpired):
                    os_log("change token is expired; resetting local CK storage", log: tplogDebug, type: .default)

                    self.moc.performAndWait {
                        do {
                            try self.deleteLocalCloudKitData()
                        } catch {
                            os_log("Failed to reset local data: %@", log: tplogDebug, type: .default, error as CVarArg)
                            reply(error)
                            return
                        }

                        self.fetchAndPersistChanges(reply: reply)
                    }

                    return
                default:
                    os_log("Fetch error is an unknown error: %@", log: tplogDebug, type: .default, String(describing: error))
                }

                os_log("Could not fetch changes: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                reply(error)
                return
            }

            do {
                try self.persist(changes: response.changes)
            } catch {
                os_log("Could not persist changes: %@", log: tplogDebug, type: .default, error as CVarArg)
                reply(error)
                return
            }

            if response.changes.more {
                os_log("persist: More changes indicated. Fetching...", log: tplogDebug, type: .default)
                self.fetchAndPersistChanges(reply: reply)
                return
            } else {
                os_log("persist: no more changes!", log: tplogDebug, type: .default)
                reply(nil)
            }
        }
    }

    //
    // Check for delta update in trust lists, that should lead to update of TLKShares
    //
    private func haveTrustMemberChanges(newDynamicInfo: TPPeerDynamicInfo, oldDynamicInfo: TPPeerDynamicInfo?) -> Bool {
        guard let oldDynamicInfo = oldDynamicInfo else {
            return true
        }
        if (newDynamicInfo.includedPeerIDs != oldDynamicInfo.includedPeerIDs) {
            return true
        }
        if (newDynamicInfo.excludedPeerIDs != oldDynamicInfo.excludedPeerIDs) {
            return true
        }
        if (newDynamicInfo.preapprovals != oldDynamicInfo.preapprovals) {
            return true
        }
        return false
    }

    // Fetch and persist changes from Cuttlefish. If this results
    // in us calculating a new dynamicInfo then give the new dynamicInfo
    // to Cuttlefish. If Cuttlefish returns more changes then persist
    // them locally, update dynamicInfo if needed, and keep doing that
    // until dynamicInfo is unchanged and there are no more changes to fetch.
    //
    // Must be holding the semaphore to call this, and it remains
    // the caller's responsibility to release it after it completes
    // (i.e. after reply is invoked).
    internal func fetchChangesAndUpdateTrustIfNeeded(stableChanges: StableChanges? = nil,
                                                    changesPending: Bool = false,
                                                    reply: @escaping (TrustedPeersHelperPeerState?, Error?) -> Void) {
        self.fetchAndPersistChanges { error in
            if let error = error {
                os_log("fetchChangesAndUpdateTrustIfNeeded: fetching failed: %@", log: tplogDebug, type: .default, error as CVarArg)
                reply(nil, error)
                return
            }

            self.updateTrustIfNeeded(stableChanges: stableChanges, changesPending: changesPending, reply: reply)
        }
    }

    // If this results in us calculating a new dynamicInfo then,
    // upload the new dynamicInfo
    // to Cuttlefish. If Cuttlefish returns more changes then persist
    // them locally, update dynamicInfo if needed, and keep doing that
    // until dynamicInfo is unchanged and there are no more changes to fetch.
    //
    // Must be holding the semaphore to call this, and it remains
    // the caller's responsibility to release it after it completes
    // (i.e. after reply is invoked).
    private func updateTrustIfNeeded(stableChanges: StableChanges? = nil,
                                     changesPending: Bool = false,
                                     reply: @escaping (TrustedPeersHelperPeerState?, Error?) -> Void) {
        self.moc.performAndWait {
            guard let egoPeerID = self.containerMO.egoPeerID else {
                // No identity, nothing to do
                os_log("updateTrustIfNeeded: No identity.", log: tplogDebug, type: .default)
                reply(TrustedPeersHelperPeerState(peerID: nil, isPreapproved: false, status: .unknown, memberChanges: changesPending, unknownMachineIDs: false, osVersion: nil), nil)
                return
            }
            loadEgoKeyPair(identifier: signingKeyIdentifier(peerID: egoPeerID)) { signingKeyPair, error in
                guard let signingKeyPair = signingKeyPair else {
                    os_log("updateTrustIfNeeded: no signing key pair: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                    reply(TrustedPeersHelperPeerState(peerID: nil, isPreapproved: false, status: .unknown, memberChanges: changesPending, unknownMachineIDs: false, osVersion: nil), error)
                    return
                }
                guard self.model.hasPeer(withID: egoPeerID) else {
                    // Not in circle, nothing to do
                    let isPreapproved = self.model.hasPotentiallyTrustedPeerPreapprovingKey(signingKeyPair.publicKey().spki())
                    os_log("updateTrustIfNeeded: ego peer is not in model, is %@", log: tplogDebug, type: .default, isPreapproved ? "preapproved" : "not yet preapproved")
                    reply(TrustedPeersHelperPeerState(peerID: egoPeerID,
                                                      isPreapproved: isPreapproved,
                                                      status: .unknown,
                                                      memberChanges: changesPending,
                                                      unknownMachineIDs: false,
                                                      osVersion: nil),
                          nil)
                    return
                }
                self.moc.performAndWait {
                    let dynamicInfo: TPPeerDynamicInfo
                    var stableInfo: TPPeerStableInfo?
                    do {
                        // FIXME We should be able to calculate the contents of dynamicInfo without the signingKeyPair,
                        // and then only load the key if it has changed and we need to sign a new one. This would also
                        // help make our detection of change immune from non-canonical serialization of dynamicInfo.
                        dynamicInfo = try self.model.calculateDynamicInfoForPeer(withID: egoPeerID,
                                                                                 addingPeerIDs: nil,
                                                                                 removingPeerIDs: nil,
                                                                                 preapprovedKeys: nil,
                                                                                 signing: signingKeyPair,
                                                                                 currentMachineIDs: self.onqueueCurrentMIDList())

                        stableInfo = try self.createNewStableInfoIfNeeded(stableChanges: stableChanges,
                                                                          egoPeerID: egoPeerID,
                                                                          dynamicInfo: dynamicInfo,
                                                                          signingKeyPair: signingKeyPair)
                    } catch {
                        os_log("updateTrustIfNeeded: couldn't calculate dynamic info: %@", log: tplogDebug, type: .default, error as CVarArg)
                        reply(TrustedPeersHelperPeerState(peerID: egoPeerID,
                                                          isPreapproved: false,
                                                          status: self.model.statusOfPeer(withID: egoPeerID),
                                                          memberChanges: changesPending,
                                                          unknownMachineIDs: false,
                                                          osVersion: nil),
                              error)
                        return
                    }

                    os_log("updateTrustIfNeeded: produced a stableInfo: %@", log: tplogDebug, type: .default, String(describing: stableInfo))
                    os_log("updateTrustIfNeeded: produced a dynamicInfo: %@", log: tplogDebug, type: .default, dynamicInfo)

                    let peer = self.model.peer(withID: egoPeerID)
                    if (stableInfo == nil || stableInfo == peer?.stableInfo) &&
                        dynamicInfo == peer?.dynamicInfo {
                        os_log("updateTrustIfNeeded: complete.", log: tplogDebug, type: .default)
                        // No change to the dynamicInfo: update the MID list now that we've reached a steady state
                        do {
                            self.onqueueUpdateMachineIDListFromModel(dynamicInfo: dynamicInfo)
                            try self.moc.save()
                        } catch {
                            os_log("updateTrustIfNeeded: unable to remove untrusted MachineIDs: %@", log: tplogDebug, type: .default, error as CVarArg)
                        }

                        reply(TrustedPeersHelperPeerState(peerID: egoPeerID,
                                                          isPreapproved: false,
                                                          status: self.model.statusOfPeer(withID: egoPeerID),
                                                          memberChanges: changesPending,
                                                          unknownMachineIDs: self.onqueueFullIDMSListWouldBeHelpful(),
                                                          osVersion: peer?.stableInfo?.osVersion),
                              nil)
                        return
                    }
                    // Check if we change that should trigger a notification that should trigger TLKShare updates
                    let haveChanges = changesPending || self.haveTrustMemberChanges(newDynamicInfo: dynamicInfo, oldDynamicInfo: peer?.dynamicInfo)

                    let signedDynamicInfo = SignedPeerDynamicInfo(dynamicInfo)
                    os_log("updateTrustIfNeeded: attempting updateTrust for %@ with: %@", log: tplogDebug, type: .default, egoPeerID, dynamicInfo)
                    var request = UpdateTrustRequest.with {
                        $0.changeToken = self.containerMO.changeToken ?? ""
                        $0.peerID = egoPeerID
                        $0.dynamicInfoAndSig = signedDynamicInfo
                    }
                    if let stableInfo = stableInfo {
                        request.stableInfoAndSig = SignedPeerStableInfo(stableInfo)
                    }
                    self.cuttlefish.updateTrust(request) { response, error in
                        os_log("UpdateTrust(%@): %@, error: %@", log: tplogDebug, "\(String(describing: request))", "\(String(describing: response))", "\(String(describing: error))")
                        guard let response = response, error == nil else {
                            os_log("UpdateTrust failed: %@", log: tplogDebug, type: .default, (error as CVarArg?) ?? "no error")
                            reply(nil, error ?? ContainerError.cloudkitResponseMissing)
                            return
                        }

                        do {
                            try self.persist(changes: response.changes)
                        } catch {
                            os_log("updateTrust failed: %@", log: tplogDebug, String(describing: error))
                            reply(nil, error)
                            return
                        }

                        if response.changes.more {
                            self.fetchChangesAndUpdateTrustIfNeeded(stableChanges: stableChanges,
                                                                    changesPending: haveChanges,
                                                                    reply: reply)
                        } else {
                            self.updateTrustIfNeeded(stableChanges: stableChanges,
                                                     changesPending: haveChanges,
                                                     reply: reply)
                        }
                    }
                }
            }
        }
    }

    private func persist(changes: Changes) throws {
        // This is some nonsense: I can't figure out how to tell swift to throw an exception across performAndWait.
        // So, do it ourself
        var outsideBlockError: Error?

        self.moc.performAndWait {
            os_log("persist: Received %d peer differences, more: %d", log: tplogDebug, type: .default,
                   changes.differences.count,
                   changes.more)
            os_log("persist: New change token: %@", log: tplogDebug, type: .default, changes.changeToken)

            do {
                try self.onQueuePersist(changes: changes)
            } catch {
                outsideBlockError = error
            }
        }

        if let outsideBlockError = outsideBlockError {
            throw outsideBlockError
        }
    }

    // Must be on moc queue to call this.
    // Changes are registered in the model and stored in moc.
    private func onQueuePersist(changes: Changes) throws {
        self.containerMO.changeToken = changes.changeToken
        self.containerMO.moreChanges = changes.more

        if changes.differences.count > 0 {
            self.model.clearViableBottles()
        }

        try changes.differences.forEach { peerDifference in
            if let operation = peerDifference.operation {
                switch operation {
                case .add(let peer):
                    try self.addOrUpdate(peer: peer)

                case .update(let peer):
                    try self.addOrUpdate(peer: peer)
                    // Update containerMO ego data if it has changed.
                    if peer.peerID == self.containerMO.egoPeerID {
                        guard let stableInfoAndSig: TPPeerStableInfo = peer.stableInfoAndSig.toStableInfo() else {
                            break
                        }
                        self.containerMO.egoPeerStableInfo = stableInfoAndSig.data
                        self.containerMO.egoPeerStableInfoSig = stableInfoAndSig.sig
                    }

                case .remove(let peer):
                    self.model.deletePeer(withID: peer.peerID)
                    if let peerMO = try self.fetchPeerMO(peerID: peer.peerID) {
                        self.moc.delete(peerMO)
                    }
                }
            }
        }

        let signingKey = changes.recoverySigningPubKey
        let encryptionKey = changes.recoveryEncryptionPubKey

        if signingKey.count > 0 && encryptionKey.count > 0 {
            self.addOrUpdate(signingKey: signingKey, encryptionKey: encryptionKey)
        }
        try self.moc.save()
    }

    // Must be on moc queue to call this
    // Deletes all things that should come back from CloudKit. Keeps the egoPeer data, though.
    private func deleteLocalCloudKitData() throws {
        os_log("Deleting all CloudKit data", log: tplogDebug, type: .default)

        do {
            let peerRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Peer")
            peerRequest.predicate = NSPredicate(format: "container == %@", self.containerMO)
            try self.moc.execute(NSBatchDeleteRequest(fetchRequest: peerRequest))

            let bottleRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bottle")
            bottleRequest.predicate = NSPredicate(format: "container == %@", self.containerMO)
            try self.moc.execute(NSBatchDeleteRequest(fetchRequest: bottleRequest))

            self.containerMO.peers = nil
            self.containerMO.bottles = nil
            self.containerMO.changeToken = nil
            self.containerMO.moreChanges = false

            self.model = Container.loadModel(from: self.containerMO)
            try self.moc.save()
        } catch {
            os_log("Local delete failed: %@", log: tplogDebug, type: .default, error as CVarArg)
            throw error
        }

        os_log("Saved model with %d peers", log: tplogDebug, type: .default, self.model.allPeerIDs().count)
    }

    // Must be on moc queue to call this.
    private func addOrUpdate(signingKey: Data, encryptionKey: Data) {
        self.model.setRecoveryKeys(
            TPRecoveryKeyPair(signingSPKI: signingKey, encryptionSPKI: encryptionKey))
    }

    // Must be on moc queue to call this.
    private func addOrUpdate(peer: Peer) throws {
        if !self.model.hasPeer(withID: peer.peerID) {
            // Add:
            guard let permanentInfo = peer.permanentInfoAndSig.toPermanentInfo(peerID: peer.peerID) else {
                // Ignoring bad peer
                return
            }
            let stableInfo = peer.stableInfoAndSig.toStableInfo()
            let dynamicInfo = peer.dynamicInfoAndSig.toDynamicInfo()
            let vouchers = peer.vouchers.compactMap {
                TPVoucher(infoWith: $0.voucher, sig: $0.sig)
            }
            let isEgoPeer = peer.peerID == self.containerMO.egoPeerID
            try self.registerPeerMO(permanentInfo: permanentInfo,
                                    stableInfo: stableInfo,
                                    dynamicInfo: dynamicInfo,
                                    vouchers: vouchers,
                                    isEgoPeer: isEgoPeer)
        } else {
            // Update:
            // The assertion here is that every peer registered in model is also present in containerMO
            let peerMO = try self.fetchPeerMO(peerID: peer.peerID)!

            if let stableInfo = peer.stableInfoAndSig.toStableInfo() {
                try self.model.update(stableInfo, forPeerWithID: peer.peerID)
                // Pull the stableInfo back out of the model, and persist that.
                // The model checks signatures and clocks to prevent replay attacks.
                let modelPeer = self.model.peer(withID: peer.peerID)
                peerMO.stableInfo = modelPeer?.stableInfo?.data
                peerMO.stableInfoSig = modelPeer?.stableInfo?.sig
            }
            if let dynamicInfo = peer.dynamicInfoAndSig.toDynamicInfo() {
                try self.model.update(dynamicInfo, forPeerWithID: peer.peerID)
                // Pull the dynamicInfo back out of the model, and persist that.
                // The model checks signatures and clocks to prevent replay attacks.
                let modelPeer = self.model.peer(withID: peer.peerID)
                peerMO.dynamicInfo = modelPeer?.dynamicInfo?.data
                peerMO.dynamicInfoSig = modelPeer?.dynamicInfo?.sig
            }
            peer.vouchers.forEach {
                if let voucher = TPVoucher(infoWith: $0.voucher, sig: $0.sig) {
                    self.model.register(voucher)
                    let voucherMO = VoucherMO(context: self.moc)
                    voucherMO.voucherInfo = voucher.data
                    voucherMO.voucherInfoSig = voucher.sig
                    peerMO.addToVouchers(voucherMO)
                }
            }
        }
    }

    // Must be on moc queue to call this.
    private func fetchPeerMO(peerID: String) throws -> PeerMO? {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Peer")
        fetch.predicate = NSPredicate(format: "peerID == %@ && container == %@", peerID, self.containerMO)
        let peers = try self.moc.fetch(fetch)
        return peers.first as? PeerMO
    }

    // Must be on moc queue to call this.
    private func getPolicyDoc(_ policyVersion: UInt64) throws -> TPPolicyDocument {
        guard let policyDoc = self.model.policy(withVersion: policyVersion) else {
            throw ContainerError.unknownPolicyVersion(policyVersion)
        }
        assert(policyVersion == policyDoc.policyVersion)
        if policyVersion == prevailingPolicyVersion {
            assert(policyDoc.policyHash == prevailingPolicyHash)
        }
        return policyDoc
    }

    // Must be on moc queue to call this.
    private func createNewStableInfoIfNeeded(stableChanges: StableChanges?,
                                             egoPeerID: String,
                                             dynamicInfo: TPPeerDynamicInfo,
                                             signingKeyPair: _SFECKeyPair) throws -> TPPeerStableInfo? {
        func noChange<T: Equatable>(_ change: T?, _ existing: T?) -> Bool {
            return (nil == change) || change == existing
        }
        let existingStableInfo = self.model.peer(withID: egoPeerID)?.stableInfo
        if noChange(stableChanges?.deviceName, existingStableInfo?.deviceName) &&
            noChange(stableChanges?.serialNumber, existingStableInfo?.serialNumber) &&
            noChange(stableChanges?.osVersion, existingStableInfo?.osVersion) &&
            noChange(stableChanges?.policyVersion, existingStableInfo?.policyVersion) &&
            noChange(stableChanges?.policySecrets, existingStableInfo?.policySecrets) &&
            noChange(stableChanges?.recoverySigningPubKey, existingStableInfo?.recoverySigningPublicKey) &&
            noChange(stableChanges?.recoveryEncryptionPubKey, existingStableInfo?.recoveryEncryptionPublicKey) &&
            self.model.doesPeerRecoveryKeyMatchPeers(egoPeerID) {
            return nil
        }
        let policyHash: String?
        if let policyVersion = stableChanges?.policyVersion {
            let policyDoc = try self.getPolicyDoc(policyVersion)
            policyHash = policyDoc.policyHash
        } else {
            policyHash = nil
        }

        // Determine which recovery key we'd like to be using, given our current idea of who to trust
        let newRecoveryKeys = self.model.bestRecoveryKey(with: dynamicInfo)

        return try self.model.createStableInfo(withPolicyVersion: stableChanges?.policyVersion ?? existingStableInfo?.policyVersion ?? prevailingPolicyVersion,
                                               policyHash: policyHash ?? existingStableInfo?.policyHash ?? prevailingPolicyHash,
                                               policySecrets: stableChanges?.policySecrets ?? existingStableInfo?.policySecrets,
                                               deviceName: stableChanges?.deviceName ?? existingStableInfo?.deviceName ?? "",
                                               serialNumber: stableChanges?.serialNumber ?? existingStableInfo?.serialNumber ?? "",
                                               osVersion: stableChanges?.osVersion ?? existingStableInfo?.osVersion ?? "",
                                               signing: signingKeyPair,
                                               recoverySigningPubKey: newRecoveryKeys?.signingSPKI ?? existingStableInfo?.recoverySigningPublicKey,
                                               recoveryEncryptionPubKey: newRecoveryKeys?.encryptionSPKI ?? existingStableInfo?.recoveryEncryptionPublicKey)
    }

    private func assembleBottle(egoPeerID: String) throws -> Bottle {
        let bottleMoSet = containerMO.bottles as? Set<BottleMO>

        var bottleMOs = bottleMoSet?.filter {
            $0.peerID == egoPeerID
        }

        if let count = bottleMOs?.count {
            if count > 1 {
                throw ContainerError.tooManyBottlesForPeer
            } else if count == 0 {
                throw ContainerError.noBottleForPeer
            }
        } else {
            throw ContainerError.failedToAssembleBottle
        }

        let BM: BottleMO? = (bottleMOs?.removeFirst())

        let bottle = try Bottle.with {
            $0.peerID = egoPeerID

            if let bottledPeerData = BM?.contents {
                $0.contents = bottledPeerData
            } else {
                throw ContainerError.failedToAssembleBottle
            }

            if let bottledPeerEscrowSigningSPKI = BM?.escrowedSigningSPKI {
                $0.escrowedSigningSpki = bottledPeerEscrowSigningSPKI
            } else {
                throw ContainerError.failedToAssembleBottle
            }

            if let bottledPeerSignatureUsingEscrowKey = BM?.signatureUsingEscrowKey {
                $0.signatureUsingEscrowKey = bottledPeerSignatureUsingEscrowKey
            } else {
                throw ContainerError.failedToAssembleBottle
            }

            if let bottledPeerSignatureUsingPeerKey = BM?.signatureUsingPeerKey {
                $0.signatureUsingPeerKey = bottledPeerSignatureUsingPeerKey
            } else {
                throw ContainerError.failedToAssembleBottle
            }

            if let bID = BM?.bottleID {
                $0.bottleID = bID
            } else {
                throw ContainerError.failedToAssembleBottle
            }
        }

        return bottle
    }

    func reportHealth(request: ReportHealthRequest, reply: @escaping (Error?) -> Void) {
        self.semaphore.wait()
        let reply: (Error?) -> Void = {
            os_log("reportHealth complete %@", log: tplogTrace, type: .info, traceError($0))
            self.semaphore.signal()
            reply($0)
        }

        var updatedRequest = request

        if let egoPeerID = self.containerMO.egoPeerID {
            loadEgoKeys(peerID: egoPeerID) { egoPeerKeys, _ in
                updatedRequest.octagonEgoIdentity = (egoPeerKeys != nil)
            }
        }

        self.moc.performAndWait {
            self.cuttlefish.reportHealth(updatedRequest) { response, error in
                os_log("reportHealth(%@): %@, error: %@", log: tplogDebug, "\(String(describing: request))", "\(String(describing: response))", "\(String(describing: error))")
                guard error == nil else {
                    reply(error)
                    return
                }
                reply(nil)
            }
        }
    }

    func pushHealthInquiry(reply: @escaping (Error?) -> Void) {
        self.semaphore.wait()
        let reply: (Error?) -> Void = {
            os_log("reportHealth complete %@", log: tplogTrace, type: .info, traceError($0))
            self.semaphore.signal()
            reply($0)
        }

        self.moc.performAndWait {
            self.cuttlefish.pushHealthInquiry(PushHealthInquiryRequest()) { response, error in
                os_log("pushHealthInquiry(): %@, error: %@", log: tplogDebug, "\(String(describing: response))", "\(String(describing: error))")
                guard error == nil else {
                    reply(error)
                    return
                }
                reply(nil)
            }
        }
    }
}
