project(libsecurity_ocspd)

set(MIG_USER_SOURCE_SUFFIX "_client.cpp")
set(MIG_SERVER_SOURCE_SUFFIX "_server.cpp")
mig(mig/ocspd.defs)

add_macos_legacy_lib(security_ocspd
	SOURCES
		client/ocspdClient.cpp
		common/ocspdDbSchema.cpp
		common/ocspdUtils.cpp
		common/ocspExtensions.cpp
		common/ocspResponse.cpp

		${CMAKE_CURRENT_BINARY_DIR}/mig/ocspd_client.cpp
		${CMAKE_CURRENT_BINARY_DIR}/mig/ocspd_server.cpp

	INCLUDES
		${CMAKE_CURRENT_BINARY_DIR}/mig
		${CMAKE_CURRENT_SOURCE_DIR}/common
)
