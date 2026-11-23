project(authd)

add_darling_executable(authd
	agent.c
	authdb.c
	authitems.c
	authtoken.c
	authutilities.c
	ccaudit.c
	connection.c
	crc.c
	credential.c
	darling_prelogin.c
	engine.c
	main.c
	mechanism.c
	object.c
	process.c
	rule.c
	server.c
	session.c
)
# PreloginUserDb.m reads the FileVault pre-login user database from APFS preboot
# volumes (APFS, DiskManagement, libaks), which Darling does not have:
# darling_prelogin.c answers the same interface.
target_compile_options(authd PRIVATE
	-fobjc-arc
	# the Xcode project builds every source with this prefix header
	-include ${CMAKE_CURRENT_SOURCE_DIR}/security.auth-Prefix.pch
)

target_link_libraries(authd
	Foundation
	sqlite3
	bsm.0
	Security
	CoreFoundation
	IOKit
	LocalAuthentication
	CryptoTokenKit

	# implied dependencies
	system
)


# authd is an XPC service: xpc_main finds the service name in the bundle's
# Info.plist, as on macOS where it is Security.framework's XPCServices/authd.xpc.
# The Xcode variables in the shipped Info.plist are filled in here.
set(AUTHD_XPC_DIR libexec/darling/System/Library/Frameworks/Security.framework/Versions/A/XPCServices/authd.xpc/Contents)
file(READ Info.plist AUTHD_INFO_PLIST)
string(REPLACE "$(PRODUCT_BUNDLE_IDENTIFIER)" "com.apple.authd" AUTHD_INFO_PLIST "${AUTHD_INFO_PLIST}")
string(REPLACE "\${EXECUTABLE_NAME}" "authd" AUTHD_INFO_PLIST "${AUTHD_INFO_PLIST}")
string(REPLACE "\${PRODUCT_NAME}" "authd" AUTHD_INFO_PLIST "${AUTHD_INFO_PLIST}")
string(REPLACE "\${CURRENT_PROJECT_VERSION}" "1" AUTHD_INFO_PLIST "${AUTHD_INFO_PLIST}")
file(GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/authd-Info.plist CONTENT "${AUTHD_INFO_PLIST}")
install(TARGETS authd DESTINATION ${AUTHD_XPC_DIR}/MacOS)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/authd-Info.plist DESTINATION ${AUTHD_XPC_DIR} RENAME Info.plist)
install(FILES authorization.plist DESTINATION libexec/darling/System/Library/Security)
install(FILES com.apple.authd DESTINATION libexec/darling/private/etc/asl)
install(FILES com.apple.authd.plist DESTINATION libexec/darling/System/Library/LaunchDaemons)
