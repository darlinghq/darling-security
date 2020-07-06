#if OCTAGON

class OctagonResetTests: OctagonTestsBase {
    func testAccountAvailableAndHandleExternalCall() throws {
        self.startCKAccountStatusMock()

        self.cuttlefishContext.startOctagonStateMachine()
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)

        _ = try self.cuttlefishContext.accountAvailable("13453464")

        self.cuttlefishContext.rpcResetAndEstablish(.testGenerated) { resetError in
            XCTAssertNil(resetError, "should be no error resetting and establishing")
        }

        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateReady, within: 10 * NSEC_PER_SEC)
        self.verifyDatabaseMocks()
    }

    func testExernalCallAndAccountAvailable() throws {
        self.startCKAccountStatusMock()

        self.cuttlefishContext.startOctagonStateMachine()
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)

        self.cuttlefishContext.rpcResetAndEstablish(.testGenerated) { resetError in
            XCTAssertNil(resetError, "should be no error resetting and establishing")
        }

        _ = try self.cuttlefishContext.accountAvailable("13453464")

        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateReady, within: 10 * NSEC_PER_SEC)
        self.verifyDatabaseMocks()
    }

    func testCallingAccountAvailableDuringResetAndEstablish() throws {
        self.startCKAccountStatusMock()

        self.cuttlefishContext.startOctagonStateMachine()
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)

        self.cuttlefishContext.rpcResetAndEstablish(.testGenerated) { resetError in
            XCTAssertNil(resetError, "should be no error resetting and establishing")
        }

        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateResetAndEstablish, within: 1 * NSEC_PER_SEC)

        _ = try self.cuttlefishContext.accountAvailable("13453464")

        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateReady, within: 10 * NSEC_PER_SEC)
        self.verifyDatabaseMocks()
    }

    func testResetAndEstablishWithEscrow() throws {
        let contextName = OTDefaultContext
        let containerName = OTCKContainerName

        self.startCKAccountStatusMock()

        // Before resetAndEstablish, there shouldn't be any stored account state
               XCTAssertThrowsError(try OTAccountMetadataClassC.loadFromKeychain(forContainer: containerName, contextID: contextName), "Before doing anything, loading a non-existent account state should fail")

        let resetAndEstablishExpectation = self.expectation(description: "resetAndEstablish callback occurs")
        let escrowRequestNotification = expectation(forNotification: OTMockEscrowRequestNotification,
                                                    object: nil,
                                                    handler: nil)
        self.manager.resetAndEstablish(containerName,
                                       context: contextName,
                                       altDSID: "new altDSID",
                                       resetReason: .testGenerated) { resetError in
                                        XCTAssertNil(resetError, "Should be no error calling resetAndEstablish")
                                        resetAndEstablishExpectation.fulfill()
        }

        self.wait(for: [resetAndEstablishExpectation], timeout: 10)
        self.wait(for: [escrowRequestNotification], timeout: 5)
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateReady, within: 10 * NSEC_PER_SEC)

        let selfPeerID = try self.cuttlefishContext.accountMetadataStore.loadOrCreateAccountMetadata().peerID

        // After resetAndEstablish, you should be able to see the persisted account state
        do {
            let accountState = try OTAccountMetadataClassC.loadFromKeychain(forContainer: containerName, contextID: contextName)
            XCTAssertEqual(selfPeerID, accountState.peerID, "Saved account state should have the same peer ID that prepare returned")
        } catch {
            XCTFail("error loading account state: \(error)")
        }
    }

    func testResetAndEstablishStopsCKKS() throws {
        let contextName = OTDefaultContext
        let containerName = OTCKContainerName

        self.startCKAccountStatusMock()

        self.cuttlefishContext.startOctagonStateMachine()
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)

        do {
            let clique = try OTClique.newFriends(withContextData: self.otcliqueContext, resetReason: .testGenerated)
            XCTAssertNotNil(clique, "Clique should not be nil")
        } catch {
            XCTFail("Shouldn't have errored making new friends: \(error)")
        }

        // Now, we should be in 'ready'
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateReady, within: 10 * NSEC_PER_SEC)
        self.assertConsidersSelfTrusted(context: self.cuttlefishContext)
        self.assertConsidersSelfTrustedCachedAccountStatus(context: self.cuttlefishContext)

        // and all subCKKSes should enter ready...
        assertAllCKKSViews(enter: SecCKKSZoneKeyStateReady, within: 10 * NSEC_PER_SEC)
        self.verifyDatabaseMocks()

        // CKKS should pass through "waitfortrust" during a reset
        let waitfortrusts = self.ckksViews.compactMap { view in
            (view as! CKKSKeychainView).keyHierarchyConditions[SecCKKSZoneKeyStateWaitForTrust] as? CKKSCondition
        }
        XCTAssert(waitfortrusts.count > 0, "Should have at least one waitfortrust condition")

        let resetAndEstablishExpectation = self.expectation(description: "resetAndEstablish callback occurs")
        let escrowRequestNotification = expectation(forNotification: OTMockEscrowRequestNotification,
                                                    object: nil,
                                                    handler: nil)
        self.manager.resetAndEstablish(containerName,
                                       context: contextName,
                                       altDSID: "new altDSID",
                                       resetReason: .testGenerated) { resetError in
                                        XCTAssertNil(resetError, "Should be no error calling resetAndEstablish")
                                        resetAndEstablishExpectation.fulfill()
        }

        self.wait(for: [resetAndEstablishExpectation], timeout: 10)
        self.wait(for: [escrowRequestNotification], timeout: 5)
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateReady, within: 10 * NSEC_PER_SEC)

        assertAllCKKSViews(enter: SecCKKSZoneKeyStateReady, within: 10 * NSEC_PER_SEC)

        // CKKS should have all gone into waitfortrust during that time
        for condition in waitfortrusts {
            XCTAssertEqual(0, condition.wait(10 * NSEC_PER_MSEC), "CKKS should have entered waitfortrust")
        }
    }

    func testOctagonResetAlsoResetsCKKSViewsMissingTLKs() {
        self.putFakeKeyHierarchy(inCloudKit: self.manateeZoneID)

        let zoneKeys = self.keys![self.manateeZoneID!] as? ZoneKeys
        XCTAssertNotNil(zoneKeys, "Should have some zone keys")
        XCTAssertNotNil(zoneKeys?.tlk, "Should have a tlk in the original key set")

        self.startCKAccountStatusMock()
        self.cuttlefishContext.startOctagonStateMachine()
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)
        assertAllCKKSViews(enter: SecCKKSZoneKeyStateWaitForTrust, within: 10 * NSEC_PER_SEC)

        self.silentZoneDeletesAllowed = true

        do {
            _ = try OTClique.newFriends(withContextData: self.otcliqueContext, resetReason: .testGenerated)
        } catch {
            XCTFail("failed to make new friends: \(error)")
        }

        assertAllCKKSViews(enter: SecCKKSZoneKeyStateReady, within: 10 * NSEC_PER_SEC)

        let laterZoneKeys = self.keys![self.manateeZoneID!] as? ZoneKeys
        XCTAssertNotNil(laterZoneKeys, "Should have some zone keys")
        XCTAssertNotNil(laterZoneKeys?.tlk, "Should have a tlk in the newly created keyset")
        XCTAssertNotEqual(zoneKeys?.tlk?.uuid, laterZoneKeys?.tlk?.uuid, "CKKS zone should now have different keys")
    }

    func testOctagonResetIgnoresOldRemoteDevicesWithKeysAndResetsCKKS() {
        // CKKS has no keys, and there's another device claiming to have them already, but it's old
        self.putFakeKeyHierarchy(inCloudKit: self.manateeZoneID)
        self.putFakeDeviceStatus(inCloudKit: self.manateeZoneID)

        (self.zones![self.manateeZoneID!]! as! FakeCKZone).currentDatabase.allValues.forEach { record in
            let r = record as! CKRecord
            if(r.recordType == SecCKRecordDeviceStateType) {
                r.creationDate = NSDate.distantPast
                r.modificationDate = NSDate.distantPast
            }
        }

        let zoneKeys = self.keys![self.manateeZoneID!] as? ZoneKeys
        XCTAssertNotNil(zoneKeys, "Should have some zone keys")
        XCTAssertNotNil(zoneKeys?.tlk, "Should have a tlk in the original key set")

        self.startCKAccountStatusMock()
        self.cuttlefishContext.startOctagonStateMachine()
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)

        self.silentZoneDeletesAllowed = true

        do {
            _ = try OTClique.newFriends(withContextData: self.otcliqueContext, resetReason: .testGenerated)
        } catch {
            XCTFail("failed to make new friends: \(error)")
        }

        assertAllCKKSViews(enter: SecCKKSZoneKeyStateReady, within: 10 * NSEC_PER_SEC)

        let laterZoneKeys = self.keys![self.manateeZoneID!] as? ZoneKeys
        XCTAssertNotNil(laterZoneKeys, "Should have some zone keys")
        XCTAssertNotNil(laterZoneKeys?.tlk, "Should have a tlk in the newly created keyset")
        XCTAssertNotEqual(zoneKeys?.tlk?.uuid, laterZoneKeys?.tlk?.uuid, "CKKS zone should now have different keys")
    }

    func testOctagonResetWithRemoteDevicesWithKeysDoesNotResetCKKS() {
        // CKKS has no keys, and there's another device claiming to have them already, so CKKS won't immediately reset it
        self.putFakeKeyHierarchy(inCloudKit: self.manateeZoneID)
        self.putFakeDeviceStatus(inCloudKit: self.manateeZoneID)

        let zoneKeys = self.keys![self.manateeZoneID!] as? ZoneKeys
        XCTAssertNotNil(zoneKeys, "Should have some zone keys")
        XCTAssertNotNil(zoneKeys?.tlk, "Should have a tlk in the original key set")

        self.startCKAccountStatusMock()
        self.cuttlefishContext.startOctagonStateMachine()
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)

        self.silentZoneDeletesAllowed = true

        do {
            _ = try OTClique.newFriends(withContextData: self.otcliqueContext, resetReason: .testGenerated)
        } catch {
            XCTFail("failed to make new friends: \(error)")
        }

        assertAllCKKSViews(enter: SecCKKSZoneKeyStateWaitForTLK, within: 10 * NSEC_PER_SEC)

        let laterZoneKeys = self.keys![self.manateeZoneID!] as? ZoneKeys
        XCTAssertNotNil(laterZoneKeys, "Should have some zone keys")
        XCTAssertNotNil(laterZoneKeys?.tlk, "Should have a tlk in the newly created keyset")
        XCTAssertEqual(zoneKeys?.tlk?.uuid, laterZoneKeys?.tlk?.uuid, "CKKS zone should now have the same keys")
    }

    func testOctagonResetWithTLKsDoesNotResetCKKS() {
        // CKKS has the keys keys
        self.putFakeKeyHierarchy(inCloudKit: self.manateeZoneID)
        self.saveTLKMaterial(toKeychain: self.manateeZoneID)

        let zoneKeys = self.keys![self.manateeZoneID!] as? ZoneKeys
        XCTAssertNotNil(zoneKeys, "Should have some zone keys")
        XCTAssertNotNil(zoneKeys?.tlk, "Should have a tlk in the original key set")

        self.startCKAccountStatusMock()
        self.cuttlefishContext.startOctagonStateMachine()
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)

        do {
            _ = try OTClique.newFriends(withContextData: self.otcliqueContext, resetReason: .testGenerated)
        } catch {
            XCTFail("failed to make new friends: \(error)")
        }
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateReady, within: 10 * NSEC_PER_SEC)

        assertAllCKKSViews(enter: SecCKKSZoneKeyStateReady, within: 10 * NSEC_PER_SEC)

        let laterZoneKeys = self.keys![self.manateeZoneID!] as? ZoneKeys
        XCTAssertNotNil(laterZoneKeys, "Should have some zone keys")
        XCTAssertNotNil(laterZoneKeys?.tlk, "Should have a tlk in the newly created keyset")
        XCTAssertEqual(zoneKeys?.tlk?.uuid, laterZoneKeys?.tlk?.uuid, "CKKS zone should now have the same keys")
    }

    func testOctagonResetAndEstablishFail() throws {
        // Make sure if establish fail we end up in untrusted instead of error
        self.startCKAccountStatusMock()

        self.cuttlefishContext.startOctagonStateMachine()
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)

        _ = try self.cuttlefishContext.accountAvailable("13453464")

        let establishExpectation = self.expectation(description: "establishExpectation")
        let resetExpectation = self.expectation(description: "resetExpectation")

        self.fakeCuttlefishServer.establishListener = {  [unowned self] request in
            self.fakeCuttlefishServer.establishListener = nil
            establishExpectation.fulfill()

            return FakeCuttlefishServer.makeCloudKitCuttlefishError(code: .establishFailed)
        }

        self.cuttlefishContext.rpcResetAndEstablish(.testGenerated) { resetError in
            resetExpectation.fulfill()
            XCTAssertNotNil(resetError, "should error resetting and establishing")
        }
        self.wait(for: [establishExpectation, resetExpectation], timeout: 10)

        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)
        self.verifyDatabaseMocks()
    }

    func testResetReasonUnknown() throws {
        self.startCKAccountStatusMock()

        self.cuttlefishContext.startOctagonStateMachine()
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)

        _ = try self.cuttlefishContext.accountAvailable("13453464")

        let resetExpectation = self.expectation(description: "resetExpectation")

        self.fakeCuttlefishServer.resetListener = {  request in
            self.fakeCuttlefishServer.resetListener = nil
            resetExpectation.fulfill()
            XCTAssertTrue(request.resetReason.rawValue == CuttlefishResetReason.unknown.rawValue, "reset reason should be unknown")
            return nil
        }

        let establishAndResetExpectation = self.expectation(description: "resetExpectation")
        self.cuttlefishContext.rpcResetAndEstablish(.unknown) { resetError in
            establishAndResetExpectation.fulfill()
            XCTAssertNil(resetError, "should not error resetting and establishing")
        }
        self.wait(for: [establishAndResetExpectation, resetExpectation], timeout: 10)

        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateReady, within: 10 * NSEC_PER_SEC)
        self.verifyDatabaseMocks()
    }

    func testResetReasonUserInitiatedReset() throws {
          // Make sure if establish fail we end up in untrusted instead of error
          self.startCKAccountStatusMock()

          self.cuttlefishContext.startOctagonStateMachine()
          self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)

          _ = try self.cuttlefishContext.accountAvailable("13453464")

        let resetExpectation = self.expectation(description: "resetExpectation")

        self.fakeCuttlefishServer.resetListener = {  request in
            self.fakeCuttlefishServer.resetListener = nil
            resetExpectation.fulfill()
            XCTAssertTrue(request.resetReason.rawValue == CuttlefishResetReason.userInitiatedReset.rawValue, "reset reason should be user initiated reset")
            return nil
        }

        let establishAndResetExpectation = self.expectation(description: "resetExpectation")
        let clique: OTClique
        let recoverykeyotcliqueContext = OTConfigurationContext()
        recoverykeyotcliqueContext.context = OTDefaultContext
        recoverykeyotcliqueContext.dsid = "13453464"
        recoverykeyotcliqueContext.altDSID = self.mockAuthKit.altDSID!
        recoverykeyotcliqueContext.otControl = self.otControl
        do {
            clique = try OTClique.newFriends(withContextData: recoverykeyotcliqueContext, resetReason: .userInitiatedReset)
            XCTAssertNotNil(clique, "Clique should not be nil")
            XCTAssertNotNil(clique.cliqueMemberIdentifier, "Should have a member identifier after a clique newFriends call")
            establishAndResetExpectation.fulfill()
        } catch {
            XCTFail("Shouldn't have errored making new friends: \(error)")
            throw error
        }
        self.wait(for: [establishAndResetExpectation, resetExpectation], timeout: 10)

        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateReady, within: 10 * NSEC_PER_SEC)
        self.verifyDatabaseMocks()
    }

    func testResetReasonRecoveryKey() throws {
        // Make sure if establish fail we end up in untrusted instead of error
        self.startCKAccountStatusMock()

        self.cuttlefishContext.startOctagonStateMachine()
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)

        _ = try self.cuttlefishContext.accountAvailable("13453464")

        let resetExpectation = self.expectation(description: "resetExpectation")

        self.fakeCuttlefishServer.resetListener = {  request in
            self.fakeCuttlefishServer.resetListener = nil
            resetExpectation.fulfill()
            XCTAssertTrue(request.resetReason.rawValue == CuttlefishResetReason.recoveryKey.rawValue, "reset reason should be recovery key")
            return nil
        }

        let recoveryKey = SecPasswordGenerate(SecPasswordType(kSecPasswordTypeiCloudRecoveryKey), nil, nil)! as String
        XCTAssertNotNil(recoveryKey, "recoveryKey should not be nil")

        let newCliqueContext = OTConfigurationContext()
        newCliqueContext.context = OTDefaultContext
        newCliqueContext.dsid = self.otcliqueContext.dsid
        newCliqueContext.altDSID = self.mockAuthKit.altDSID!
        newCliqueContext.otControl = self.otControl

        let joinWithRecoveryKeyExpectation = self.expectation(description: "joinWithRecoveryKeyExpectation callback occurs")
        TestsObjectiveC.recoverOctagon(usingData: newCliqueContext, recoveryKey: recoveryKey) { error in
            XCTAssertNil(error, "error should be nil")
            joinWithRecoveryKeyExpectation.fulfill()
        }
        self.wait(for: [joinWithRecoveryKeyExpectation], timeout: 10)
        self.wait(for: [resetExpectation], timeout: 10)

        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateReady, within: 10 * NSEC_PER_SEC)
        self.verifyDatabaseMocks()
    }

    func testResetReasonNoValidBottle() throws {
        self.startCKAccountStatusMock()

        self.cuttlefishContext.startOctagonStateMachine()
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)

        let initiatorContext = self.manager.context(forContainerName: OTCKContainerName,
                                                    contextID: "restoreContext",
                                                    sosAdapter: OTSOSMissingAdapter(),
                                                    authKitAdapter: self.mockAuthKit2,
                                                    lockStateTracker: self.lockStateTracker,
                                                    accountStateTracker: self.accountStateTracker,
                                                    deviceInformationAdapter: self.makeInitiatorDeviceInfoAdapter())

        initiatorContext.startOctagonStateMachine()
        let newOTCliqueContext = OTConfigurationContext()
        newOTCliqueContext.context = OTDefaultContext
        newOTCliqueContext.dsid = self.otcliqueContext.dsid
        newOTCliqueContext.altDSID = self.otcliqueContext.altDSID
        newOTCliqueContext.otControl = self.otcliqueContext.otControl
        newOTCliqueContext.sbd = OTMockSecureBackup(bottleID: nil, entropy: nil)

        let resetExpectation = self.expectation(description: "resetExpectation callback occurs")
        self.fakeCuttlefishServer.resetListener = {  request in
            self.fakeCuttlefishServer.resetListener = nil
            resetExpectation.fulfill()
            XCTAssertTrue(request.resetReason.rawValue == CuttlefishResetReason.noBottleDuringEscrowRecovery.rawValue, "reset reason should be no bottle during escrow recovery")
            return nil
        }

        let newClique: OTClique
        do {
            newClique = try OTClique.performEscrowRecovery(withContextData: newOTCliqueContext, escrowArguments: [:])
            XCTAssertNotNil(newClique, "newClique should not be nil")
        } catch {
            XCTFail("Shouldn't have errored recovering: \(error)")
            throw error
        }
        self.wait(for: [resetExpectation], timeout: 10)

    }

    func testResetReasonHealthCheck() throws {

        let containerName = OTCKContainerName
        let contextName = OTDefaultContext

        self.cuttlefishContext.startOctagonStateMachine()
        self.startCKAccountStatusMock()

        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)

        let clique: OTClique
        do {
            clique = try OTClique.newFriends(withContextData: self.otcliqueContext, resetReason: .testGenerated)
            XCTAssertNotNil(clique, "Clique should not be nil")
            XCTAssertNotNil(clique.cliqueMemberIdentifier, "Should have a member identifier after a clique newFriends call")
        } catch {
            XCTFail("Shouldn't have errored making new friends: \(error)")
            throw error
        }

        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateReady, within: 10 * NSEC_PER_SEC)
        self.assertConsidersSelfTrusted(context: self.cuttlefishContext)

        do {
            let accountState = try OTAccountMetadataClassC.loadFromKeychain(forContainer: containerName, contextID: contextName)
            XCTAssertEqual(2, accountState.trustState.rawValue, "saved account should be trusted")
        } catch {
            XCTFail("error loading account state: \(error)")
        }

        // Reset any CFUs we've done so far
        self.otFollowUpController.postedFollowUp = false

        let resetExpectation = self.expectation(description: "resetExpectation callback occurs")
        self.fakeCuttlefishServer.resetListener = {  request in
            self.fakeCuttlefishServer.resetListener = nil
            resetExpectation.fulfill()
            XCTAssertTrue(request.resetReason.rawValue == CuttlefishResetReason.healthCheck.rawValue, "reset reason should be health check")
            return nil
        }
        self.fakeCuttlefishServer.returnResetOctagonResponse = true
        self.aksLockState = false
        self.lockStateTracker.recheck()

        let healthCheckCallback = self.expectation(description: "healthCheckCallback callback occurs")
        self.manager.healthCheck(containerName, context: contextName, skipRateLimitingCheck: false) { error in
            XCTAssertNil(error, "error should be nil")
            healthCheckCallback.fulfill()
        }
        self.wait(for: [healthCheckCallback, resetExpectation], timeout: 10)

        assertAllCKKSViews(enter: SecCKKSZoneKeyStateReady, within: 10 * NSEC_PER_SEC)
        self.verifyDatabaseMocks()

        let dumpCallback = self.expectation(description: "dumpCallback callback occurs")
        self.tphClient.dump(withContainer: containerName, context: contextName) {
            dump, _ in
            XCTAssertNotNil(dump, "dump should not be nil")
            let egoSelf = dump!["self"] as? Dictionary<String, AnyObject>
            XCTAssertNotNil(egoSelf, "egoSelf should not be nil")
            dumpCallback.fulfill()
        }
        self.wait(for: [dumpCallback], timeout: 10)

        self.verifyDatabaseMocks()
        self.assertEnters(context: cuttlefishContext, state: OctagonStateReady, within: 10 * NSEC_PER_SEC)
    }

    func testLegacyJoinCircleDoesNotReset() throws {
        self.cuttlefishContext.startOctagonStateMachine()
        self.startCKAccountStatusMock()

        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)

        let establishAndResetExpectation = self.expectation(description: "resetExpectation")
        let clique: OTClique
        let recoverykeyotcliqueContext = OTConfigurationContext()
        recoverykeyotcliqueContext.context = OTDefaultContext
        recoverykeyotcliqueContext.dsid = "13453464"
        recoverykeyotcliqueContext.altDSID = self.mockAuthKit.altDSID!
        recoverykeyotcliqueContext.otControl = self.otControl
        do {
            clique = try OTClique.newFriends(withContextData: recoverykeyotcliqueContext, resetReason: .testGenerated)
            XCTAssertNotNil(clique, "Clique should not be nil")
            XCTAssertNotNil(clique.cliqueMemberIdentifier, "Should have a member identifier after a clique newFriends call")
            establishAndResetExpectation.fulfill()
        } catch {
            XCTFail("Shouldn't have errored making new friends: \(error)")
            throw error
        }
        self.wait(for: [establishAndResetExpectation], timeout: 10)

        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateReady, within: 10 * NSEC_PER_SEC)
        self.verifyDatabaseMocks()

        self.fakeCuttlefishServer.resetListener = {  request in
            XCTFail("requestToJoinCircle should not reset Octagon")
            return nil
        }

        do {
            _ = try clique.requestToJoinCircle()
        } catch {
            XCTFail("Shouldn't have errored requesting to join circle: \(error)")
            throw error
        }

        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateReady, within: 10 * NSEC_PER_SEC)
    }

    func testResetReasonTestGenerated() throws {
        self.startCKAccountStatusMock()

        self.cuttlefishContext.startOctagonStateMachine()
        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateUntrusted, within: 10 * NSEC_PER_SEC)

        _ = try self.cuttlefishContext.accountAvailable("13453464")

        let resetExpectation = self.expectation(description: "resetExpectation")

        self.fakeCuttlefishServer.resetListener = {  request in
            self.fakeCuttlefishServer.resetListener = nil
            resetExpectation.fulfill()
            XCTAssertTrue(request.resetReason.rawValue == CuttlefishResetReason.testGenerated.rawValue, "reset reason should be test generated")
            return nil
        }

        let establishAndResetExpectation = self.expectation(description: "resetExpectation")
        self.cuttlefishContext.rpcResetAndEstablish(.testGenerated) { resetError in
            establishAndResetExpectation.fulfill()
            XCTAssertNil(resetError, "should not error resetting and establishing")
        }
        self.wait(for: [establishAndResetExpectation, resetExpectation], timeout: 10)

        self.assertEnters(context: self.cuttlefishContext, state: OctagonStateReady, within: 10 * NSEC_PER_SEC)
        self.verifyDatabaseMocks()
    }
}

#endif // OCTAGON
