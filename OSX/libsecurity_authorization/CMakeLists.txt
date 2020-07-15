project(libsecurity_authorization)

add_macos_legacy_lib(security_authorization
	SOURCES
		../authd/authutilities.c
		lib/Authorization.c
		lib/Authorization.cpp
		lib/trampolineClient.cpp
		lib/trampolineServer.cpp
	INCLUDES
		${CMAKE_CURRENT_SOURCE_DIR}/../authd
)
