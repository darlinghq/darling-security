project(KeychainSyncAccountNotification)

add_bundle(KeychainSyncAccountNotification ""
	KeychainSyncAccountNotification.m
)

set_target_properties(KeychainSyncAccountNotification PROPERTIES
	SUFFIX ".bundle"
)

target_link_libraries(KeychainSyncAccountNotification
	AuthKit
	Security
	#Accounts # missing
	Foundation

	# implied dependencies
	objc
	system
)

install(TARGETS KeychainSyncAccountNotification DESTINATION libexec/darling/System/Library/Accounts/Notification)
