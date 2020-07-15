project(libsecurity_ssl)

add_macos_legacy_lib(security_ssl
	SOURCES
		../../protocol/SecProtocol.c
		../../protocol/SecProtocolConfiguration.m
		../../protocol/SecProtocolHelper.m
		../../protocol/SecProtocolTypes.m
		lib/sslCipherSpecs.c
		lib/sslContext.c
		lib/sslCrypto.c
		lib/sslKeychain.c
		lib/sslMemory.c
		lib/sslRecord.c
		lib/SSLRecordInternal.c
		lib/sslTransport.c
		lib/tlsCallbacks.c
)
