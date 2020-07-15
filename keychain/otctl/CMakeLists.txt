project(otctl)

add_darling_executable(otctl
	../../lib/SecArgParse.c
	../ot/OTControlProtocol.m
	../otpaird/OTPairingClient.m
	EscrowRequestCLI.m
	OTControlCLI.m
	otctl.m
)

target_link_libraries(otctl
	Security

	# implied dependencies
	objc
	system
)

install(TARGETS otctl DESTINATION libexec/darling/usr/sbin)
install(FILES otctl.1 DESTINATION libexec/darling/usr/share/man/man1)
