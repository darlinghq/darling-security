project(libsecurity_sd_cspdl)

add_macos_legacy_lib(security_sd_cspdl
	SOURCES
		lib/SDContext.cpp
		lib/SDCSPDLBuiltin.cpp
		lib/SDCSPDLDatabase.cpp
		lib/SDCSPDLPlugin.cpp
		lib/SDCSPDLSession.cpp
		lib/SDCSPSession.cpp
		lib/SDDLSession.cpp
		lib/SDFactory.cpp
		lib/SDKey.cpp
)
