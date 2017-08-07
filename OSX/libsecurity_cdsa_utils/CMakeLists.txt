include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_darling_static_library(security_cdsa_utils FAT
	SOURCES
		lib/cuPem.cpp
		lib/cuEnc64.c
		lib/cuCdsaUtils.cpp
		lib/cuDbUtils.cpp
		lib/cuOidParser.cpp
		lib/cuPrintCert.cpp
		lib/cuTimeStr.cpp
		lib/cuFileIo.c
)
