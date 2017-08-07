include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_darling_static_library(security_cdsa_plugin FAT
	SOURCES
		lib/ACabstractsession.cpp
		lib/CSPabstractsession.cpp
		lib/DLabstractsession.cpp
		lib/DatabaseSession.cpp
		lib/CSPsession.cpp
		lib/csputilities.cpp
		lib/DbContext.cpp
		lib/Database.cpp
		lib/pluginsession.cpp
		lib/cssmplugin.cpp
		lib/TPabstractsession.cpp
		lib/DLsession.cpp
		lib/CLabstractsession.cpp
)
