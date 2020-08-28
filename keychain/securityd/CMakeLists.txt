project(secd)

add_darling_executable(secd
	PolicyReporter.h
	PolicyReporter.m
	spi.c
	../../OSX/sec/ipc/SecdWatchdog.m
	../../OSX/sec/ipc/server.c
	../../securityd/src/util.m
	../../OSX/sec/ipc/server_entitlement_helpers.c
	../../OSX/sec/ipc/server_security_helpers.m
	../../OSX/sec/ipc/server_xpc.m
	../../OSX/sec/ipc/server_endpoint.m
)
target_compile_definitions(secd PRIVATE
	SECITEM_SHIM_OSX=1
	SEC_IOS_ON_OSX=1
	SECD_SERVER=1
)
target_compile_options(secd PRIVATE
	-fobjc-arc
)
target_link_libraries(secd
	#TrustedPeers
	#CloudServices # missing
	z
	AuthKit
	#AppleAccount # missing
	Accounts
	#prequelite # missing
	CrashReporterSupport
	DiagnosticMessagesClient
	SecurityFoundation
	#WirelessDiagnostics # missing
	Foundation
	login
	DER
	#ACM
	aks # already includes aks_acl
	#aks_acl
	security_asn1

	#coreauthd_client
	LocalAuthentication # instead of coreauthd_client

	#ctkclient_sep
	CryptoTokenKit # instead of ctkclient_sep and ACM

	sqlite3
	SecureObjectSyncServer
	utilities
	libsecurityd_ios
	libtrustd
	CoreFoundation
	IOKit
	CoreData
	#ApplePushService # missing
	#CloudKit # missing
	SystemConfiguration
	Security
	ProtocolBuffer
	AppleSystemInfo

	# implied dependencies
	objc
	system
)
install(TARGETS secd DESTINATION libexec/darling/usr/libexec)
install(FILES ../../OSX/sec/ipc/com.apple.secd.plist DESTINATION libexec/darling/System/Library/LaunchAgents)
