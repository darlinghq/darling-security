project(libsecurityd)

include_directories(${CMAKE_CURRENT_BINARY_DIR}/mig)

set(MIG_USER_SOURCE_SUFFIX "Client.cpp")
set(MIG_SERVER_SOURCE_SUFFIX "Server.cpp")
mig(mig/ucsp.defs)

set(MIG_USER_SOURCE_SUFFIX "Sender.cpp")
set(MIG_SERVER_SOURCE_SUFFIX "Receiver.cpp")
mig(mig/ucspNotify.defs)

file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/mig")
file(CREATE_LINK "ucspClient.cpp" "${CMAKE_CURRENT_BINARY_DIR}/mig/ucspClientC.c" SYMBOLIC)

# we don't need to make these depend on their targets because they will alreday be generated
# for the targets that need them
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/mig/securityd_client")
file(CREATE_LINK "../ucsp.h" "${CMAKE_CURRENT_BINARY_DIR}/mig/securityd_client/ucsp.h" SYMBOLIC)
file(CREATE_LINK "../ucspNotify.h" "${CMAKE_CURRENT_BINARY_DIR}/mig/securityd_client/ucspNotify.h" SYMBOLIC)

add_custom_command(
	OUTPUT
		${CMAKE_CURRENT_BINARY_DIR}/mig/ucspClientC.c
	DEPENDS
		${CMAKE_CURRENT_BINARY_DIR}/mig/ucspClient.cpp
	COMMAND
		true
	COMMENT "Generating MIG symlinks for libsecurityd libraries"
)

add_macos_legacy_lib(securityd_client
	SOURCES
		lib/dictionary.cpp
		lib/eventlistener.cpp
		lib/sec_xdr_array.c
		lib/sec_xdr_reference.c
		lib/sec_xdr_sizeof.c
		lib/sec_xdr.c
		lib/sec_xdrmem.c
		lib/SharedMemoryClient.cpp
		lib/ssblob.cpp
		lib/ssclient.cpp
		lib/sstransit.cpp
		lib/transition.cpp
		lib/xdr_auth.c
		lib/xdr_cssm.c
		lib/xdr_dldb.cpp

		${CMAKE_CURRENT_BINARY_DIR}/mig/ucspClient.cpp
		${CMAKE_CURRENT_BINARY_DIR}/mig/ucspNotifySender.cpp
)

add_macos_legacy_lib(securityd_server
	SOURCES
		${CMAKE_CURRENT_BINARY_DIR}/mig/ucspNotifyReceiver.cpp
		${CMAKE_CURRENT_BINARY_DIR}/mig/ucspServer.cpp
)

add_macos_legacy_lib(securityd_ucspc
	SOURCES
		${CMAKE_CURRENT_BINARY_DIR}/mig/ucspClientC.c
)
