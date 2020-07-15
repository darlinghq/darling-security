project(KeychainSyncAccountUpdater)

add_bundle(KeychainSyncAccountUpdater ""
KeychainSyncAccountUpdater.m
)

set_target_properties(KeychainSyncAccountUpdater PROPERTIES
	SUFFIX ".bundle"
)

target_link_libraries(KeychainSyncAccountUpdater
	libsecurityd_ios
	SystemConfiguration
	utilities
	#MobileGestalt # missing
	#IDS #missing
	KeychainCircle

	# implied dependencies
	objc
	system
)

install(TARGETS KeychainSyncAccountUpdater DESTINATION libexec/darling/System/Library/CoreServices/UAUPlugins)
