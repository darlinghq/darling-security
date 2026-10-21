project(trustd)

include_directories(
	../../OSX/sec/Security
)

add_lib_ios_shim(libtrustd
	OUTPUT_NAME "trustd"
	MODERN_OBJC
	SOURCES
		CertificateTransparency.m
		md.m
		nameconstraints.c
		OTATrustUtilities.m
		personalization.c
		policytree.c
		SecCAIssuerCache.c
		SecCAIssuerRequest.m
		SecCertificateServer.c
		SecCertificateSource.c
		SecOCSPCache.c
		SecOCSPRequest.c
		SecOCSPResponse.c
		SecPinningDb.m
		SecPolicyServer.c
		SecRevocationDb.c
		SecRevocationNetworking.m
		SecRevocationServer.c
		SecTrustExceptionResetCount.m
		SecTrustLoggingServer.m
		SecTrustServer.c
		SecTrustStoreServer.c
		SecTrustStoreServer.m
		trustd_spi.c
		trustdFileLocations.m
		TrustURLSessionCache.m
		TrustURLSessionDelegate.m

		../../OSX/sec/Security/SecuritydXPC.c
	DEFINITIONS
		LIBTRUSTD=1
)

# Apple's trustd sources are written for ARC (e.g. assign-by-default properties
# would otherwise dangle). Without it the library's object ownership is wrong.
target_compile_options(libtrustd PRIVATE
	$<$<COMPILE_LANGUAGE:C,OBJC>:-fobjc-arc>
)
# these use Foundation/MobileAsset APIs Darling lacks, which ARC refuses to compile; they stay as they were
set_source_files_properties(OTATrustUtilities.m SecRevocationNetworking.m trustdFileLocations.m PROPERTIES COMPILE_OPTIONS -fno-objc-arc)

add_darling_executable(trustd
	../../OSX/sec/ipc/server_entitlement_helpers.c
	trustd.c

	# not listed in Xcode project, but necessary
	../../OSX/sec/ipc/util.m
)
target_compile_options(trustd PRIVATE
	-fobjc-arc
)
target_compile_definitions(trustd PRIVATE
	LIBTRUSTD
	SECITEM_SHIM_OSX=1
	SEC_IOS_ON_OSX=1
)
target_link_libraries(trustd
	DER
	bsm.0
	z
	sqlite3
	libtrustd
	utilities
	security_asn1
	login
	CFNetwork
	Network
	Security
	CoreFoundation
	Foundation
	MobileAsset

	# implied dependencies
	objc
	system
)
install(TARGETS trustd DESTINATION libexec/darling/usr/libexec)
install(FILES macOS/com.apple.trustd.plist DESTINATION libexec/darling/System/Library/LaunchDaemons)
install(FILES macOS/com.apple.trustd.agent.plist DESTINATION libexec/darling/System/Library/LaunchAgents)

add_darling_executable(trustdFileHelper
	trustdFileHelper/main.m
	trustdFileHelper/trustdFileHelper.m
)
target_compile_options(trustdFileHelper PRIVATE
	-fobjc-arc
	-DDARLING
)
target_compile_definitions(trustdFileHelper PRIVATE
	LIBTRUSTD
	SECITEM_SHIM_OSX=1
	SEC_IOS_ON_OSX=1
)
target_link_libraries(trustdFileHelper
	libtrustd
	utilities
	Security
	CoreFoundation
	Foundation
	objc
	system
)
install(TARGETS trustdFileHelper DESTINATION libexec/darling/usr/libexec)
