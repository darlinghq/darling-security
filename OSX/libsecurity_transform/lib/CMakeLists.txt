project(libsecurity_transform)

cmake_minimum_required(VERSION 2.4.0)
enable_language(C ASM)

if(COMMAND cmake_policy)
	cmake_policy(SET CMP0003 NEW)
	cmake_policy(SET CMP0005 NEW)
endif(COMMAND cmake_policy)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -msse -msse2 -msse3 -w -nostdinc -fblocks")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__DARWIN_UNIX03 -fPIC -w -include ${CMAKE_CURRENT_SOURCE_DIR}/../forceinclude.h")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdinc -nostdinc++ -fblocks -Wno-deprecated -fPIC -include ${CMAKE_CURRENT_SOURCE_DIR}/../forceinclude.h")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -nostdlib -Wl,--version-script=${DARLING_TOP_DIRECTORY}/darwin.map")

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)
include_directories(${CMAKE_SOURCE_DIR}/src/external/corefoundation/Headers)
include_directories(${CMAKE_BINARY_DIR}/src/external/corefoundation/Headers)
include_directories(${CMAKE_SOURCE_DIR}/src/external/foundation/Headers)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libcxx/include)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libdispatch)
include_directories(${CMAKE_SOURCE_DIR}/src/external/corecrypto)
include_directories(${CMAKE_SOURCE_DIR}/src/external/zlib)
include_directories(${CMAKE_SOURCE_DIR}/src/CommonCrypto)

add_definitions(-DOBJC2RUNTIME=1)

set(security_transform_sources
	CEncryptDecrypt.c
	CoreFoundationBasics.cpp
	c++utils.cpp
	Digest.cpp
	EncodeDecodeTransforms.c
	EncryptTransform.cpp
	EncryptTransformUtilities.cpp
	GroupTransform.cpp
	LinkedList.cpp
	misc.c
	Monitor.cpp
	NullTransform.cpp
	SecCollectTransform.cpp
	SecCustomTransform.cpp
	SecDigestTransform.cpp
	SecEncryptTransform.cpp
	SecExternalSourceTransform.cpp
	SecGroupTransform.cpp
	SecMaskGenerationFunctionTransform.c
	SecNullTransform.cpp
	SecSignVerifyTransform.c
	SecTransform.cpp
	SecTransformReadTransform.cpp
	SingleShotSource.cpp
	Source.cpp
	StreamSource.cpp
	Transform.cpp
	TransformFactory.cpp
	Utilities.cpp
)

add_library(security_transform OBJECT ${security_transform_sources})

