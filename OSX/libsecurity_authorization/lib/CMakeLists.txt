project(libsecurity_authorization)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_authorization OBJECT
	Authorization.cpp
	trampolineClient.cpp
	trampolineServer.cpp
	AuthorizationC.c
)

set_property(TARGET security_authorization PROPERTY COMPILE_FLAGS "-include security-duct.h")
