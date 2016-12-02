project(libsecurity_cssm)

cmake_minimum_required(VERSION 2.4.0)
enable_language(C ASM)

if(COMMAND cmake_policy)
	cmake_policy(SET CMP0003 NEW)
	cmake_policy(SET CMP0005 NEW)
endif(COMMAND cmake_policy)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -msse -msse2 -msse3 -w -nostdinc -fblocks")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__DARWIN_UNIX03 -fPIC -w")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdinc -nostdinc++ -fblocks -Wno-deprecated -fPIC")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -nostdlib -Wl,--version-script=${DARLING_TOP_DIRECTORY}/darwin.map")

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../derived_src)
include_directories(${CMAKE_SOURCE_DIR}/src/external/corefoundation/Headers)
include_directories(${CMAKE_BINARY_DIR}/src/external/corefoundation/Headers)
include_directories(${CMAKE_SOURCE_DIR}/src/external/foundation/Headers)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libcxx/include)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libdispatch)
include_directories(${CMAKE_SOURCE_DIR}/src/CommonCrypto)

add_definitions(-DOBJC2RUNTIME=1)

set(security_cssm_sources
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

add_library(security_cssm OBJECT ${security_cssm_sources})

