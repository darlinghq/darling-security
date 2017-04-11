project(security_sec)

include_directories(BEFORE
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/ipc
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/Regressions
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/SecureObjectSync
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/CKBridge
	${CMAKE_CURRENT_SOURCE_DIR}/Security
)

add_library(sec_item_shim OBJECT
	Security/SecItemBackup.c
	Security/SecItem.c
	Security/SecDH.c
	SOSCircle/SecureObjectSync/SOSCloudCircle.c
	Security/SecAccessControl.c
	Security/SecuritydXPC.c
	SOSCircle/osxshim.c
	Security/SecItemConstants.c
	Security/SecPasswordGenerate.c
)

target_compile_definitions(sec_item_shim PRIVATE -DSECITEM_SHIM_OSX=1)
