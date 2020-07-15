project(securityuploadd)

add_darling_executable(securityuploadd
	main.m
	supd.m
)

target_link_libraries(securityuploadd
	#Accounts # missing
	z
	Foundation
	AuthKit
	utilities
	Security

	# implied dependencies
	objc
	system
)

set_target_properties(securityuploadd PROPERTIES OUTPUT_NAME "supd")

install(TARGETS securityuploadd DESTINATION libexec/darling/usr/libexec)
install(FILES securityuploadd.8 DESTINATION libexec/darling/usr/share/man/man1)
install(
	FILES securityuploadd-osx.plist
	DESTINATION libexec/darling/System/Library/LaunchAgents
	RENAME com.apple.securityuploadd.plist
)
