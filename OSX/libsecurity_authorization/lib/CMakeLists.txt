project(libsecurity_authorization)

cmake_minimum_required(VERSION 2.4.0)
enable_language(C ASM)

if(COMMAND cmake_policy)
	cmake_policy(SET CMP0003 NEW)
	cmake_policy(SET CMP0005 NEW)
endif(COMMAND cmake_policy)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -msse -msse2 -msse3 -w -nostdinc -fblocks")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__DARWIN_UNIX03 -fPIC -w")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdinc -nostdinc++ -fblocks -fPIC -Wno-deprecated -include ${CMAKE_CURRENT_SOURCE_DIR}/../../../include/security-duct.h")

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_SOURCE_DIR}/src/external/libcxx/include)

add_definitions(-DOBJC2RUNTIME=1)

set(security_authorization_sources
	Authorization.cpp
	trampolineClient.cpp
	trampolineServer.cpp
	Authorization.c
)

add_library(security_authorization OBJECT ${security_authorization_sources})

