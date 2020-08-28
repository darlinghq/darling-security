project(libsecurity_ocspd)

set(MIG_USER_SOURCE_SUFFIX "_client.cpp")
set(MIG_SERVER_SOURCE_SUFFIX "_server.cpp")
mig(mig/ocspd.defs)

target_include_directories(ocspd_xtrace_mig PRIVATE
	${SECURITY_PROJECT_DIR}/OSX/libsecurity_cssm/lib
	${SECURITY_PROJECT_DIR}/OSX/include
	${SECURITY_PROJECT_DIR}/OSX/utilities/src
	${SECURITY_PROJECT_DIR}/OSX/libsecurity_apple_csp/open_ssl
	${SECURITY_PROJECT_DIR}/OSX/libsecurity_ocspd/lib
)

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
