project(Security)

cmake_minimum_required(VERSION 2.4.0)

if(COMMAND cmake_policy)
	cmake_policy(SET CMP0003 NEW)
	cmake_policy(SET CMP0005 NEW)
endif(COMMAND cmake_policy)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -nostdinc -fblocks -fPIC")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdinc -nostdinc++ -fblocks")

set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -nostdlib -Wl,--version-script=${DARLING_TOP_DIRECTORY}/darwin.map")

add_definitions(
	-D__APPLE_CPP__
	-D__DARWIN_UNIX03
	-DOBJC2RUNTIME=1
)

SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/darling")
SET(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE) 
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurity_keychain)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurity_cssm)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurity_cdsa_utilities)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurity_cdsa_client)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurity_utilities)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurity_codesigning)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurity_asn1)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurity_authorization)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/authd)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurity_dotmac_tp/lib)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurityd)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/sec)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurity_keychain/libDER)
include_directories(${CMAKE_SOURCE_DIR}/src/copyfile)
include_directories(${CMAKE_SOURCE_DIR}/src/external/openssl/src/include)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libxpc)
include_directories(${CMAKE_SOURCE_DIR}/src/external/corecrypto/include)
include_directories(${CMAKE_SOURCE_DIR}/src/sandbox)
include_directories(${CMAKE_SOURCE_DIR}/src/launchd/liblaunch)
include_directories(${CMAKE_SOURCE_DIR}/src/libc/darwin)
include_directories(
	${CMAKE_SOURCE_DIR}/src/external/corefoundation/Headers
	${CMAKE_BINARY_DIR}/src/external/corefoundation/Headers
	${CMAKE_SOURCE_DIR}/src/external/foundation/Headers
	${CMAKE_SOURCE_DIR}/src/external/libobjc2/objc
)
add_subdirectory(OSX)
