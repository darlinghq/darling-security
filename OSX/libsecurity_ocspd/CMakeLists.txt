include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/common
)

add_darling_static_library(security_ocspd FAT
	SOURCES
		mig/ocspd_client.cpp
		common/ocspdDbSchema.cpp
		mig/ocspd.defs
		common/ocspResponse.cpp
		mig/ocspd_server.cpp
		client/ocspdClient.cpp
		common/ocspExtensions.cpp
		common/ocspdUtils.cpp
)
