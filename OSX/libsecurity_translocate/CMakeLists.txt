add_library(libsecurity_translocate OBJECT
	lib/SecTranslocate.cpp
	lib/SecTranslocateShared.cpp
	lib/SecTranslocateLSNotification.cpp
	lib/SecTranslocateUtilities.cpp
	lib/SecTranslocateDANotification.cpp
	lib/SecTranslocateServer.cpp
	lib/SecTranslocateInterface.cpp
	lib/SecTranslocateClient.cpp
	lib/SecTranslocateXPCServer.cpp
)
make_fat(libsecurity_translocate)
