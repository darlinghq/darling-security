project(SecureObjectSync)

include_directories(
	../categories
	../../OSX/sec/ipc
)

add_lib_ios_shim(SecureObjectSyncFramework
	SOURCES
		SOSBackupSliceKeyBag.m
		SOSCircleDer.c
		SOSCircle.c
		Tool/secViewDisplay.c
		SOSPeerInfo.m
		SOSCircleV2.c
		CKBridge/SOSCloudKeychainClient.c
		SOSPiggyback.m
		CKBridge/SOSCloudKeychainConstants.c
		SOSECWrapUnwrap.c
		SOSFullPeerInfo.m
		SOSGenCount.c
		SOSInternal.m
		SOSControlHelper.m
		SOSKVSKeys.m
		SOSKeyedPubKeyIdentifier.c
		SOSPeerInfoCollections.c
		SOSPeerInfoDER.m
		SOSPeerInfoRingState.m
		SOSPeerInfoV2.m
		SOSRingPeerInfoUtils.c
		SOSRingV0.m
		SOSViews.m
		../../OSX/sec/Security/SecRecoveryKey.m
	INCLUDES
		${CMAKE_CURRENT_SOURCE_DIR}
)

# can't build this with Octagon disabled
#add_lib_ios_shim(SecureObjectSyncServer
#	OBJC_ARC
#	MODERN_OBJC
#	SOURCES
#		../../OSX/sec/Security/SecRecoveryKey.m
#		../securityd/SOSCloudCircleServer.m
#		generated_source/SOSAccountConfiguration.m
#		SOSAccount.m
#		SOSAccountBackup.m
#		SOSAccountCircles.m
#		SOSAccountCloudParameters.m
#		SOSAccountCredentials.m
#		SOSAccountDer.m
#		SOSAccountFullPeerInfo.m
#		SOSAccountGetSet.m
#		SOSAccountGhost.m
#		SOSAccountLog.m
#		SOSAccountPeers.m
#		SOSAccountPersistence.m
#		SOSAccountRecovery.m
#		SOSAccountRings.m
#		SOSAccountRingUpdate.m
#		SOSAccountSync.m
#		SOSAccountTransaction.m
#		SOSAccountTrust.m
#		SOSAccountTrustClassic.m
#		SOSAccountTrustClassic+Circle.m
#		SOSAccountTrustClassic+Expansion.m
#		SOSAccountTrustClassic+Identity.m
#		SOSAccountTrustClassic+Retirement.m
#		SOSAccountUpdate.m
#		SOSAccountViewSync.m
#		SOSAuthKitHelpers.m
#		SOSBackupEvent.c
#		SOSBackupInformation.m
#		SOSCoder.c
#		SOSControlServer.m
#		SOSDigestVector.c
#		SOSIntervalEvent.m
#		SOSManifest.c
#		SOSMessage.c
#		SOSPeer.m
#		SOSPeerCoder.m
#		SOSPeerOTRTimer.m
#		SOSPeerRateLimiter.m
#		SOSRecoveryKeyBag.m
#		SOSRingBackup.m
#		SOSRingBasic.m
#		SOSRingConcordanceTrust.c
#		SOSRingDER.c
#		SOSRingRecovery.m
#		SOSRingTypes.m
#		SOSRingUtils.c
#		SOSTransport.m
#		SOSTransportBackupPeer.m
#		SOSTransportCircle.m
#		SOSTransportCircleCK.m
#		SOSTransportCircleKVS.m
#		SOSTransportKeyParameter.m
#		SOSTransportMessage.m
#		SOSTransportMessageKVS.m
#		SOSTrustedDeviceAttributes.m
#		SOSUserKeygen.m
#)
