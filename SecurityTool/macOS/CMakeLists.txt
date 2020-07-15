project(SecurityTool-macOS)

add_darling_executable(securitytool_macos
	srCdsaUtils.cpp
	createFVMaster.c
	mds_install.cpp
	cmsutil.c
	db_commands.cpp
	display_error_code.c
	trusted_cert_dump.c
	identity_find.m
	identity_prefs.c
	key_create.c
	keychain_add.c
	keychain_create.c
	keychain_delete.c
	keychain_export.m
	keychain_find.c
	keychain_import.c
	keychain_list.c
	keychain_lock.c
	keychain_recode.c
	keychain_set_settings.c
	keychain_show_info.c
	keychain_unlock.c
	keychain_utilities.c
	leaks.c
	readline.c
	security.c
	smartcards.m
	trusted_cert_add.c
	trusted_cert_utils.c
	trust_settings_impexp.c
	user_trust_enable.cpp
	requirement.c
	authz.c
	verify_cert.c
	trusted_cert_ssl.m
	access_utils.c
	translocate.c
)
target_compile_options(securitytool_macos PRIVATE
	-fobjc-arc
)
target_include_directories(securitytool_macos PRIVATE
	${SECURITY_PROJECT_DIR}/header_symlinks/macOS
)

set_target_properties(securitytool_macos PROPERTIES OUTPUT_NAME "security")

target_link_libraries(securitytool_macos
	CoreFoundation
	SecurityFoundation
	Security
	security_asn1
	utilities
	security_utilities
	security_cdsa_client
	security_cdsa_utilities
	security_cdsa_utils
	Foundation
	#Network # missing

	# implied dependencies
	objc
	cxx
	system
)

install(TARGETS securitytool_macos DESTINATION libexec/darling/usr/bin)
install(FILES security.1 DESTINATION libexec/darling/usr/share/man/man1)
