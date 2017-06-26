include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_library(libsecurity_cdsa_plugin OBJECT
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
make_fat(libsecurity_cdsa_plugin)
