project(Security.framework)

add_definitions(
	-Wno-c++11-extensions
	-Wno-implicit-function-declaration
	-Wno-deprecated
	-Wno-bool-conversion
	-Wno-null-conversion
	-Wno-int-conversion
	-D__nullable=
	-D__nonnull=
)

add_subdirectory(libsecurity_keychain/libDER)
add_subdirectory(libsecurity_keychain/lib)
add_subdirectory(libsecurity_authorization/lib)
add_subdirectory(libsecurity_utilities/lib)
add_subdirectory(utilities/src)
add_subdirectory(libsecurity_cssm/lib)
add_subdirectory(libsecurity_transform/lib)
add_subdirectory(libsecurity_asn1/lib)
add_subdirectory(libsecurity_manifest/lib)
add_subdirectory(libsecurity_mds/lib)

SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/darling")
SET(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

add_library(Security SHARED
	$<TARGET_OBJECTS:security_authorization>
	$<TARGET_OBJECTS:security_utilities>
	$<TARGET_OBJECTS:utilities>
	$<TARGET_OBJECTS:security_keychain>
	$<TARGET_OBJECTS:security_keychain_der>
	$<TARGET_OBJECTS:security_cssm>
	$<TARGET_OBJECTS:security_transform>
	$<TARGET_OBJECTS:security_asn1>
	$<TARGET_OBJECTS:security_manifest>
	$<TARGET_OBJECTS:security_mds>
)

target_link_libraries(Security system auto CFFExtra CFF sqlite3 xpc)
install(TARGETS Security DESTINATION ${CMAKE_INSTALL_LIBDIR}/darling)
