project(libsecurity_asn1)

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
include_directories(${CMAKE_SOURCE_DIR}/src/external/corefoundation/Headers)
include_directories(${CMAKE_BINARY_DIR}/src/external/corefoundation/Headers)
include_directories(${CMAKE_SOURCE_DIR}/src/external/foundation/Headers)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libcxx/include)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libdispatch)
include_directories(${CMAKE_SOURCE_DIR}/src/external/corecrypto)
include_directories(${CMAKE_SOURCE_DIR}/src/CommonCrypto)

add_definitions(-DOBJC2RUNTIME=1)

set(security_asn1_sources
	certExtensionTemplates.c
	csrTemplates.c
	keyTemplates.c
	nameTemplates.c
	nsprPortX.c
	nssUtils.c
	ocspTemplates.c
	oidsalg.c
	oidsattr.c
	oidsocsp.c
	osKeyTemplates.c
	pkcs12Templates.c
	pkcs7Templates.c
	plarena.c
	SecAsn1Coder.c
	secasn1d.c
	secasn1e.c
	SecAsn1Templates.c
	secasn1u.c
	secErrorStr.c
	SecNssCoder.cpp
	secport.c
	X509Templates.c
)

add_library(security_asn1 OBJECT ${security_asn1_sources})

