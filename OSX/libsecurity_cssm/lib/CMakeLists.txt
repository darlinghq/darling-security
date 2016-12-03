project(libsecurity_cssm)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/..
)

add_library(security_cssm OBJECT
	attachfactory.cpp
	attachment.cpp
	cspattachment.cpp
	cssmcontext.cpp
	cssm.cpp
	cssmmds.cpp
	guids.cpp
	manager.cpp
	modloader.cpp
	modload_plugin.cpp
	modload_static.cpp
	module.cpp
	oidscert.cpp
	oidscrl.cpp
	transition.cpp
)
