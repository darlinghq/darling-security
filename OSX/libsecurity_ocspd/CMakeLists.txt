project(security_ocspd)

include_directories(
	${CMAKE_CURRENT_BINARY_DIR}/mig
	${CMAKE_CURRENT_SOURCE_DIR}/common
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_BINARY_DIR}/mig
)

mig(mig/ocspd.defs)

add_library(libsecurity_ocspd OBJECT
	${CMAKE_CURRENT_BINARY_DIR}/mig/ocspdUser.c
	client/ocspdClient.cpp
	common/ocspResponse.cpp
	common/ocspExtensions.cpp
	common/ocspdUtils.cpp
	common/ocspdDbSchema.cpp
	${CMAKE_CURRENT_BINARY_DIR}/mig/ocspdServer.c
)

