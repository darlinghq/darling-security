project(libsecurity_utilities)

cmake_minimum_required(VERSION 2.4.0)
enable_language(C ASM)

if(COMMAND cmake_policy)
	cmake_policy(SET CMP0003 NEW)
	cmake_policy(SET CMP0005 NEW)
endif(COMMAND cmake_policy)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -msse -msse2 -msse3 -w -nostdinc -fblocks")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__DARWIN_UNIX03 -fPIC -w")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdinc -nostdinc++ -fblocks -fPIC -Wno-deprecated -include ${CMAKE_CURRENT_SOURCE_DIR}/../../../include/security-duct.h -include ${CMAKE_CURRENT_SOURCE_DIR}/../dtrace_fake.h")
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
include_directories(${CMAKE_SOURCE_DIR}/src/CoreServices)

add_definitions(-DOBJC2RUNTIME=1)

set(security_utilities_sources
	adornments.cpp
	alloc.cpp
	blob.cpp
	bufferfifo.cpp
	buffers.cpp
	ccaudit.cpp
	cfclass.cpp
	cfmach++.cpp
	cfmunge.cpp
	cfutilities.cpp
	coderepository.cpp
	daemon.cpp
	debugging.cpp
	debugging_internal.cpp
	devrandom.cpp
	#dispatch.cpp
	dyldcache.cpp
	endian.cpp
	errors.cpp
	fdmover.cpp
	fdsel.cpp
	globalizer.cpp
	hashing.cpp
	headermap.cpp
	hosts.cpp
	inetreply.cpp
	#iodevices.cpp
	ip++.cpp
	kq++.cpp
	logging.cpp
	mach++.cpp
	macho++.cpp
	machrunloopserver.cpp
	machserver.cpp
	#muscle++.cpp
	osxcode.cpp
	#pcsc++.cpp
	#powerwatch.cpp
	seccfobject.cpp
	selector.cpp
	simpleprefs.cpp
	socks++.cpp
	socks++4.cpp
	socks++5.cpp
	sqlite++.cpp
	streams.cpp
	superblob.cpp
	threading.cpp
	timeflow.cpp
	tqueue.cpp
	trackingallocator.cpp
	transactions.cpp
	typedvalue.cpp
	unix++.cpp
	unixchild.cpp
	url.cpp
	utilities.cpp
	vproc++.cpp
)

add_library(security_utilities OBJECT ${security_utilities_sources})

