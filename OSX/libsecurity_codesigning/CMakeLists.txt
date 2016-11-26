project(libsecurity_codesigning)

cmake_minimum_required(VERSION 2.4.0)
enable_language(C ASM)

if(COMMAND cmake_policy)
	cmake_policy(SET CMP0003 NEW)
	cmake_policy(SET CMP0005 NEW)
endif(COMMAND cmake_policy)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -msse -msse2 -msse3 -w -nostdinc -fblocks")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__DARWIN_UNIX03 -fPIC -w")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdinc -nostdinc++ -fblocks -Wno-deprecated -include ${CMAKE_CURRENT_SOURCE_DIR}/../../include/security-duct.h")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -nostdlib -Wl,--version-script=${DARLING_TOP_DIRECTORY}/darwin.map")

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/antlr2)
include_directories(${CMAKE_SOURCE_DIR}/src/external/corefoundation/Headers)
include_directories(${CMAKE_BINARY_DIR}/src/external/corefoundation/Headers)
include_directories(${CMAKE_SOURCE_DIR}/src/external/foundation/Headers)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libcxx/include)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libdispatch)
include_directories(${CMAKE_SOURCE_DIR}/src/external/sqlite)
include_directories(${CMAKE_SOURCE_DIR}/src/CommonCrypto)
include_directories(${CMAKE_SOURCE_DIR}/src/OpenScripting)
include_directories(${CMAKE_CURRENT_BINARY_DIR}/../libsecurityd)
include_directories(${CMAKE_SOURCE_DIR}/src/libc/include/FreeBSD)

add_definitions(-DOBJC2RUNTIME=1)

set(security_codesigning_sources
	lib/antlrplugin.cpp
	lib/bundlediskrep.cpp
	lib/cdbuilder.cpp
	lib/Code.cpp
	lib/codedirectory.cpp
	lib/CodeSigner.cpp
	lib/cs.cpp
	lib/csdatabase.cpp
	lib/cserror.cpp
	lib/csgeneric.cpp
	lib/cskernel.cpp
	lib/csprocess.cpp
	lib/csutilities.cpp
	lib/detachedrep.cpp
	lib/dirscanner.cpp
	lib/diskrep.cpp
	lib/drmaker.cpp
	lib/evaluationmanager.cpp
	lib/filediskrep.cpp
	lib/kerneldiskrep.cpp
	lib/machorep.cpp
	lib/opaquewhitelist.cpp
	lib/piddiskrep.cpp
	lib/policydb.cpp
	lib/policyengine.cpp
	lib/quarantine++.cpp
	lib/reqdumper.cpp
	lib/reqinterp.cpp
	lib/reqmaker.cpp
	lib/reqparser.cpp
	lib/reqreader.cpp
	lib/requirement.cpp
	lib/RequirementLexer.cpp
	lib/RequirementParser.cpp
	lib/Requirements.cpp
	lib/resources.cpp
	lib/SecAssessment.cpp
	lib/SecCode.cpp
	lib/SecCodeHost.cpp
	lib/SecCodeSigner.cpp
	lib/SecIntegrity.cpp
	lib/SecRequirement.cpp
	lib/SecStaticCode.cpp
	lib/sigblob.cpp
	lib/signer.cpp
	lib/signerutils.cpp
	lib/singlediskrep.cpp
	lib/slcrep.cpp
	lib/StaticCode.cpp
	lib/xar++.cpp
	lib/xpcengine.cpp

)

add_library(security_codesigning STATIC ${security_codesigning_sources})

