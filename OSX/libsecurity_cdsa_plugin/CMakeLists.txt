project(libsecurity_cdsa_plugin)

add_macos_legacy_lib(security_cdsa_plugin
	SOURCES
		lib/ACabstractsession.cpp
		lib/CLabstractsession.cpp
		lib/CSPabstractsession.cpp
		lib/CSPsession.cpp
		lib/csputilities.cpp
		lib/cssmplugin.cpp
		lib/Database.cpp
		lib/DatabaseSession.cpp
		lib/DbContext.cpp
		lib/DLabstractsession.cpp
		lib/DLsession.cpp
		lib/pluginsession.cpp
		lib/TPabstractsession.cpp
)
