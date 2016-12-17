project(Security)

cmake_minimum_required(VERSION 2.4.0)

enable_language(C ASM)

if(COMMAND cmake_policy)
	cmake_policy(SET CMP0003 NEW)
	cmake_policy(SET CMP0005 NEW)
endif(COMMAND cmake_policy)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -msse -msse2 -msse3 -nostdinc -fblocks -fPIC")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -msse -msse2 -msse3 -nostdinc -nostdinc++ -fblocks -fPIC")

set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -nostdlib -Wl,--version-script=${DARLING_TOP_DIRECTORY}/darwin.map")

add_definitions(
	-D__APPLE_CPP__
	-D__DARWIN_UNIX03
	-DOBJC2RUNTIME=1
)

SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/darling")
SET(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/include
	${CMAKE_CURRENT_SOURCE_DIR}/include/Security
)

# Leaving these here for now because they lack build scripts of their own
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/authd)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurity_dotmac_tp/lib)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurityd)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/sec)

include_directories(
	${CMAKE_SOURCE_DIR}/src/external/corefoundation/Headers
	${CMAKE_BINARY_DIR}/src/external/corefoundation/Headers
	${CMAKE_SOURCE_DIR}/src/external/foundation/Headers
	${CMAKE_SOURCE_DIR}/src/external/libobjc2/objc
	${CMAKE_SOURCE_DIR}/src/external/libobjc2
	${CMAKE_SOURCE_DIR}/src/external/libauto
	${CMAKE_SOURCE_DIR}/src/external/zlib
	${CMAKE_SOURCE_DIR}/src/external/libcxx/include
	${CMAKE_SOURCE_DIR}/src/external/libdispatch
	${CMAKE_SOURCE_DIR}/src/external/openpam/include
	${CMAKE_SOURCE_DIR}/src/CommonCrypto
	${CMAKE_SOURCE_DIR}/src/external/commoncrypto/include
	${CMAKE_SOURCE_DIR}/src/external/corecrypto/include
	${CMAKE_SOURCE_DIR}/src/copyfile
	${CMAKE_SOURCE_DIR}/src/external/openssl/src/include
	${CMAKE_SOURCE_DIR}/src/external/libxpc
	${CMAKE_SOURCE_DIR}/kernel-include/iokit
	${CMAKE_SOURCE_DIR}/src/external/IOKitUser
	${CMAKE_SOURCE_DIR}/src/sandbox
	${CMAKE_SOURCE_DIR}/src/launchd/liblaunch
	${CMAKE_SOURCE_DIR}/src/libc/darwin
	${CMAKE_SOURCE_DIR}/src/external/sqlite
	${CMAKE_SOURCE_DIR}/src/CFF
	${CMAKE_SOURCE_DIR}/src/libc/include/FreeBSD
	${CMAKE_SOURCE_DIR}/src/external/libcxxabi/include
	${CMAKE_SOURCE_DIR}/src/CoreServices
	${CMAKE_SOURCE_DIR}/src/external/coretls/lib
	${CMAKE_SOURCE_DIR}/src/OpenScripting
)

add_subdirectory(OSX)
