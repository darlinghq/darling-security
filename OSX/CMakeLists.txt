project(Security.framework)

add_definitions(
	-Wno-c++11-extensions
	-Wno-implicit-function-declaration
	-Wno-deprecated
	-Wno-bool-conversion
	-Wno-null-conversion
	-Wno-enum-conversion
	-Wno-int-conversion
	-Wno-#warnings
	-Wno-mismatched-new-delete
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
add_subdirectory(libsecurity_sd_cspdl/lib)
add_subdirectory(libsecurity_smime/lib)
add_subdirectory(libsecurity_ssl/lib)
add_subdirectory(libsecurity_apple_csp)
add_subdirectory(libsecurity_apple_cspdl/lib)
add_subdirectory(libsecurity_apple_file_dl/lib)
add_subdirectory(libsecurity_apple_x509_cl/lib)
add_subdirectory(libsecurity_apple_x509_tp/lib)
add_subdirectory(libsecurity_cdsa_client/lib)
add_subdirectory(libsecurity_cdsa_plugin/lib)
add_subdirectory(libsecurity_cdsa_utilities/lib)
add_subdirectory(libsecurity_cdsa_utils/lib)
add_subdirectory(libsecurity_filedb/lib)
add_subdirectory(libsecurity_checkpw/lib)
add_subdirectory(libsecurity_cms/lib)
add_subdirectory(libsecurity_comcryption/lib)
add_subdirectory(libsecurity_codesigning)
add_subdirectory(libsecurityd)
add_subdirectory(sec)

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
	$<TARGET_OBJECTS:security_sd_cspdl>
	$<TARGET_OBJECTS:security_smime>
	$<TARGET_OBJECTS:security_ssl>
	$<TARGET_OBJECTS:security_apple_csp>
	$<TARGET_OBJECTS:security_apple_cspdl>
	$<TARGET_OBJECTS:security_apple_file_dl>
	$<TARGET_OBJECTS:security_apple_x509_cl>
	$<TARGET_OBJECTS:security_apple_x509_tp>
	$<TARGET_OBJECTS:security_cdsa_client>
	$<TARGET_OBJECTS:security_cdsa_plugin>
	$<TARGET_OBJECTS:security_cdsa_utilities>
	$<TARGET_OBJECTS:security_cdsa_utils>
	$<TARGET_OBJECTS:security_filedb>
	$<TARGET_OBJECTS:security_checkpw>
	$<TARGET_OBJECTS:security_cms>
	$<TARGET_OBJECTS:security_comcryption>
	$<TARGET_OBJECTS:security_codesigning>
	$<TARGET_OBJECTS:secutityd_client>
	$<TARGET_OBJECTS:sec_item_shim>

	ExtraConstants.c
)

target_link_libraries(Security system auto CFFExtra CFF sqlite3 xpc pam.2)
install(TARGETS Security DESTINATION ${CMAKE_INSTALL_LIBDIR}/darling)
