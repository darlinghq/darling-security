include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_library(libsecurity_ssl OBJECT
	lib/sslRecord.c
	lib/sslContext.c
	lib/tlsCallbacks.c
	lib/SSLRecordInternal.c
	lib/sslKeychain.c
	lib/sslMemory.c
	lib/sslTransport.c
	lib/sslCipherSpecs.c
	lib/sslCrypto.c
)
make_fat(libsecurity_ssl)
