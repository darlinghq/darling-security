project(security_sec)

add_compile_options(
	-Wno-visibility
	-Wno-unused-value
	-includeACMDefs.h
)

include_directories(BEFORE
	${CMAKE_CURRENT_SOURCE_DIR}/SharedWebCredential
	${CMAKE_CURRENT_SOURCE_DIR}/../regressions
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

add_library(security_security OBJECT
	Security/p12import.c
	Security/p12pbegen.c
	Security/pbkdf2.c
	Security/SecAccessControl.c
	Security/SecBase64.c
	securityd/Regressions/secd-52-offering-gencount-reset.c
	Security/SecCertificate.c
	Security/SecCertificatePath.c
	Security/SecCertificateRequest.c
	Security/SecCMS.c
	Security/SecDH.c
	Security/SecCTKKey.c
	securityd/Regressions/secd-95-escrow-persistence.c
	Security/SecECKey.c
	Security/SecFramework.c
	Security/SecIdentity.c
	Security/SecImportExport.c
	Security/SecItem.c
	Security/SecItemConstants.c
	Security/SecKey.c
	Security/SecPBKDF.c
	Security/SecPolicy.c
	SOSCircle/SecureObjectSync/SOSCloudCircle.c
	Security/SecRSAKey.c
	Security/SecSCEP.c
	Security/SecTrust.c
	Security/SecTrustSettings.c
	Security/SecSharedCredential.c
	Security/SecItemBackup.c
	Security/Tool/verify_cert.c
	Security/SecPasswordGenerate.c
	Security/SecTrustStore.c
	Security/vmdh.c
	Security/SecOTRDHKey.c
	Security/SecServerEncryptionSupport.c
	Security/SecOTRFullIdentity.c
	Security/SecOTRMath.c
	Security/SecOTRPacketData.c
	Security/SecOTRPackets.c
	Security/SecOTRPublicIdentity.c
	Security/SecOTRSession.c
	Security/SecOTRSessionAKE.c
	Security/SecOTRUtils.c
	Security/SecuritydXPC.c
)
target_compile_definitions(security_security PRIVATE INDIGO=1)

add_library(security_securityd OBJECT
	securityd/SecLogSettingsServer.c
	securityd/SecItemSchema.c
	securityd/SecItemDb.c
	securityd/OTATrustUtilities.c
	securityd/SecOTRRemote.c
	securityd/asynchttp.c
	securityd/policytree.c
	securityd/SecCAIssuerCache.c
	securityd/SecCAIssuerRequest.c
	securityd/SecItemServer.c
	Security/SecuritydXPC.c
	securityd/SecOCSPCache.c
	securityd/iCloudTrace.c
	SOSCircle/SecureObjectSync/SOSEngine.c
	securityd/SecDbKeychainItem.c
	securityd/SecOCSPRequest.c
	securityd/SecOCSPResponse.c
	securityd/SecPolicyServer.c
	securityd/SecKeybagSupport.c
	securityd/SecItemDataSource.c
	securityd/SecDbQuery.c
	securityd/SecItemBackupServer.c
	securityd/SecTrustServer.c
	securityd/nameconstraints.c
	securityd/SecTrustStoreServer.c
	securityd/spi.c
	securityd/SOSCloudCircleServer.c
	SharedWebCredential/swcagent_client.c
	SOSCircle/SecureObjectSync/SOSChangeTracker.c
	securityd/SecDbItem.c
)

target_compile_definitions(security_securityd PRIVATE INDIGO=1)

add_library(security_secipc OBJECT
	ipc/client.c
)
target_compile_definitions(security_secipc PRIVATE SECITEM_SHIM_OSX=1)

add_library(security_securityd_regressions OBJECT
	securityd/Regressions/sd-10-policytree.c
	securityd/Regressions/SOSTransportTestTransports.c
	securityd/Regressions/secd-90-hsa2.c
)

add_library(security_libsecd_regressions OBJECT
	securityd/Regressions/secd-62-account-backup.c
	securityd/Regressions/secd-50-message.c
	securityd/Regressions/secd-55-account-incompatibility.c
	securityd/Regressions/secd-01-items.c
	securityd/Regressions/secd-58-password-change.c
	securityd/Regressions/secd-57-account-leave.c
	securityd/Regressions/secd-62-account-hsa-join.c
	securityd/Regressions/secd-32-restore-bad-backup.c
	securityd/Regressions/secd-49-manifests.c
	securityd/Regressions/secd-60-account-cloud-identity.c
	securityd/Regressions/secd-75-engine-views.c
	securityd/Regressions/secd-70-engine-smash.c
	securityd/Regressions/secd-70-otr-remote.c
	securityd/Regressions/secd-56-account-apply.c
	securityd/Regressions/secd-63-account-resurrection.c
	securityd/Regressions/secd-02-upgrade-while-locked.c
	securityd/Regressions/secd-80-views-basic.c
	securityd/Regressions/secd-03-corrupted-items.c
	securityd/Regressions/secd-40-cc-gestalt.c
	securityd/Regressions/secd-05-corrupted-items.c
	securityd/Regressions/secd-70-engine.c
	securityd/Regressions/secd-65-account-retirement-reset.c
	SOSCircle/Regressions/SOSTestDevice.c
	securityd/Regressions/secd-04-corrupted-items.c
	securityd/Regressions/secd-52-account-changed.c
	securityd/Regressions/secd-30-keychain-upgrade.c
	securityd/Regressions/secd-31-keychain-bad.c
	securityd/Regressions/secd-31-keychain-unreadable.c
	securityd/Regressions/secd-50-account.c
	securityd/Regressions/secd-51-account-inflate.c
	securityd/Regressions/secd-82-persistent-ref.c
	securityd/Regressions/secd-74-engine-beer-servers.c
	securityd/Regressions/secd-81-item-acl-stress.c
	securityd/Regressions/secd-64-circlereset.c
	securityd/Regressions/secd-81-item-acl.c
	securityd/Regressions/secd-70-engine-corrupt.c
	securityd/Regressions/SOSTransportTestTransports.c
	securityd/Regressions/secd-34-backup-der-parse.c
	securityd/Regressions/secd-61-account-leave-not-in-kansas-anymore.c
	SOSCircle/Regressions/SOSTestDataSource.c
	securityd/Regressions/secd-35-keychain-migrate-inet.c
	securityd/Regressions/secd-33-keychain-ctk.c
	SOSCircle/Regressions/SOSRegressionUtilities.c
	securityd/Regressions/secd-55-account-circle.c
	securityd/Regressions/SecdTestKeychainUtilities.c
	securityd/Regressions/secd-82-secproperties-basic.c
	securityd/Regressions/secd-59-account-cleanup.c
)
