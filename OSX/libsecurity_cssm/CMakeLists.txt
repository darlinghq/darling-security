include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_darling_static_library(security_cssm FAT
	SOURCES
		lib/attachment.cpp
		lib/modloader.cpp
		lib/cspattachment.cpp
		lib/cssmcontext.cpp
		lib/oidsalg.c
		lib/modload_plugin.cpp
		lib/oidscrl.cpp
		lib/attachfactory.cpp
		lib/cssmmds.cpp
		lib/modload_static.cpp
		lib/transition.cpp
		lib/cssm.cpp
		lib/oidscert.cpp
		lib/module.cpp
		lib/guids.cpp
		lib/manager.cpp
)
