project(security_cdsa_utils)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_cdsa_utils OBJECT
	cuCdsaUtils.cpp
	cuDbUtils.cpp
	#cuEnc64.c 	multiple definition?
	#cuFileIo.c 	multiple definition?
	cuOidParser.cpp
	cuPem.cpp
	cuPrintCert.cpp
	cuTimeStr.cpp
)

# Not sure why to do this, but it's here because Apple does it
set_property(SOURCE
	cuCdsaUtils.cpp
	cuDbUtils.cpp
	cuOidParser.cpp
	cuPem.cpp
	cuPrintCert.cpp
	cuTimeStr.cpp

	PROPERTY COMPILE_FLAGS "-fno-rtti -fno-exceptions"
)
