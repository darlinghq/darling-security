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

get_directory_property(DirDefs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} COMPILE_DEFINITIONS)
get_directory_property(InclDirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} INCLUDE_DIRECTORIES)
get_directory_property(DirOpts DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} COMPILE_OPTIONS)

set(EXP_IN_FLAGS "")
foreach(def ${DirDefs})
	set(EXP_IN_FLAGS "${EXP_IN_FLAGS} -D${def}")
endforeach()
foreach(dir ${InclDirs})
	set(EXP_IN_FLAGS "${EXP_IN_FLAGS} -I${dir}")
endforeach()

set(EXP_IN_FLAGS "${EXP_IN_FLAGS} ${CMAKE_C_FLAGS}")

separate_arguments(EXP_IN_FLAGS)

set(EXP_IN_FLAGS ${EXP_IN_FLAGS} ${DirOpts})

set (security_objects "")
set (generate-security-exp-depends "")

if (BUILD_TARGET_64BIT)
	add_custom_command(
		OUTPUT
			${CMAKE_CURRENT_BINARY_DIR}/Security.${APPLE_ARCH_64BIT}.exp
		DEPENDS
			${CMAKE_CURRENT_SOURCE_DIR}/../Security.exp-in
			${CMAKE_CURRENT_SOURCE_DIR}/../CSSMOID.exp-in
		COMMAND
			${CMAKE_C_COMPILER} -E -Xpreprocessor -P -x objective-c -target ${APPLE_TARGET_TRIPLET_64BIT} ${EXP_IN_FLAGS} ${CMAKE_CURRENT_SOURCE_DIR}/../Security.exp-in -o ${CMAKE_CURRENT_BINARY_DIR}/Security.${APPLE_ARCH_64BIT}.exp
	)

	# can't be called `Security_x86_64`; add_separated_framework already uses that
	add_darling_object_library(Security_x86_64_only_stuff
		64BIT_ONLY

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
	)

	target_include_directories(Security_x86_64_only_stuff PRIVATE
		${CMAKE_CURRENT_SOURCE_DIR}/include
	)

	set (security_objects ${security_objects}
		$<TARGET_OBJECTS:Security_x86_64_only_stuff>
	)

	set (generate-security-exp-depends ${generate-security-exp-depends}
		${CMAKE_CURRENT_BINARY_DIR}/Security.x86_64.exp
	)
endif ()

if (BUILD_TARGET_32BIT)
	add_custom_command(
		OUTPUT
			${CMAKE_CURRENT_BINARY_DIR}/Security.${APPLE_ARCH_32BIT}.exp
		DEPENDS
			${CMAKE_CURRENT_SOURCE_DIR}/../Security.exp-in
			${CMAKE_CURRENT_SOURCE_DIR}/../CSSMOID.exp-in
		COMMAND
			${CMAKE_C_COMPILER} -E -Xpreprocessor -P -x objective-c -target ${APPLE_TARGET_TRIPLET_32BIT} ${EXP_IN_FLAGS} ${CMAKE_CURRENT_SOURCE_DIR}/../Security.exp-in -o ${CMAKE_CURRENT_BINARY_DIR}/Security.${APPLE_ARCH_32BIT}.exp
	)

	set (generate-security-exp-depends ${generate-security-exp-depends}
		${CMAKE_CURRENT_BINARY_DIR}/Security.i386.exp
	)
endif ()

add_custom_target(generate-security-exp
	DEPENDS
		${generate-security-exp-depends}	
)


set_source_files_properties(
	../Analytics/SFAnalytics.m
	../Analytics/SFAnalyticsMultiSampler.m
	../Analytics/SFAnalyticsSampler.m
	../Analytics/SQLite/SFSQLiteStatement.m

	PROPERITES
		COMPILE_FLAGS " -fobjc-arc"
)

add_separated_framework(Security
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
		../Analytics/Clients/LocalKeychainAnalytics.m
		../experiment/SecExperiment.m
		../keychain/behavior/SFBehavior.m
		../keychain/ckks/CKKSControl.m
		../keychain/ckks/CKKSControlProtocol.m
		../keychain/escrowrequest/EscrowRequestXPCProtocol.m
		../keychain/escrowrequest/Framework/SecEscrowRequest.m
		../keychain/ot/OTClique.m
		../keychain/ot/OTConstants.m
		../keychain/ot/OTControl.m
		../keychain/ot/OTControlProtocol.m
		../keychain/ot/OTDefines.m
		../keychain/ot/OTJoiningConfiguration.m
		../keychain/SigninMetrics/OctagonSignPosts.m
		../keychain/SigninMetrics/SFSignInAnalytics.m
		../protocol/SecProtocol.c
		../protocol/SecProtocolConfiguration.m
		../protocol/SecProtocolHelper.m
		../protocol/SecProtocolTypes.m

		../darling/version.c

	OBJECTS
		${security_objects}

	# coretls_cfhelpers depends on some symbols in Security provided through static libraries
	# it probably only depends on a subset of these, but just in case, link all of our static libraries strongly (i.e. in the firstpass)
	STRONG_DEPENDENCIES
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

	DEPENDENCIES
		# try to stick to the order in xcodeproj as much as possible
		#
		# kind of difficult because there is a mix of libraries added
		# through target "Frameworks" and some added as plain flags
		AppleFSCompression

		# static Security libraries moved to STRONG_DEPENDENCIES

		DiagnosticMessagesClient

		#aks_acl
		aks # already includes aks_acl

		bsm.0

		#CrashReporterClient # missing (but apparently not necessary?)

		#coreauthd_client
		LocalAuthentication # instead of coreauthd_client

		coretls
		#coretls_cfhelpers # must be added as a circular library

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

	CIRCULAR_DEPENDENCIES
		coretls_cfhelpers

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

if (BUILD_TARGET_64BIT)
	add_dependencies(Security_${APPLE_ARCH_64BIT}_firstpass
		generate-security-exp
	)

	add_dependencies(Security_${APPLE_ARCH_64BIT}
		generate-security-exp
		Foundation
	)

	target_link_options(Security_${APPLE_ARCH_64BIT}_firstpass PRIVATE
		-Wl,-exported_symbols_list,${CMAKE_CURRENT_BINARY_DIR}/Security.${APPLE_ARCH_64BIT}.exp
	)

	target_link_options(Security_${APPLE_ARCH_64BIT} PRIVATE
		-Wl,-dead_strip
		-Wl,-exported_symbols_list,${CMAKE_CURRENT_BINARY_DIR}/Security.${APPLE_ARCH_64BIT}.exp
		-Wl,-upward_library,$<TARGET_FILE:Foundation>
	)
endif ()
if (BUILD_TARGET_32BIT)
	add_dependencies(Security_${APPLE_ARCH_32BIT}_firstpass
		generate-security-exp
	)

	add_dependencies(Security_${APPLE_ARCH_32BIT}
		generate-security-exp
		Foundation
	)

	target_link_options(Security_${APPLE_ARCH_32BIT}_firstpass PRIVATE
		-Wl,-exported_symbols_list,${CMAKE_CURRENT_BINARY_DIR}/Security.${APPLE_ARCH_32BIT}.exp
	)

	target_link_options(Security_${APPLE_ARCH_32BIT} PRIVATE
		-Wl,-dead_strip
		-Wl,-exported_symbols_list,${CMAKE_CURRENT_BINARY_DIR}/Security.${APPLE_ARCH_32BIT}.exp
		-Wl,-upward_library,$<TARGET_FILE:Foundation>
	)
endif ()

target_include_directories(Security_obj PRIVATE
	${CMAKE_CURRENT_SOURCE_DIR}/include
)

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
