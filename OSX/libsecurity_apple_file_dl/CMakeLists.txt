project(libsecurity_apple_file_dl)

add_macos_legacy_lib(security_apple_file_dl
	SOURCES
		lib/AppleDLBuiltin.cpp
		lib/AppleFileDL.cpp
)
