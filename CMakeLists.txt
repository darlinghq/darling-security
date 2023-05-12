project(Security)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/darling/cmake")

include(security_lib)
include(security_xcconfigs)

set(CMAKE_CXX_STANDARD 14)
set(SECURITY_PROJECT_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

add_compile_options(
	-w
	-nostdinc
)

add_compile_definitions(
	__KEYCHAINCORE__=1
	CORECRYPTO_DONOT_USE_TRANSPARENT_UNION=1
	#OCTAGON=1 # needs some extra stuff i don't want to implement right now
	#TRUSTEDPEERS=1 # needs Octagon
	SECUREOBJECTSYNC=1
	SHAREDWEBCREDENTIALS=0
	PLATFORM=macOS
	"SECURITY_BUILD_VERSION=\"0\""
	NDEBUG=1

	# not listed in Xcode, but apparently necessary
	PRIVATE

	# we don't currently do anything with DTrace
	DTRACE_PROBES_DISABLED=1
)

include_directories(
	${SECURITY_PROJECT_DIR}/darling/include
	${SECURITY_PROJECT_DIR}/darling/include/macOS
	${SECURITY_PROJECT_DIR}
	${SECURITY_PROJECT_DIR}/gen
	${SECURITY_PROJECT_DIR}/OSX/libsecurity_asn1
	${SECURITY_PROJECT_DIR}/OSX/libsecurity_keychain/lib/
	${SECURITY_PROJECT_DIR}/OSX/sec
	${SECURITY_PROJECT_DIR}/OSX/sec/Security
	${SECURITY_PROJECT_DIR}/OSX/utilities
	${SECURITY_PROJECT_DIR}/OSX
	${SECURITY_PROJECT_DIR}/darling/src/libDER
	${SECURITY_PROJECT_DIR}/darling/include/Security
	${SECURITY_PROJECT_DIR}/darling/include/macOS/Security
)

add_subdirectory(darling/src/libDER)
add_subdirectory(keychain)
add_subdirectory(keychain/SecureObjectSync)

# Security.framework
add_subdirectory(OSX)
# securityd
add_subdirectory(securityd)
add_subdirectory(SecurityTool/macOS)

# missing ProtocolBuffer.framework
#add_subdirectory(KeychainCircle)

add_subdirectory(trust/trustd)
#add_subdirectory(keychain/securityd) # can't build this with Octagon disabled
#add_subdirectory(OSX/authd)

install(DIRECTORY DESTINATION libexec/darling/System/Library/Security)
