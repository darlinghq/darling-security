add_subdirectory(libsecurity_asn1)
add_subdirectory(sec)
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
add_subdirectory(libsecurity_smime)
add_subdirectory(libsecurity_ssl)
add_subdirectory(libsecurity_transform)
add_subdirectory(libsecurity_translocate)
add_subdirectory(libsecurity_utilities)
add_subdirectory(libsecurityd)
add_subdirectory(utilities)

set(DYLIB_COMPAT_VERSION "1.0.0")
set(DYLIB_CURRENT_VERSION "57740.51.3")

add_framework(Security
	FAT
	CURRENT_VERSION
	VERSION "A"

	SOURCES
		lib/dummy.cpp
		lib/version.c
		Breadcrumb/SecBreadcrumb.c
		../../coretls/coretls_cfhelpers/tls_helpers.c
		../../coretls/coretls_cfhelpers/tls_helpers_identity.c
		../../coretls/lib/sslMemory.c

	DEPENDENCIES
		#coretls_cfhelpers
		objc
		pam.2
		bsm.0
		auto
		z
		xar
		sqlite3
		CoreFoundation
		CryptoTokenKit
		IOKit
		SystemConfiguration
		LocalAuthentication
		DiagnosticMessagesClient

		# Static libraries
		security_asn1
		SecItemShimOSX
		SecOtrOSX
		SecTrustOSX
		SecureObjectSync
		logging
		secipc_client
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
		security_keychain_DER
		security_manifest
		security_mds
		security_ocspd
		security_pkcs12
		security_sd_cspdl
		security_smime
		security_ssl
		security_transform
		security_translocate
		security_utilities
		securityd_client
		securityd
		utilities
		aks
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

set_property(TARGET Security APPEND_STRING PROPERTY LINK_FLAGS " -Wl,-dead_strip -exported_symbols_list ${CMAKE_CURRENT_SOURCE_DIR}/../SEC_MANUAL.exp")
