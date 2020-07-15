project(libsecurity_cdsa_utils)

add_macos_legacy_lib(security_cdsa_utils
	SOURCES
		lib/cuCdsaUtils.cpp
		lib/cuDbUtils.cpp
		lib/cuEnc64.c
		lib/cuFileIo.c
		lib/cuOidParser.cpp
		lib/cuPem.cpp
		lib/cuPrintCert.cpp
		lib/cuTimeStr.cpp
)
