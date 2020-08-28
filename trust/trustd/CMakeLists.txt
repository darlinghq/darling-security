project(trustd)

include_directories(
	../../OSX/sec/Security
)

add_lib_ios_shim(libtrustd
	OUTPUT_NAME "trustd"
	MODERN_OBJC
	SOURCES
		nameconstraints.c
		OTATrustUtilities.m
		personalization.c
		policytree.c
		SecCAIssuerCache.c
		SecCAIssuerRequest.m
		SecCertificateServer.c
		SecCertificateSource.c
		SecTrustExceptionResetCount.m
		SecOCSPCache.c
		SecOCSPRequest.c
		trustd_spi.c
		SecRevocationNetworking.m
		SecTrustStoreServer.m
		SecOCSPResponse.c
		SecPinningDb.m
		SecPolicyServer.c
		SecRevocationDb.c
		SecRevocationServer.c
		md.m
		SecTrustLoggingServer.m
		TrustURLSessionDelegate.m
		SecTrustServer.c
		SecTrustStoreServer.c
		../../OSX/sec/Security/SecuritydXPC.c
	DEFINITIONS
		LIBTRUSTD=1
)

add_darling_executable(trustd
	../../OSX/sec/ipc/server_entitlement_helpers.c
	trustd.c

	# not listed in Xcode project, but necessary
	../../OSX/sec/ipc/util.m
)
target_compile_options(trustd PRIVATE
	-fobjc-arc
)
target_compile_definitions(trustd PRIVATE
	LIBTRUSTD
	SECITEM_SHIM_OSX=1
	SEC_IOS_ON_OSX=1
)
target_link_libraries(trustd
	DER
	bsm.0
	z
	sqlite3
	libtrustd
	utilities
	security_asn1
	login
	CFNetwork
	Network
	Security
	CoreFoundation
	Foundation
	MobileAsset

	# implied dependencies
	objc
	system
)
install(TARGETS trustd DESTINATION libexec/darling/usr/libexec)
install(FILES macOS/com.apple.trustd.plist DESTINATION libexec/darling/System/Library/LaunchDaemons)
install(FILES macOS/com.apple.trustd.agent.plist DESTINATION libexec/darling/System/Library/LaunchAgents)
