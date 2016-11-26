project(libsecurityd)

cmake_minimum_required(VERSION 2.4.0)
enable_language(C ASM)

if(COMMAND cmake_policy)
	cmake_policy(SET CMP0003 NEW)
	cmake_policy(SET CMP0005 NEW)
endif(COMMAND cmake_policy)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -msse -msse2 -msse3 -w -nostdinc -fblocks")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__DARWIN_UNIX03 -fPIC -w  -include ${CMAKE_CURRENT_SOURCE_DIR}/../../include/security-duct.h")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdinc -nostdinc++ -fblocks -Wno-deprecated -include ${CMAKE_CURRENT_SOURCE_DIR}/../../include/security-duct.h")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -nostdlib -Wl,--version-script=${DARLING_TOP_DIRECTORY}/darwin.map")

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/)
include_directories(${CMAKE_SOURCE_DIR}/src/external/corefoundation/Headers)
include_directories(${CMAKE_BINARY_DIR}/src/external/corefoundation/Headers)
include_directories(${CMAKE_SOURCE_DIR}/src/external/foundation/Headers)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libcxx/include)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libdispatch)
include_directories(${CMAKE_SOURCE_DIR}/src/external/sqlite)
include_directories(${CMAKE_SOURCE_DIR}/src/CommonCrypto)
include_directories(${CMAKE_SOURCE_DIR}/src/libinfo)
include_directories(${CMAKE_SOURCE_DIR}/src/libc/include/FreeBSD)
include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_definitions(-DOBJC2RUNTIME=1)

set(MIG_USER_SOURCE_SUFFIX "User.c")
mig(mig/ucsp.defs)
set(MIG_USER_SOURCE_SUFFIX "User.cpp")
set(MIG_SERVER_SOURCE_SUFFIX "Server.cpp")
mig(mig/cshosting.defs)
mig(mig/ucsp.defs)
mig(mig/ucspNotify.defs)

set(security_libsecurityd_sources
	${CMAKE_CURRENT_BINARY_DIR}/mig/ucspServer.cpp
	${CMAKE_CURRENT_BINARY_DIR}/mig/ucspUser.cpp
	${CMAKE_CURRENT_BINARY_DIR}/mig/ucspUser.c
	${CMAKE_CURRENT_BINARY_DIR}/mig/ucspNotifyServer.cpp
	${CMAKE_CURRENT_BINARY_DIR}/mig/ucspNotifyUser.cpp
	${CMAKE_CURRENT_BINARY_DIR}/mig/cshostingServer.cpp
	${CMAKE_CURRENT_BINARY_DIR}/mig/cshostingUser.cpp
	lib/dictionary.cpp
	lib/eventlistener.cpp
	lib/sec_xdr_array.c
	lib/sec_xdr.c
	lib/sec_xdrmem.c
	lib/sec_xdr_reference.c
	lib/sec_xdr_sizeof.c
	lib/SharedMemoryClient.cpp
	lib/ssblob.cpp
	lib/ssclient.cpp
	lib/sstransit.cpp
	lib/transition.cpp
	lib/xdr_auth.c
	lib/xdr_cssm.c
	lib/xdr_dldb.cpp
)

add_library(securityd STATIC ${security_libsecurityd_sources})

