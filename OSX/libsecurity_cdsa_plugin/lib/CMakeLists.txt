project(security_cdsa_plugin)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_cdsa_plugin OBJECT
	CSPsession.cpp
	csputilities.cpp
	cssmplugin.cpp
	Database.cpp
	DatabaseSession.cpp
	DbContext.cpp
	DLsession.cpp
	pluginsession.cpp
	ACabstractsession.cpp
	CLabstractsession.cpp
	CSPabstractsession.cpp
	DLabstractsession.cpp
	TPabstractsession.cpp
)
