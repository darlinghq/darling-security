project(Security)

add_compile_options(
	-fconstant-cfstrings
	-fblocks
	-nostdinc
	-nostdinc++
#	-fobjc-arc
	-Wno-unused-command-line-argument
	-Wl,-undefined,dynamic_lookup
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

add_subdirectory(OSX)
