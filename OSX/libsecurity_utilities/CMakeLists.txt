project(libsecurity_utilities)

cmake_minimum_required(VERSION 2.4.0)
enable_language(C ASM)

if(COMMAND cmake_policy)
	cmake_policy(SET CMP0003 NEW)
	cmake_policy(SET CMP0005 NEW)
endif(COMMAND cmake_policy)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -msse -msse2 -msse3 -w -nostdinc -fblocks")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__DARWIN_UNIX03 -fPIC -w")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdinc -nostdinc++ -fblocks -fPIC -Wno-deprecated -include ${CMAKE_CURRENT_SOURCE_DIR}/../../include/security-duct.h")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -nostdlib -Wl,--version-script=${DARLING_TOP_DIRECTORY}/darwin.map")

add_definitions(-D__strong=)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/)
include_directories(${CMAKE_SOURCE_DIR}/src/external/corefoundation/Headers)
include_directories(${CMAKE_BINARY_DIR}/src/external/corefoundation/Headers)
include_directories(${CMAKE_SOURCE_DIR}/src/external/foundation/Headers)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libcxx/include)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libdispatch)
include_directories(${CMAKE_SOURCE_DIR}/src/external/sqlite)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libauto)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libobjc2)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libcxxabi/include)
include_directories(${CMAKE_SOURCE_DIR}/src/CommonCrypto)
include_directories(${CMAKE_SOURCE_DIR}/src/libc/include/FreeBSD)

add_definitions(-DOBJC2RUNTIME=1)

set(security_utilities_sources
	lib/adornments.cpp
	lib/alloc.cpp
	lib/blob.cpp
	lib/bufferfifo.cpp
	lib/buffers.cpp
	lib/ccaudit.cpp
	lib/cfclass.cpp
	lib/cfmach++.cpp
	lib/cfmunge.cpp
	lib/cfutilities.cpp
	lib/coderepository.cpp
	lib/daemon.cpp
	lib/debugging.cpp
	lib/debugging_internal.cpp
	lib/devrandom.cpp
	lib/dispatch.cpp
	lib/dyldcache.cpp
	lib/endian.cpp
	lib/errors.cpp
	lib/fdmover.cpp
	lib/fdsel.cpp
	lib/globalizer.cpp
	lib/hashing.cpp
	lib/headermap.cpp
	lib/hosts.cpp
	lib/inetreply.cpp
	lib/iodevices.cpp
	lib/ip++.cpp
	lib/kq++.cpp
	lib/logging.cpp
	lib/mach++.cpp
	lib/macho++.cpp
	lib/machrunloopserver.cpp
	lib/machserver.cpp
	lib/muscle++.cpp
	lib/osxcode.cpp
	lib/pcsc++.cpp
	lib/powerwatch.cpp
	lib/seccfobject.cpp
	lib/selector.cpp
	lib/simpleprefs.cpp
	lib/socks++.cpp
	lib/socks++4.cpp
	lib/socks++5.cpp
	lib/sqlite++.cpp
	lib/streams.cpp
	lib/superblob.cpp
	lib/threading.cpp
	lib/timeflow.cpp
	lib/tqueue.cpp
	lib/trackingallocator.cpp
	lib/transactions.cpp
	lib/typedvalue.cpp
	lib/unix++.cpp
	lib/unixchild.cpp
	lib/url.cpp
	lib/utilities.cpp
	lib/vproc++.cpp
)

add_library(security_utilities OBJECT ${security_utilities_sources})

