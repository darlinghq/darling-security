project(security_sec)

add_compile_options(
	-Wno-visibility
)

include_directories(BEFORE
	${CMAKE_CURRENT_SOURCE_DIR}/ipc
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/Regressions
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/SecureObjectSync
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/CKBridge
	${CMAKE_CURRENT_SOURCE_DIR}/Security
	${CMAKE_CURRENT_SOURCE_DIR}/securityd
	${CMAKE_CURRENT_SOURCE_DIR}
)

#include_directories(AFTER
#)

add_library(sec_item_shim OBJECT
	Security/SecItemBackup.c
	Security/SecItem.c
	Security/SecDH.c
	SOSCircle/SecureObjectSync/SOSCloudCircle.c
	Security/SecAccessControl.c
	Security/SecuritydXPC.c
	SOSCircle/osxshim.c
	Security/SecItemConstants.c
	Security/SecPasswordGenerate.c
)

target_compile_definitions(sec_item_shim PRIVATE -DSECITEM_SHIM_OSX=1)

add_library(security_SecureObjectSync OBJECT
	SOSCircle/SecureObjectSync/SOSAccountRingUpdate.c
	SOSCircle/SecureObjectSync/SOSRingTypes.c
	SOSCircle/SecureObjectSync/SOSPeerInfoRingState.c
	SOSCircle/SecureObjectSync/SOSPeerInfoSecurityProperties.c
	SOSCircle/SecureObjectSync/SOSTransportCircle.c
	SOSCircle/SecureObjectSync/SOSGenCount.c
	SOSCircle/SecureObjectSync/SOSUserKeygen.c
	SOSCircle/SecureObjectSync/SOSAccount.c
	SOSCircle/SecureObjectSync/SOSCircleDer.c
	SOSCircle/SecureObjectSync/SOSCircle.c
	SOSCircle/SecureObjectSync/SOSPeer.c
	SOSCircle/SecureObjectSync/SOSViewQueries.c
	SOSCircle/SecureObjectSync/SOSRingBasic.c
	SOSCircle/SecureObjectSync/SOSAccountCloudParameters.c
	SOSCircle/SecureObjectSync/SOSForerunnerSession.c
	SOSCircle/SecureObjectSync/SOSRingBackup.c
	SOSCircle/SecureObjectSync/SOSPeerInfoDER.c
	SOSCircle/SecureObjectSync/SOSTransportCoder.c
	SOSCircle/SecureObjectSync/SOSAccountUpdate.c
	SOSCircle/SecureObjectSync/SOSTransport.c
	SOSCircle/SecureObjectSync/SOSAccountRings.c
	SOSCircle/SecureObjectSync/SOSAccountBackup.c
	SOSCircle/SecureObjectSync/SOSAccountPeers.c
	SOSCircle/SecureObjectSync/SOSCircleV2.c
	SOSCircle/SecureObjectSync/SOSAccountHSAJoin.c
	SOSCircle/SecureObjectSync/SOSTransportBackupPeer.c
	SOSCircle/SecureObjectSync/SOSBackupSliceKeyBag.c
	SOSCircle/SecureObjectSync/SOSECWrapUnwrap.c
	SOSCircle/SecureObjectSync/SOSPeerInfoV2.c
	SOSCircle/SecureObjectSync/SOSInternal.c
	SOSCircle/SecureObjectSync/SOSTransportMessageKVS.c
	SOSCircle/SecureObjectSync/SOSPeerInfo.c
	SOSCircle/SecureObjectSync/SOSTransportKeyParameterKVS.c
	SOSCircle/SecureObjectSync/SOSAccountDer.c
	SOSCircle/CKBridge/SOSCloudKeychainConstants.c
	SOSCircle/SecureObjectSync/SOSDigestVector.c
	SOSCircle/SecureObjectSync/SOSPeerInfoCollections.c
	SOSCircle/SecureObjectSync/SOSViews.c
	SOSCircle/SecureObjectSync/SOSFullPeerInfo.c
	SOSCircle/SecureObjectSync/SOSBackupEvent.c
	SOSCircle/SecureObjectSync/SOSRingDER.c
	SOSCircle/SecureObjectSync/SOSRingV0.c
	SOSCircle/SecureObjectSync/SOSRingPeerInfoUtils.c
	SOSCircle/SecureObjectSync/SOSTransportMessageIDS.c
	SOSCircle/SecureObjectSync/SOSAccountCredentials.c
	SOSCircle/CKBridge/SOSCloudKeychainClient.c
	SOSCircle/SecureObjectSync/SOSTransportCircleKVS.c
	SOSCircle/SecureObjectSync/SOSManifest.c
	SOSCircle/SecureObjectSync/SOSTransportMessage.c
	SOSCircle/SecureObjectSync/SOSRingConcordanceTrust.c
	SOSCircle/SecureObjectSync/SOSCoder.c
	SOSCircle/SecureObjectSync/SOSMessage.c
	SOSCircle/SecureObjectSync/SOSPeerCoder.c
	SOSCircle/SecureObjectSync/SOSTransportKeyParameter.c
	SOSCircle/SecureObjectSync/SOSRingUtils.c
	SOSCircle/SecureObjectSync/SOSAccountFullPeerInfo.c
	SOSCircle/SecureObjectSync/SOSAccountCircles.c
	SOSCircle/SecureObjectSync/SOSKVSKeys.c
	SOSCircle/SecureObjectSync/SOSAccountPersistence.c
)

add_library(security_SecTrustOSX OBJECT
	Security/SecCertificate.c
	Security/SecCertificatePath.c
	Security/SecPolicy.c
	Security/SecTrust.c
	Security/SecTrustSettings.c
	Security/SecTrustStore.c
	Security/SecKey.c
	Security/SecECKey.c
	Security/SecRSAKey.c
)
target_compile_definitions(security_SecTrustOSX PRIVATE SECTRUST_OSX=0)

add_library(security_SecOtrOSX OBJECT
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
