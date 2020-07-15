add_subdirectory(libsecurity_asn1)
add_subdirectory(sec/Security)
add_subdirectory(libsecurity_apple_csp)
add_subdirectory(libsecurity_apple_cspdl)
add_subdirectory(libsecurity_apple_file_dl)
add_subdirectory(libsecurity_apple_x509_cl)
add_subdirectory(libsecurity_apple_x509_tp)
add_subdirectory(libsecurity_authorization)
add_subdirectory(libsecurity_cdsa_client)
add_subdirectory(libsecurity_cdsa_plugin)
add_subdirectory(libsecurity_cdsa_utilities)
add_subdirectory(libsecurity_cdsa_utils)
add_subdirectory(libsecurity_checkpw)
add_subdirectory(libsecurity_cms)
add_subdirectory(libsecurity_codesigning)
add_subdirectory(libsecurity_comcryption)
add_subdirectory(libsecurity_cryptkit)
add_subdirectory(libsecurity_cssm)
add_subdirectory(libsecurity_filedb)
add_subdirectory(libsecurity_keychain)
add_subdirectory(libsecurity_manifest)
add_subdirectory(libsecurity_mds)
add_subdirectory(libsecurity_ocspd)
add_subdirectory(libsecurity_pkcs12)
add_subdirectory(libsecurity_sd_cspdl)
add_subdirectory(libsecurity_ssl)
add_subdirectory(libsecurity_transform)
add_subdirectory(libsecurity_translocate)
add_subdirectory(libsecurity_utilities)
add_subdirectory(libsecurityd)
add_subdirectory(utilities)

set(DYLIB_COMPAT_VERSION "1.0.0")
set(DYLIB_CURRENT_VERSION "59306.61.1")

add_compile_definitions(
	CORECRYPTO_DONOT_USE_TRANSPARENT_UNION=1
)

add_darling_object_library(Security_x86_64
	x86_64_ONLY

	../Analytics/Clients/LocalKeychainAnalytics.m
	../Analytics/Clients/SOSAnalytics.m
	../Analytics/NSDate+SFAnalytics.m
	../Analytics/SFAnalytics.m
	../Analytics/SFAnalyticsActivityTracker.m
	../Analytics/SFAnalyticsMultiSampler.m
	../Analytics/SFAnalyticsSampler.m
	../Analytics/SFAnalyticsSQLiteStore.m
	../Analytics/SQLite/SFObjCType.m
	../Analytics/SQLite/SFSQLite.m
	../Analytics/SQLite/SFSQLiteStatement.m
	../keychain/escrowrequest/Framework/SecEscrowRequest.m

	# all this Octagon stuff is brand new and most of it only compiles on x86_64
	../keychain/ot/OTClique.m
	../keychain/ot/OTConstants.m
	../keychain/ot/OTControl.m
	../keychain/ot/OTControlProtocol.m
	../keychain/ot/OTDefines.m
	../keychain/ot/OTJoiningConfiguration.m
)

target_include_directories(Security_x86_64 PRIVATE
	${CMAKE_CURRENT_SOURCE_DIR}/include
)

set_source_files_properties(
	../Analytics/SFAnalytics.m
	../Analytics/SFAnalyticsMultiSampler.m
	../Analytics/SFAnalyticsSampler.m
	../Analytics/SQLite/SFSQLiteStatement.m

	PROPERITES
		COMPILE_FLAGS " -fobjc-arc"
)

add_framework(Security
	FAT
	CURRENT_VERSION
	VERSION "A"

	SOURCES
		Breadcrumb/SecBreadcrumb.c
		lib/dummy.cpp
		sec/ipc/client_endpoint.m
		sec/ipc/client.c
		sec/Security/SecFramework.c
		utilities/SecCoreAnalytics.m
		utilities/SecPaddingConfigurations.c
		$<TARGET_OBJECTS:Security_x86_64>
		../experiment/SecExperiment.m
		../keychain/behavior/SFBehavior.m
		../keychain/ckks/CKKSControl.m
		../keychain/ckks/CKKSControlProtocol.m
		../keychain/escrowrequest/EscrowRequestXPCProtocol.m
		../keychain/SigninMetrics/OctagonSignPosts.m
		../keychain/SigninMetrics/SFSignInAnalytics.m
		../protocol/SecProtocol.c
		../protocol/SecProtocolConfiguration.m
		../protocol/SecProtocolHelper.m
		../protocol/SecProtocolTypes.m

	DEPENDENCIES
		# try to stick to the order in xcodeproj as much as possible
		#
		# kind of difficult because there is a mix of libraries added
		# through target "Frameworks" and some added as plain flags
		AppleFSCompression
		security_asn1
		SecItemShimOSX
		SecOtrOSX
		SecTrustOSX
		SecureObjectSyncFramework
		logging
		security_apple_csp
		security_apple_cspdl
		security_apple_file_dl
		security_apple_x509_cl
		security_apple_x509_tp
		security_authorization
		security_cdsa_client
		security_cdsa_plugin
		security_cdsa_utilities
		security_cdsa_utils
		security_checkpw
		security_cms
		security_codesigning
		security_comcryption
		security_cryptkit
		security_cssm
		security_filedb
		security_keychain
		security_manifest
		security_mds
		security_ocspd
		security_pkcs12
		security_sd_cspdl
		security_ssl
		security_transform
		security_translocate
		security_utilities
		securityd_client
		utilities
		DiagnosticMessagesClient

		#aks_acl # missing
		aks

		bsm.0

		CrashReporterClient

		#coreauthd_client
		LocalAuthentication # instead of coreauthd_client

		coretls
		#coretls_cfhelpers # missing

		#ctkclient_sep
		#ACM
		CryptoTokenKit # instead of ctkclient_sep and ACM

		DER
		pam.2
		sqlite3
		xar
		z
		CoreFoundation
		IOKit

		# implied dependencies (not listed in Xcode, but still used)
		objc
		cxx
		system
	RESOURCES
		cssm.mdsinfo			libsecurity_cssm/mds/cssm.mdsinfo
		sd_cspdl_common.mdsinfo		libsecurity_sd_cspdl/mds/sd_cspdl_common.mdsinfo
		tp_primary.mdsinfo		libsecurity_apple_x509_tp/mds/tp_primary.mdsinfo
		tp_common.mdsinfo		libsecurity_apple_x509_tp/mds/tp_common.mdsinfo
		tp_policyOids.mdsinfo		libsecurity_apple_x509_tp/mds/tp_policyOids.mdsinfo
		cl_primary.mdsinfo		libsecurity_apple_x509_cl/mds/cl_primary.mdsinfo
		cl_common.mdsinfo		libsecurity_apple_x509_cl/mds/cl_common.mdsinfo
		csp_capabilities_common.mds	libsecurity_apple_csp/mds/csp_capabilities_common.mds
		csp_capabilities.mdsinfo	libsecurity_apple_csp/mds/csp_capabilities.mdsinfo
		csp_common.mdsinfo		libsecurity_apple_csp/mds/csp_common.mdsinfo
		csp_primary.mdsinfo		libsecurity_apple_csp/mds/csp_primary.mdsinfo
		cspdl_csp_capabilities.mdsinfo	libsecurity_apple_cspdl/mds/cspdl_csp_capabilities.mdsinfo
		cspdl_common.mdsinfo		libsecurity_apple_cspdl/mds/cspdl_common.mdsinfo
		cspdl_csp_primary.mdsinfo	libsecurity_apple_cspdl/mds/cspdl_csp_primary.mdsinfo
		cspdl_dl_primary.mdsinfo	libsecurity_apple_cspdl/mds/cspdl_dl_primary.mdsinfo
		dl_primary.mdsinfo		libsecurity_apple_file_dl/mds/dl_primary.mdsinfo
		dl_common.mdsinfo		libsecurity_apple_file_dl/mds/dl_common.mdsinfo

		#dotmac_tp_primary.mdsinfo	security_dotmac_tp/mds/dotmac_tp_primary.mdsinfo
		#dotmac_policyOids.mdsinfo	security_dotmac_tp/mds/dotmac_policyOids.mdsinfo
		#dotmac_tp_common.mdsinfo	security_dotmac_tp/mds/dotmac_tp_common.mdsinfo

)

target_include_directories(Security PRIVATE
	${CMAKE_CURRENT_SOURCE_DIR}/include
)

set_property(TARGET Security APPEND_STRING PROPERTY LINK_FLAGS " -Wl,-dead_strip -exported_symbols_list ${CMAKE_CURRENT_SOURCE_DIR}/../SEC_MANUAL.exp -Wl,-upward_library,$<TARGET_FILE:Foundation>")

include(darling_bundle)

add_darling_bundle(csparser ""
	lib/plugins/csparser.cpp
)
make_fat(csparser)
target_link_libraries(csparser security_cdsa_utilities utilities)
set_target_properties(csparser PROPERTIES
	OUTPUT_NAME "csparser"
	PREFIX ""
	SUFFIX ".bundle"
)
