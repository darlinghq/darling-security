include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_library(libsecurity_apple_x509_tp OBJECT
	lib/TPDatabase.cpp
	lib/TPCertInfo.cpp
	lib/AppleTP.cpp
	lib/ocspRequest.cpp
	lib/TPNetwork.cpp
	lib/tpCrlVerify.cpp
	lib/AppleTPSession.cpp
	lib/cuEnc64.c
	lib/tpPolicies.cpp
	lib/AppleX509TPBuiltin.cpp
	lib/tpOcspVerify.cpp
	lib/TPCrlInfo.cpp
	lib/tpTime.c
	lib/certGroupUtils.cpp
	lib/tpOcspCache.cpp
	lib/tpCertGroup.cpp
	lib/tpOcspCertVfy.cpp
	lib/tpCredRequest.cpp
)
make_fat(libsecurity_apple_x509_tp)
