include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/ipc
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/SecureObjectSync
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/CKBridge
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/Tool
	${CMAKE_CURRENT_SOURCE_DIR}/Security
	${CMAKE_CURRENT_SOURCE_DIR}/securityd
	${CMAKE_CURRENT_SOURCE_DIR}/SharedWebCredential
)

add_definitions(
	-DSEC_IOS_ON_OSX=1
	-DNO_SERVER=1
	-DOS_STATE_API_REQUEST=1
	-DOS_STATE_DATA_PROTOCOL_BUFFER=1
)

add_darling_static_library(securityd FAT
	SOURCES
		securityd/asynchttp.c
		securityd/iCloudTrace.c
		securityd/nameconstraints.c
		securityd/OTATrustUtilities.c
		securityd/personalization.c
		securityd/policytree.c
		securityd/SecCAIssuerCache.c
		securityd/SecCAIssuerRequest.c
		securityd/SecCertificateSource.c
		securityd/SecDbItem.c
		securityd/SecDbKeychainItem.c
		securityd/SecDbQuery.c
		securityd/SecItemBackupServer.c
		securityd/SecItemDataSource.c
		securityd/SecItemDb.c
		securityd/SecItemSchema.c
		securityd/SecItemServer.c
		securityd/SecKeybagSupport.c
		securityd/SecLogSettingsServer.c
		securityd/SecOCSPCache.c
		securityd/SecOCSPRequest.c
		securityd/SecOCSPResponse.c
		securityd/SecOTRRemote.c
		securityd/SecPolicyServer.c
		securityd/SecRevocationDb.c
		securityd/SecTrustLoggingServer.c
		securityd/SecTrustServer.c
		securityd/SecTrustStoreServer.c
		securityd/SOSCloudCircleServer.c
		securityd/spi.c
)

add_darling_static_library(SecOtrOSX FAT
	SOURCES
		Security/SecOTRDHKey.c
		Security/SecOTRFullIdentity.c
		Security/SecOTRMath.c
		Security/SecOTRPacketData.c
		Security/SecOTRPackets.c
		Security/SecOTRPublicIdentity.c
		Security/SecOTRSession.c
		Security/SecOTRSessionAKE.c
		Security/SecOTRUtils.c
)

add_darling_static_library(SecureObjectSync FAT
	SOURCES
		SOSCircle/Tool/accountCirclesViewsPrint.c
		SOSCircle/SecureObjectSync/SOSBackupInformation.c
		SOSCircle/SecureObjectSync/SOSAccount.c
		SOSCircle/SecureObjectSync/SOSAccountBackup.c
		SOSCircle/SecureObjectSync/SOSAccountCircles.c
		SOSCircle/SecureObjectSync/SOSAccountSync.c
		SOSCircle/SecureObjectSync/SOSAccountCloudParameters.c
		SOSCircle/SecureObjectSync/SOSAccountCredentials.c
		SOSCircle/SecureObjectSync/SOSAccountDer.c
		SOSCircle/SecureObjectSync/SOSKeyedPubKeyIdentifier.c
		SOSCircle/SecureObjectSync/SOSAccountFullPeerInfo.c
		SOSCircle/SecureObjectSync/SOSAccountHSAJoin.c
		SOSCircle/SecureObjectSync/SOSAccountLog.c
		SOSCircle/SecureObjectSync/SOSAccountPeers.c
		SOSCircle/SecureObjectSync/SOSAccountPersistence.c
		SOSCircle/SecureObjectSync/SOSAccountRingUpdate.c
		SOSCircle/SecureObjectSync/SOSAccountRings.c
		SOSCircle/SecureObjectSync/SOSRingRecovery.c
		SOSCircle/SecureObjectSync/SOSAccountTransaction.c
		SOSCircle/SecureObjectSync/SOSAccountUpdate.c
		SOSCircle/SecureObjectSync/SOSAccountViewSync.c
		SOSCircle/SecureObjectSync/SOSBackupEvent.c
		SOSCircle/SecureObjectSync/SOSBackupSliceKeyBag.c
		SOSCircle/SecureObjectSync/SOSCircle.c
		SOSCircle/SecureObjectSync/SOSCircleDer.c
		SOSCircle/SecureObjectSync/SOSCircleV2.c
		SOSCircle/CKBridge/SOSCloudKeychainConstants.c
		SOSCircle/CKBridge/SOSCloudKeychainClient.c
		SOSCircle/SecureObjectSync/SOSCoder.c
		SOSCircle/SecureObjectSync/SOSChangeTracker.c
		SOSCircle/SecureObjectSync/SOSDigestVector.c
		SOSCircle/SecureObjectSync/SOSEngine.c
		SOSCircle/SecureObjectSync/SOSECWrapUnwrap.c
		SOSCircle/SecureObjectSync/SOSFullPeerInfo.c
		SOSCircle/SecureObjectSync/SOSGenCount.c
		SOSCircle/SecureObjectSync/SOSInternal.c
		SOSCircle/SecureObjectSync/SOSKVSKeys.c
		SOSCircle/SecureObjectSync/SOSManifest.c
		SOSCircle/SecureObjectSync/SOSMessage.c
		SOSCircle/SecureObjectSync/SOSPeer.c
		SOSCircle/SecureObjectSync/SOSPeerCoder.c
		SOSCircle/SecureObjectSync/SOSPeerInfo.c
		SOSCircle/SecureObjectSync/SOSPeerInfoCollections.c
		SOSCircle/SecureObjectSync/SOSPeerInfoDER.c
		SOSCircle/SecureObjectSync/SOSRecoveryKeyBag.c
		SOSCircle/SecureObjectSync/SOSPeerInfoRingState.c
		SOSCircle/SecureObjectSync/SOSPeerInfoSecurityProperties.c
		SOSCircle/SecureObjectSync/SOSPeerInfoV2.c
		SOSCircle/SecureObjectSync/SOSAccountGhost.c
		SOSCircle/SecureObjectSync/SOSRingBackup.c
		SOSCircle/SecureObjectSync/SOSAccountGetSet.c
		SOSCircle/SecureObjectSync/SOSRingBasic.c
		SOSCircle/SecureObjectSync/SOSRingConcordanceTrust.c
		Security/SecRecoveryKey.m
		SOSCircle/SecureObjectSync/SOSRingDER.c
		SOSCircle/SecureObjectSync/SOSAccountRecovery.c
		SOSCircle/SecureObjectSync/SOSRingPeerInfoUtils.c
		SOSCircle/SecureObjectSync/SOSRingTypes.c
		SOSCircle/SecureObjectSync/SOSRingUtils.c
		SOSCircle/SecureObjectSync/SOSRingV0.c
		SOSCircle/SecureObjectSync/SOSSysdiagnose.c
		SOSCircle/SecureObjectSync/SOSTransport.c
		SOSCircle/SecureObjectSync/SOSTransportBackupPeer.c
		SOSCircle/SecureObjectSync/SOSTransportCircle.c
		SOSCircle/SecureObjectSync/SOSTransportCircleKVS.c
		SOSCircle/SecureObjectSync/SOSTransportKeyParameter.c
		SOSCircle/SecureObjectSync/SOSTransportKeyParameterKVS.c
		SOSCircle/SecureObjectSync/SOSTransportMessage.c
		SOSCircle/SecureObjectSync/SOSTransportMessageIDS.c
		SOSCircle/SecureObjectSync/SOSTransportMessageKVS.c
		SOSCircle/SecureObjectSync/SOSUserKeygen.c
		SOSCircle/SecureObjectSync/SOSViews.c
		SOSCircle/Tool/secToolFileIO.c
		SOSCircle/Tool/secViewDisplay.c
)

add_darling_static_library(logging FAT
	SOURCES
		Security/SecLogging.c
)

add_definitions(
	-DSECITEM_SHIM_OSX=1
)

add_darling_static_library(SecItemShimOSX FAT
	SOURCES
		Security/SecItemBackup.c
		Security/SecKeyAdaptors.c
		Security/SecCFAllocator.c
		Security/SecItem.c
		Security/SecRSAKey.c
		Security/SecDH.c
		Security/SecCTKKey.c
		SOSCircle/SecureObjectSync/SOSCloudCircle.c
		Security/SecAccessControl.c
		Security/SecKey.c
		Security/SecuritydXPC.c
		Security/SecECKey.c
		Security/SecItemConstants.c
		Security/SecPasswordGenerate.c
)

add_darling_static_library(SecTrustOSX FAT
	SOURCES
		Security/SecCertificateRequest.c
		Security/SecCertificate.c
		Security/SecDigest.c
		Security/SecBase64.c
		Security/SecCertificatePath.c
		Security/SecKey.c
		Security/SecKeyAdaptors.c
		Security/SecPolicy.c
		Security/SecPolicyLeafCallbacks.c
		Security/SecTrust.c
		Security/SecTrustStore.c
		Security/SecECKey.c
		Security/SecRSAKey.c
		Security/SecServerEncryptionSupport.c
		../utilities/src/SecInternalRelease.c
		Security/SecSignatureVerificationSupport.c
)

add_darling_static_library(secipc_client FAT
	SOURCES
		ipc/client.c
)

add_darling_executable(secipc_server ipc/server.c ipc/client.c)
set_target_properties(secipc_server PROPERTIES OUTPUT_NAME "secd")
target_link_libraries(secipc_server system Security CoreFoundation
    SecTrustOSX securityd xpc sqlite3 utilities CFNetwork SecItemShimOSX
    security_keychain_DER SecureObjectSync z IOKit #security_smime
    LocalAuthentication objc CryptoTokenKit SystemConfiguration
	security_asn1 bsm.0 AppleSystemInfo cxx)
#target_link_options(secipc_server BEFORE PRIVATE "-Wl,-all_load")
install(TARGETS secipc_server DESTINATION libexec/darling/usr/libexec)
install(FILES ipc/com.apple.secd.plist DESTINATION libexec/darling/System/Library/LaunchDaemons)

add_darling_executable(trustd_server ipc/server.c ipc/client.c)
set_target_properties(trustd_server PROPERTIES OUTPUT_NAME "trustd")
target_compile_definitions(trustd_server PRIVATE TRUSTD_SERVER)
target_link_libraries(trustd_server system Security CoreFoundation
	SecTrustOSX securityd xpc sqlite3 utilities CFNetwork SecItemShimOSX
	security_keychain_DER SecureObjectSync z IOKit #security_smime
	LocalAuthentication objc CryptoTokenKit SystemConfiguration
	security_asn1 bsm.0 AppleSystemInfo cxx)
#target_link_options(trustd_server BEFORE PRIVATE "-Wl,-all_load")
install(TARGETS trustd_server DESTINATION libexec/darling/usr/libexec)
install(FILES ../trustd/com.apple.trustd.plist DESTINATION libexec/darling/System/Library/LaunchDaemons)
install(FILES ../trustd/com.apple.trustd.agent.plist DESTINATION libexec/darling/System/Library/LaunchAgents)

add_subdirectory(Security/Tool)
#add_subdirectory(SOSCircle/Tool)
