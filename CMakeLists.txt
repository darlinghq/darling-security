project(Security)

add_compile_options(
	-Wno-gcc-compat
	-Wno-ignored-attributes
)
add_definitions(
	-DNDEBUG=1
	-D__KEYCHAINCORE__=1
	-DOSSPINLOCK_USE_INLINED=0
)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/keychain
	${CMAKE_CURRENT_SOURCE_DIR}/base
	${CMAKE_CURRENT_SOURCE_DIR}/OSX/libsecurity_asn1
	${CMAKE_CURRENT_SOURCE_DIR}/OSX/utilities
	${CMAKE_CURRENT_SOURCE_DIR}/OSX/utilities/src
	${CMAKE_CURRENT_SOURCE_DIR}/trust
	${CMAKE_CURRENT_SOURCE_DIR}/internal-include
)

add_subdirectory(OSX)
