project(CloudKeychainProxy)

add_bundle(CloudKeychainProxy ""
	CKDAKSLockMonitor.m
	XPCNotificationDispatcher.m
	CKDKVSProxy.m
	CKDSecuritydAccount.m
	cloudkeychainproxy.m
	../keychain/SecureObjectSync/CKBridge/SOSCloudKeychainConstants.c
	CKDKVSStore.m
)

set_target_properties(CloudKeychainProxy PROPERTIES
	SUFFIX ".bundle"
)

target_link_libraries(CloudKeychainProxy
	utilities
	Security
	Foundation
	IOKit

	# implied dependencies
	objc
	system
)

install(TARGETS CloudKeychainProxy DESTINATION libexec/darling/System/Library/Frameworks/Security.framework/Versions/A/Resources)
install(
	FILES com.apple.security.cloudkeychainproxy3.osx.plist
	DESTINATION libexec/darling/System/Library/LaunchAgents
	RENAME com.apple.security.cloudkeychainproxy3.plist
)
install(FILES ../OSX/sec/CloudKeychainProxy/CloudKeychainProxy.8 DESTINATION libexec/darling/usr/share/man/man8)
