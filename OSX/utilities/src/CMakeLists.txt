project(utilities)

add_definitions(
	-DCF_CONSUMED=
)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/../SecurityTool
	${CMAKE_CURRENT_SOURCE_DIR}/../../sec
	${CMAKE_CURRENT_SOURCE_DIR}/../../../securityd/securityd_service/KeyStore
)

add_library(utilities OBJECT
	comparison.c
	debugging.c
	iCloudKeychainTrace.c
	der_array.c
	der_boolean.c
	der_data.c
	der_date.c
	SecCoreCrypto.c
	simulate_crash.c
	SecAKSWrappers.c
	der_dictionary.c
	der_number.c
	SecAppleAnchor.c
	der_plist.c
	der_plist_internal.c
	der_string.c
	SecCFError.c
	der_set.c
	SecDb.c
	SecdUsage.c
	SecCFWrappers.c
	SecCFCCWrappers.c
	SecXPCError.c
	SecBuffer.c
	iOSforOSX-SecAttr.c
	iOSforOSX-SecRandom.c
	../SecurityTool/readline.c
	../SecurityTool/not_on_this_platorm.c
	der_null.c
	SecFileLocations.c
	SecInternalRelease.c
	SecSCTUtils.c
)

set_property(SOURCE SecCFError.c SecCFWrappers.c
	PROPERTY COMPILE_FLAGS "-include errno.h")
