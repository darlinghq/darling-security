add_subdirectory(securityd_service)

include_directories(
	../OSX/libsecurityd/lib
	../OSX/include
	${CMAKE_CURRENT_BINARY_DIR}/../OSX/libsecurityd/mig
	${CMAKE_CURRENT_SOURCE_DIR}/src
)

set(MIG_USER_SOURCE_SUFFIX "User.cpp")
set(MIG_SERVER_SOURCE_SUFFIX "Server.cpp")

mig(mig/self.defs
	MIG_FLAGS "-cpp"
)

add_darling_executable(securityd_exe
	src/acl_keychain.cpp
	src/acl_partition.cpp
	src/acls.cpp
	src/agentquery.cpp
	src/auditevents.cpp
	src/authhost.cpp
	src/ccaudit_extensions.cpp
	src/child.cpp
	src/clientid.cpp
	src/codesigdb.cpp
	src/connection.cpp
	src/credential.cpp
	src/database.cpp
	src/dbcrypto.cpp
	src/kcdatabase.cpp
	src/kckey.cpp
	src/key.cpp
	src/localdatabase.cpp
	src/localkey.cpp
	src/main.cpp
	src/notifications.cpp
	src/pcscmonitor.cpp
	src/process.cpp
	src/reader.cpp
	src/server.cpp
	src/session.cpp
	src/SharedMemoryServer.cpp
	src/structure.cpp
	src/tempdatabase.cpp
	src/token.cpp
	src/tokenaccess.cpp
	src/tokenacl.cpp
	src/tokencache.cpp
	src/tokend.cpp
	src/tokendatabase.cpp
	src/tokenkey.cpp
	src/transition.cpp
	src/util.m

	${CMAKE_CURRENT_BINARY_DIR}/mig/selfServer.cpp
	${CMAKE_CURRENT_BINARY_DIR}/mig/selfUser.cpp
)
target_include_directories(securityd_exe PRIVATE
	${SECURITY_PROJECT_DIR}/header_symlinks/macOS
	${SECURITY_PROJECT_DIR}/securityd
	${SECURITY_PROJECT_DIR}/OSX/include

	${CMAKE_CURRENT_BINARY_DIR}/mig
)
target_compile_options(securityd_exe PRIVATE
	-fobjc-arc
)
make_fat(securityd_exe)

# same order from xcodeproj
target_link_libraries(securityd_exe
	AppleFSCompression
	Foundation
	objc
	DiagnosticMessagesClient
	securitydservice_client
	sqlite3
	z
	security_codesigning
	security_utilities
	securityd_client
	securityd_server
	security_tokend_client
	security_cdsa_utilities
	security_cdsa_client
	bsm.0
	utilities
	xar
	PCSC
	Security
	system
	CoreFoundation
	IOKit
)

set_target_properties(securityd_exe PROPERTIES OUTPUT_NAME "securityd")

set_property(TARGET securityd_exe APPEND_STRING PROPERTY LINK_FLAGS " -Wl,-dead_strip ")

# TODO: Permissions, suid/whatever
install(TARGETS securityd_exe DESTINATION libexec/darling/usr/sbin)
install(FILES etc/com.apple.securityd.plist DESTINATION libexec/darling/System/Library/LaunchDaemons)
