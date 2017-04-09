project(security_sec)

include_directories(BEFORE
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/ipc
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/Regressions
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/SecureObjectSync
	${CMAKE_CURRENT_SOURCE_DIR}/SOSCircle/CKBridge
	${CMAKE_CURRENT_SOURCE_DIR}/Security
)

add_definitions(
	-DSECTRUST_OSX
	-DSECITEM_SHIM_OSX
	-DMULTIPLE_KEYCHAINS
)

add_library(sec_item_shim OBJECT
	Security/SecItemBackup.c
	Security/SecItem.c				# FIXME: CoreFoundation issues
	#Security/SecDH.c				FIXME: corecrypto/ccdh.h
	SOSCircle/SecureObjectSync/SOSCloudCircle.c
	# Security/SecAccessControl.c		#	FIXME: requires ACM
	Security/SecCertificate.c
	Security/SecuritydXPC.c
	SOSCircle/osxshim.c
	Security/SecItemConstants.c
	Security/SecPasswordGenerate.c
)
