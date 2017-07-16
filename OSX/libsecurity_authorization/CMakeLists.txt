include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_library(libsecurity_authorization OBJECT
	lib/trampolineServer.cpp
	lib/Authorization++.cpp
	lib/Authorization.c
	../authd/authutilities.c
	lib/trampolineClient.cpp
)
make_fat(libsecurity_authorization)
