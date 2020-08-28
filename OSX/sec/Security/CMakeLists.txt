project(libsecurity)

# only needed for various tests and for the iOS build
#add_security_library(libsecurity
#	FAT
#	OUTPUT_NAME "security"
#	SOURCES
#		../../../experiment/SecExperiment.m
#		../../../keychain/SecureObjectSync/SOSCloudCircle.m
#		../../../keychain/SecureObjectSync/Tool/secViewDisplay.c
#		../../utilities/SecInternalRelease.c
#		../../utilities/SecPaddingConfigurations.c
#		p12import.c
#		p12pbegen.c
#		pbkdf2.c
#		SecAccessControl.m
#		SecBase.c
#		SecBase64.c
#		SecCertificate.c
#		SecCertificateRequest.c
#		SecCFAllocator.c
#		SecCMS.c
#		SecCTKKey.m
#		SecDH.c
#		SecDigest.c
#		SecECKey.m
#		SecEMCS.m
#		SecIdentity.c
#		SecImportExport.c
#		SecItem.c
#		SecItem.m
#		SecItemBackup.c
#		SecItemConstants.c
#		SecKey.m
#		SecKeyAdaptors.m
#		SecKeyProxy.m
#		SecOTRDHKey.c
#		SecOTRFullIdentity.c
#		SecOTRMath.c
#		SecOTRPacketData.c
#		SecOTRPackets.c
#		SecOTRPublicIdentity.c
#		SecOTRSession.c
#		SecOTRSessionAKE.c
#		SecOTRUtils.c
#		SecPasswordGenerate.c
#		SecPBKDF.c
#		SecPolicy.c
#		SecPolicyLeafCallbacks.c
#		SecRSAKey.c
#		SecSCEP.c
#		SecServerEncryptionSupport.c
#		SecSharedCredential.c
#		SecSignatureVerificationSupport.c
#		SecTrust.c
#		SecTrustStatusCodes.c
#		SecTrustStore.c
#		SecuritydXPC.c
#		vmdh.c
#)

add_lib_ios(SecOtrOSX
	SOURCES
		SecOTRDHKey.c
		SecOTRFullIdentity.c
		SecOTRMath.c
		SecOTRPacketData.c
		SecOTRPackets.c
		SecOTRPublicIdentity.c
		SecOTRSession.c
		SecOTRSessionAKE.c
		SecOTRUtils.c
)

add_lib_ios_shim(SecTrustOSX
	SOURCES
		../../utilities/SecInternalRelease.c
		SecBase64.c
		SecCertificate.c
		SecCertificateRequest.c
		SecDigest.c
		SecECKey.m
		SecKey.m
		SecKeyAdaptors.m
		SecPolicy.c
		SecPolicyLeafCallbacks.c
		SecRSAKey.c
		SecServerEncryptionSupport.c
		SecSignatureVerificationSupport.c
		SecTrust.c
		SecTrustStatusCodes.c
		SecTrustStore.c
)

add_lib_ios_shim(SecItemShimOSX
	SOURCES
		../../../keychain/SecureObjectSync/SOSCloudCircle.m
		p12import.c
		p12pbegen.c
		SecAccessControl.m
		SecCFAllocator.c
		SecCTKKey.m
		SecDH.c
		SecECKey.m
		SecImportExport.c
		SecItem.c
		SecItem.m
		SecItemBackup.c
		SecItemConstants.c
		SecKey.m
		SecKeyAdaptors.m
		SecKeyProxy.m
		SecPasswordGenerate.c
		SecRSAKey.c
		SecuritydXPC.c
)

add_lib_ios(logging
	SOURCES
		SecLogging.c
	INCLUDES
		${CMAKE_CURRENT_SOURCE_DIR}/../ipc
)
