project(libsecurity_keychain_der)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_keychain_der OBJECT
	libDER/DER_CertCrl.c
	libDER/DER_Decode.c
	libDER/DER_Digest.c
	libDER/DER_Encode.c
	libDER/DER_Keys.c
	libDER/oids.c
	libDERUtils/fileIo.c
	libDERUtils/libDERUtils.c
	libDERUtils/printFields.c
)
