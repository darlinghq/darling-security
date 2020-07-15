project(libsecurity_comcryption)

add_macos_legacy_lib(security_comcryption
	SOURCES
		lib/comcryption.c
		lib/comcryptPriv.c
)
