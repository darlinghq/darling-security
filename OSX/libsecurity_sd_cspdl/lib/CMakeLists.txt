project(security_sd_cspdl)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_sd_cspdl OBJECT
	SDContext.cpp
	SDCSPDLBuiltin.cpp
	SDCSPDLDatabase.cpp
	SDCSPDLPlugin.cpp
	SDCSPDLSession.cpp
	SDCSPSession.cpp
	SDDLSession.cpp
	SDFactory.cpp
	SDKey.cpp
)
