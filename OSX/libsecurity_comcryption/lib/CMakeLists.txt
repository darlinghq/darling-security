project(security_comcryption)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_comcryption OBJECT
	comcryption.c
	comcryptPriv.c
)
