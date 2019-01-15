add_subdirectory(securityd_service)

set(MIG_USER_SOURCE_SUFFIX "User.cpp")
set(MIG_SERVER_SOURCE_SUFFIX "Server.cpp")

mig(mig/self.defs
	MIG_FLAGS "-cpp"
)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/src
	${CMAKE_CURRENT_BINARY_DIR}/mig
	${CMAKE_CURRENT_SOURCE_DIR}/../OSX/libsecurityd/lib
	${CMAKE_CURRENT_SOURCE_DIR}/../../SecurityTokend/lib
)

add_darling_executable(securityd_exe
	${CMAKE_CURRENT_BINARY_DIR}/mig/selfServer.cpp
	${CMAKE_CURRENT_BINARY_DIR}/mig/selfUser.cpp
	src/main.cpp
	src/connection.cpp
	src/database.cpp
	src/key.cpp
	src/process.cpp
	src/server.cpp
	src/session.cpp
	src/structure.cpp
	src/dbcrypto.cpp
	src/localdatabase.cpp
	src/localkey.cpp
	src/kcdatabase.cpp
	src/kckey.cpp
	src/tempdatabase.cpp
	src/tokendatabase.cpp
	src/tokenkey.cpp
	src/tokenaccess.cpp
	src/pcscmonitor.cpp
	src/reader.cpp
	src/token.cpp
	src/tokend.cpp
	src/tokencache.cpp
	src/transition.cpp
	src/acls.cpp
	src/tokenacl.cpp
	src/acl_keychain.cpp
	src/acl_partition.cpp
	src/authhost.cpp
	src/credential.cpp
	src/clientid.cpp
	src/codesigdb.cpp
	src/csproxy.cpp
	src/agentquery.cpp
	src/auditevents.cpp
	src/ccaudit_extensions.cpp
	src/child.cpp
	src/notifications.cpp
	src/SharedMemoryServer.cpp
)
make_fat(securityd_exe)
target_link_libraries(securityd_exe sqlite3 z auto objc DiagnosticMessagesClient security_codesigning
	security_utilities securityd_client securityd_server security_cdsa_utilities security_cdsa_client
	bsm.0 utilities IOKit CoreFoundation Security security_tokend_client securitydservice_client PCSC)

set_target_properties(securityd_exe PROPERTIES OUTPUT_NAME "securityd")

set_property(TARGET securityd_exe APPEND_STRING PROPERTY LINK_FLAGS " -Wl,-dead_strip ")

# TODO: Permissions, suid/whatever
install(TARGETS securityd_exe DESTINATION libexec/darling/usr/sbin)
install(FILES etc/com.apple.securityd.plist DESTINATION libexec/darling/System/Library/LaunchDaemons)
