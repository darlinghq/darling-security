include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/mig
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_darling_static_library(securityd_client FAT
	SOURCES
		lib/dictionary.cpp
		lib/sec_xdr.c
		lib/sec_xdr_array.c
		lib/sec_xdr_reference.c
		lib/sec_xdrmem.c
		lib/sec_xdr_sizeof.c
		lib/xdr_auth.c
		lib/xdr_cssm.c
		lib/xdr_dldb.cpp
		lib/SharedMemoryClient.cpp
		lib/eventlistener.cpp
		lib/ssblob.cpp
		lib/ssclient.cpp
		lib/sstransit.cpp
		lib/transition.cpp
		mig/ucspClient.cpp
		mig/ucspNotifySender.cpp
		mig/cshostingClient.cpp
		mig/cshostingServer.cpp
)

add_darling_static_library(securityd_server FAT
	SOURCES
		mig/ucspNotifyReceiver.cpp
		mig/ucspServer.cpp
)
