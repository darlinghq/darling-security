project(libsecurityd)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_BINARY_DIR}
)


set(MIG_USER_SOURCE_SUFFIX "User.c")
mig(mig/ucsp.defs)
set(MIG_USER_SOURCE_SUFFIX "User.cpp")
set(MIG_SERVER_SOURCE_SUFFIX "Server.cpp")
mig(mig/cshosting.defs)
mig(mig/ucsp.defs)
mig(mig/ucspNotify.defs)

#set(security_libsecurityd_sources
#	${CMAKE_CURRENT_BINARY_DIR}/mig/ucspServer.cpp
#	${CMAKE_CURRENT_BINARY_DIR}/mig/ucspUser.cpp
#	${CMAKE_CURRENT_BINARY_DIR}/mig/ucspUser.c
#	${CMAKE_CURRENT_BINARY_DIR}/mig/ucspNotifyServer.cpp
#	${CMAKE_CURRENT_BINARY_DIR}/mig/ucspNotifyUser.cpp
#	${CMAKE_CURRENT_BINARY_DIR}/mig/cshostingServer.cpp
#	${CMAKE_CURRENT_BINARY_DIR}/mig/cshostingUser.cpp
#	lib/dictionary.cpp
#	lib/eventlistener.cpp
#	lib/sec_xdr_array.c
#	lib/sec_xdr.c
#	lib/sec_xdrmem.c
#	lib/sec_xdr_reference.c
#	lib/sec_xdr_sizeof.c
#	lib/SharedMemoryClient.cpp
#	lib/ssblob.cpp
#	lib/ssclient.cpp
#	lib/sstransit.cpp
#	lib/transition.cpp
#	lib/xdr_auth.c
#	lib/xdr_cssm.c
#	lib/xdr_dldb.cpp
#)

#add_library(securityd STATIC ${security_libsecurityd_sources})

add_library(secutityd_client OBJECT
	lib/SharedMemoryClient.cpp
	lib/eventlistener.cpp
	securityd_client/ucspNotifySender.cpp
	securityd_client/ucspClient.cpp
	lib/dictionary.cpp
	lib/ssblob.cpp
	lib/ssclient.cpp
	lib/sstransit.cpp
	lib/transition.cpp
	lib/xdr_auth.c
	lib/sec_xdr.c
	lib/sec_xdr_array.c
	lib/sec_xdr_reference.c
	lib/sec_xdrmem.c
	lib/xdr_cssm.c
	lib/xdr_dldb.cpp
	lib/sec_xdr_sizeof.c
	${CMAKE_CURRENT_BINARY_DIR}/mig/cshostingServer.cpp
	${CMAKE_CURRENT_BINARY_DIR}/mig/cshostingUser.cpp
)
