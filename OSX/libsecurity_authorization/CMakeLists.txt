include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_darling_static_library(security_authorization FAT
	SOURCES
		lib/trampolineServer.cpp
		lib/Authorization++.cpp
		lib/Authorization.c
		../authd/authutilities.c
		lib/trampolineClient.cpp
)
