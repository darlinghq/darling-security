include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_library(libsecurity_sd_cspdl OBJECT
	lib/SDCSPSession.cpp
	lib/SDCSPDLDatabase.cpp
	lib/SDDLSession.cpp
	lib/SDContext.cpp
	lib/SDCSPDLSession.cpp
	lib/SDFactory.cpp
	lib/SDKey.cpp
	lib/SDCSPDLPlugin.cpp
	lib/SDCSPDLBuiltin.cpp
)
make_fat(libsecurity_sd_cspdl)
