include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_darling_static_library(security_sd_cspdl FAT
	SOURCES
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
