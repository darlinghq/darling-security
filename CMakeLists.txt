project(Security)

add_compile_options(
	-fconstant-cfstrings
	-fblocks
	-nostdinc
	-nostdinc++
#	-fobjc-arc
	-Wno-unused-command-line-argument
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
	${CMAKE_SOURCE_DIR}/src/external/sqlite
	${CMAKE_SOURCE_DIR}/src/libc/include/FreeBSD
	${CMAKE_SOURCE_DIR}/src/external/libcxxabi/include
	${CMAKE_SOURCE_DIR}/src/CoreServices
	${CMAKE_SOURCE_DIR}/src/external/coretls/lib
	${CMAKE_SOURCE_DIR}/src/OpenScripting
	${CMAKE_SOURCE_DIR}/src/quarantine
	${CMAKE_SOURCE_DIR}/src/kernel/libsyscall/wrappers/libproc
	${CMAKE_SOURCE_DIR}/src/external/objc4/runtime
)


include_directories(BEFORE
	${CMAKE_SOURCE_DIR}/src/external/libcxx/include
)

add_subdirectory(OSX)
