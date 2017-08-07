include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_darling_static_library(security_mds FAT
	SOURCES
		lib/MDSDictionary.cpp
		lib/MDSDatabase.cpp
		lib/MDSAttrParser.cpp
		lib/MDSSchema.cpp
		lib/MDSModule.cpp
		lib/MDSAttrUtils.cpp
		lib/MDSAttrStrings.cpp
		lib/MDSSession.cpp
		lib/mdsapi.cpp
)
