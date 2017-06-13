include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/ipc
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/SecureObjectSync
)

add_definitions(
	-DSEC_IOS_ON_OSX=1
)

add_library(libSecOtrOSX OBJECT
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
make_fat(libSecOtrOSX)

add_definitions(
	-DECITEM_SHIM_OSX=1
)

add_library(libSecItemShimOSX OBJECT
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
make_fat(libSecItemShimOSX)

add_library(libSecTrustOSX OBJECT
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
make_fat(libSecTrustOSX)

