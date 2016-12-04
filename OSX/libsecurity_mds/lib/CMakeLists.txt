project(security_mds)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
)

add_library(security_mds OBJECT
	mdsapi.cpp
	MDSAttrParser.cpp
	MDSAttrStrings.cpp
	MDSAttrUtils.cpp
	MDSDatabase.cpp
	MDSDictionary.cpp
	MDSModule.cpp
	MDSPrefs.cpp
	MDSSchema.cpp
	MDSSession.cpp
)
