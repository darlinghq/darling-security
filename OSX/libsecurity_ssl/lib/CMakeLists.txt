project(security_ssl)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_ssl OBJECT
	sslMemory.c
	sslCrypto.c
	SSLRecordInternal.c
	appleSession.c
	sslKeychain.c
	sslCipherSpecs.c
	sslContext.c
	tlsCallbacks.c
	sslRecord.c
	sslTransport.c
	sslUtils.c
)
