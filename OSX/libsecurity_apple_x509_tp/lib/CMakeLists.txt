project(security_apple_x509_tp)

include_directories(BEFORE
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/../../libsecurity_cssm/lib
)

add_library(security_apple_x509_tp OBJECT
	AppleTP.cpp
	AppleTPSession.cpp
	certGroupUtils.cpp
	tpCertGroup.cpp
	TPCertInfo.cpp
	tpCredRequest.cpp
	TPCrlInfo.cpp
	tpCrlVerify.cpp
	TPDatabase.cpp
	TPNetwork.cpp
	tpPolicies.cpp
	tpTime.c
	AppleX509TPBuiltin.cpp
	ocspRequest.cpp
	tpOcspCache.cpp
	tpOcspCertVfy.cpp
	tpOcspVerify.cpp
	cuEnc64.c
	tpCertAllowList.cpp
)

set_property(TARGET security_apple_x509_tp PROPERTY COMPILE_FLAGS "-include oidsbase.h")
