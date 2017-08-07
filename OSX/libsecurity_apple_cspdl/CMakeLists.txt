include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_definitions(
	-DALLOW_ZERO_PASSWORD
	-DCRYPTKIT_CSP_ENABLE
	-DCK_SECURITY_BUILD
	-DASC_CSP_ENABLE
)

add_darling_static_library(security_apple_cspdl FAT
	SOURCES
		lib/SSCSPSession.cpp
		lib/SSDLSession.cpp
		lib/SSKey.cpp
		lib/SSContext.cpp
		lib/SSCSPDLSession.cpp
		lib/CSPDLPlugin.cpp
		lib/SSDatabase.cpp
		lib/CSPDLDatabase.cpp
		lib/SSFactory.cpp
		lib/AppleCSPDLBuiltin.cpp
)
