project(libutilities)

add_darling_object_library(utilities_x86_64
	64BIT_ONLY

	SecTapToRadar.m
)

add_security_library(utilities
	FAT
	OBJC_ARC
	SOURCES
		debugging.c
		der_array.c
		der_boolean.c
		der_data.c
		der_date.c
		der_dictionary.c
		der_null.c
		der_number.c
		der_plist.c
		der_plist_internal.c
		der_set.c
		der_string.c
		fileIo.c
		iCloudKeychainTrace.c
		iOSforOSX-SecAttr.c
		iOSforOSX-SecRandom.c
		NSURL+SOSPlistStore.m
		SecABC.m
		SecAKSWrappers.c
		SecAppleAnchor.c
		SecAutorelease.m
		SecBuffer.c
		SecCFCCWrappers.c
		SecCFError.c
		SecCFWrappers.c
		SecCoreCrypto.c
		SecDb.c
		SecFileLocations.c
		SecNSAdditions.m
		SecPLWrappers.m
		SecSCTUtils.c
		# SecTapToRadar.m
		SecTrace.c
		SecXPCError.c
		SecXPCHelper.m
		SecXPCUtils.m
		sec_action.c
		simulate_crash.m

		$<TARGET_OBJECTS:utilities_x86_64>
	INCLUDES
		${SECURITY_PROJECT_DIR}/securityd/securityd_service/KeyStore
)
