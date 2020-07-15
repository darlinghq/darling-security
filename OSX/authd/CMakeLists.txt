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
	engine.c
	main.c
	mechanism.c
	object.c
	process.c
	rule.c
	server.c
	session.c
)
target_compile_options(authd PRIVATE
	-fobjc-arc
)

target_link_libraries(authd
	Foundation
	sqlite3
	bsm.0
	Security
	CoreFoundation
	IOKit
	#coreauthd_client # missing
	#ctkloginhelper # missing

	# implied dependencies
	system
)

install(TARGETS authd DESTINATION libexec/darling/System/Library/Frameworks/Security.framework/Versions/A/XPCServices)
install(FILES authorization.plist DESTINATION libexec/darling/System/Library/Security)
install(FILES com.apple.authd DESTINATION libexec/darling/private/etc/asl)
