project(libsecurity_authorization)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
)

add_library(libsecurity_authorization STATIC
	Authorization.c
	Authorization.cpp
	trampolineClient.cpp
	trampolineServer.cpp
	../../authd/authutilities.c
)
