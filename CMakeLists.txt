project(Security)

set(CMAKE_CXX_STANDARD 14)

add_compile_options(
	-Wno-gcc-compat
	-Wno-ignored-attributes
	#-Wno-unused-command-line-argument
	-Wno-c++11-extensions
	-Wno-error=c++11-narrowing
)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -nostdinc")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdinc")

add_definitions(
	-DNDEBUG=1
	-D__KEYCHAINCORE__=1
	-DOSSPINLOCK_USE_INLINED=0
	-DDTRACE_PROBES_DISABLED
)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/securityd/securityd_service/KeyStore
	${CMAKE_CURRENT_SOURCE_DIR}/OSX/trustd
	${CMAKE_CURRENT_SOURCE_DIR}/OSX/authd
	${CMAKE_CURRENT_SOURCE_DIR}/OSX/security_dotmac_tp/lib
	${CMAKE_CURRENT_SOURCE_DIR}/cssm
	${CMAKE_CURRENT_SOURCE_DIR}/keychain
	${CMAKE_CURRENT_SOURCE_DIR}/base
	${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurity_asn1
	${CMAKE_CURRENT_SOURCE_DIR}/OSX/utilities
	${CMAKE_CURRENT_SOURCE_DIR}/OSX/utilities/src
	${CMAKE_CURRENT_SOURCE_DIR}/sectask
	${CMAKE_CURRENT_SOURCE_DIR}/trust
	${CMAKE_CURRENT_SOURCE_DIR}/internal-include
	${CMAKE_CURRENT_SOURCE_DIR}/gen/include
)

add_subdirectory(OSX)
