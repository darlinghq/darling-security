project(security_apple_x509_cl)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_apple_x509_cl OBJECT
	AppleX509CL.cpp
	AppleX509CLSession.cpp
	CertFields.cpp
	CLCachedEntry.cpp
	CLCertExtensions.cpp
	CLCrlExtensions.cpp
	CLFieldsCommon.cpp
	clNameUtils.cpp
	clNssUtils.cpp
	CrlFields.cpp
	CSPAttacher.cpp
	DecodedCert.cpp
	DecodedCrl.cpp
	DecodedExtensions.cpp
	DecodedItem.cpp
	Session_Cert.cpp
	Session_CRL.cpp
	Session_Crypto.cpp
	Session_CSR.cpp
	AppleX509CLBuiltin.cpp
	AppleX509CLPlugin.cpp
)
