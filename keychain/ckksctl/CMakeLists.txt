project(ckksctl)

add_darling_executable(ckksctl
	../../lib/SecArgParse.c
	ckksctl.m
)

target_link_libraries(ckksctl
	Security

	# implied dependencies
	objc
	system
)

install(TARGETS ckksctl DESTINATION libexec/darling/usr/sbin)
