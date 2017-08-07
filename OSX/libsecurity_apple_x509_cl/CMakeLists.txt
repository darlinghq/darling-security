include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_darling_static_library(security_apple_x509_cl FAT
	SOURCES
		lib/AppleX509CL.cpp
		lib/clNssUtils.cpp
		lib/DecodedItem.cpp
		lib/clNameUtils.cpp
		lib/Session_Cert.cpp
		lib/CLFieldsCommon.cpp
		lib/DecodedCert.cpp
		lib/AppleX509CLBuiltin.cpp
		lib/CertFields.cpp
		lib/AppleX509CLSession.cpp
		lib/CSPAttacher.cpp
		lib/CLCrlExtensions.cpp
		lib/AppleX509CLPlugin.cpp
		lib/CLCachedEntry.cpp
		lib/DecodedCrl.cpp
		lib/CrlFields.cpp
		lib/Session_CSR.cpp
		lib/Session_CRL.cpp
		lib/DecodedExtensions.cpp
		lib/CLCertExtensions.cpp
		lib/Session_Crypto.cpp
)
