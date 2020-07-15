project(libsecurity_translocate)

add_macos_legacy_lib(security_translocate
	SOURCES
		lib/SecTranslocate.cpp
		lib/SecTranslocateClient.cpp
		lib/SecTranslocateDANotification.cpp
		lib/SecTranslocateInterface.cpp
		lib/SecTranslocateLSNotification.cpp
		lib/SecTranslocateServer.cpp
		lib/SecTranslocateShared.cpp
		lib/SecTranslocateUtilities.cpp
		lib/SecTranslocateXPCServer.cpp
)
