project(SecurityTool)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/../OSX/sec
	${CMAKE_CURRENT_SOURCE_DIR}/..
)

set(sources
	access_utils.c
	authz.c
	cmsutil.c
	createFVMaster.c
	db_commands.cpp
	display_error_code.c
	identity_find.c
	identity_prefs.c
	keychain_add.c
	keychain_create.c
	keychain_delete.c
	keychain_export.c
	keychain_find.c
	keychain_import.c
	keychain_list.c
	keychain_lock.c
	keychain_recode.c
	keychain_set_settings.c
	keychain_show_info.c
	keychain_unlock.c
	keychain_utilities.c
	key_create.c
	leaks.c
	mds_install.cpp
	#readline.c
	security.c
	#security_tool_commands.c
	srCdsaUtils.cpp
	translocate.c
	trusted_cert_add.c
	trusted_cert_dump.c
	trusted_cert_utils.c
	trust_settings_impexp.c
	user_trust_enable.cpp
	#verify_cert.c
	smartcards.m
	#${CMAKE_CURRENT_SOURCE_DIR}/../OSX/sec/Security/Tool/keychain_find.c
	${CMAKE_CURRENT_SOURCE_DIR}/../OSX/sec/SecurityTool/whoami.m
	${CMAKE_CURRENT_SOURCE_DIR}/../OSX/sec/SecurityTool/syncbubble.m
	${CMAKE_CURRENT_SOURCE_DIR}/../OSX/sec/SecurityTool/digest_calc.c
)

add_darling_executable(security ${sources}
	$<TARGET_OBJECTS:SecSecurityTool>
	$<TARGET_OBJECTS:UtilitiesSecurityTool>
	#$<TARGET_OBJECTS:SOSCircleTool>
)
target_link_libraries(security
	system
	Security
	CoreFoundation
	security_cdsa_utilities
	security_cdsa_utils
	security_utilities
	security_cdsa_client
	#SecureObjectSync
	security_asn1
	cxx
	Foundation
	utilities
	sqlite3
)

install(TARGETS security DESTINATION libexec/darling/usr/bin)
install(FILES security.1 DESTINATION libexec/darling/usr/share/man/man1)
