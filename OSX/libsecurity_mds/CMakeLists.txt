project(libsecurity_mds)

add_macos_legacy_lib(security_mds
	SOURCES
		lib/mdsapi.cpp
		lib/MDSAttrParser.cpp
		lib/MDSAttrStrings.cpp
		lib/MDSAttrUtils.cpp
		lib/MDSDatabase.cpp
		lib/MDSDictionary.cpp
		lib/MDSModule.cpp
		lib/MDSSchema.cpp
		lib/MDSSession.cpp
)
