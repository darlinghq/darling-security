project(security_sec)

include_directories(BEFORE
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/ipc
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/Regressions
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/SecureObjectSync
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/CKBridge
)

add_definitions(
	-DSECTRUST_OSX
	-DSECITEM_SHIM_OSX
)

add_library(sec_item_shim OBJECT
	Security/SecItemBackup.c
	#Security/SecItem.c				FIXME: CoreFoundation issues
	#Security/SecDH.c				FIXME: corecrypto/ccdh.h
	SOSCircle/SecureObjectSync/SOSCloudCircle.c
	#Security/SecAccessControl.c			FIXME: CoreFoundation issues
	#Security/SecuritydXPC.c			FIXME: CoreFoundation issues
	SOSCircle/osxshim.c
	Security/SecItemConstants.c
	Security/SecPasswordGenerate.c
)
