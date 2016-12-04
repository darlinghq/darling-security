project(security_apple_cspdl)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_apple_cspdl OBJECT
	CSPDLDatabase.cpp
	CSPDLPlugin.cpp
	SSContext.cpp
	SSCSPDLSession.cpp
	SSCSPSession.cpp
	SSDatabase.cpp
	SSDLSession.cpp
	SSFactory.cpp
	SSKey.cpp
	AppleCSPDLBuiltin.cpp
)
