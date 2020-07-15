project(security-sysdiagnose)

add_darling_executable(security-sysdiagnose
	security-sysdiagnose.m
)
target_compile_options(security-sysdiagnose PRIVATE
	-fobjc-arc
)
target_link_libraries(security-sysdiagnose
	SecureObjectSyncServer
	SOSCommands
	Security
	utilities

	# implied dependencies
	objc
	system
)

install(TARGETS security-sysdiagnose DESTINATION libexec/darling/usr/libexec)
install(FILES security-sysdiagnose.1 DESTINATION libexec/darling/usr/share/man/man1)
