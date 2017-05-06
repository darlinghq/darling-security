project(Security)

add_compile_options(
	-fconstant-cfstrings
	-fblocks
	-nostdinc
	-nostdinc++
#	-fobjc-arc
)

add_definitions(
	-D__APPLE_CPP__
	-D__DARWIN_UNIX03
	-Dnil=NULL
	-DTARGET_HAS_KEYSTORE=0
	-DTARGET_OS_OSX=1
	-DNDEBUG=1
	-D__KEYCHAINCORE__=1
	-DOSSPINLOCK_USE_INLINED=0
)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/include
	${CMAKE_CURRENT_SOURCE_DIR}/include/Security
)

# Leaving these here for now because they lack build scripts of their own
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/authd)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurity_dotmac_tp/lib)

include_directories(
	${CMAKE_SOURCE_DIR}/src/external/corefoundation
	${CMAKE_SOURCE_DIR}/src/external/foundation/include
	${CMAKE_SOURCE_DIR}/src/external/libauto
	${CMAKE_SOURCE_DIR}/src/external/zlib
	${CMAKE_SOURCE_DIR}/src/external/libclosure
	${CMAKE_SOURCE_DIR}/src/external/libdispatch
	${CMAKE_SOURCE_DIR}/src/external/openpam/include
	${CMAKE_SOURCE_DIR}/src/external/syslog/libsystem_asl.tproj/include
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
	${CMAKE_SOURCE_DIR}/src/libinfo/include
	${CMAKE_SOURCE_DIR}/src/quarantine
	${CMAKE_SOURCE_DIR}/src/LocalAuthentication/include
	${CMAKE_SOURCE_DIR}/src/kernel/libsyscall/wrappers/libproc
	${CMAKE_SOURCE_DIR}/src/libmalloc/include
	${CMAKE_SOURCE_DIR}/src/external/objc4/runtime
	${CMAKE_SOURCE_DIR}/src/CryptoTokenKit/include
)


include_directories(BEFORE
	${CMAKE_SOURCE_DIR}/src/external/libcxx/include
)

add_subdirectory(OSX)
