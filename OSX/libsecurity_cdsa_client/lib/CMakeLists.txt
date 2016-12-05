project(security_cdsa_client)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_cdsa_client OBJECT
	aclclient.cpp
	clclient.cpp
	cryptoclient.cpp
	cspclient.cpp
	cssmclient.cpp
	dlclient.cpp
	DLDBList.cpp
	genkey.cpp
	keychainacl.cpp
	keyclient.cpp
	macclient.cpp
	multidldb.cpp
	securestorage.cpp
	signclient.cpp
	tpclient.cpp
	wrapkey.cpp
	mdsclient.cpp
	mds_standard.cpp
	dlquery.cpp
	dlclientpriv.cpp
	dliterators.cpp
	dl_standard.cpp
)
