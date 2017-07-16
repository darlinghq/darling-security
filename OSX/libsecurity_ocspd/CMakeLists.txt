include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/common
)

add_library(libsecurity_ocspd OBJECT
	mig/ocspd_client.cpp
	common/ocspdDbSchema.cpp
	mig/ocspd.defs
	common/ocspResponse.cpp
	mig/ocspd_server.cpp
	client/ocspdClient.cpp
	common/ocspExtensions.cpp
	common/ocspdUtils.cpp
)
make_fat(libsecurity_ocspd)
