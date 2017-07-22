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

set(CMAKE_SHARED_LINKER_FLAGS "-Wl,-flat_namespace,-undefined,suppress")

add_framework(Security
	FAT
	CURRENT_VERSION
	VERSION "A"

	SOURCES
		lib/dummy.cpp
		Breadcrumb/SecBreadcrumb.c
		../../coretls/coretls_cfhelpers/tls_helpers.c
		../../coretls/coretls_cfhelpers/tls_helpers_identity.c
		../../coretls/lib/sslMemory.c

		#$<TARGET_OBJECTS:libsecurity_asn1>
		#$<TARGET_OBJECTS:libSecItemShimOSX>
		$<TARGET_OBJECTS:libSecOtrOSX>
		#$<TARGET_OBJECTS:libSecTrustOSX>
		#$<TARGET_OBJECTS:libSecureObjectSync>
		$<TARGET_OBJECTS:liblogging>
		$<TARGET_OBJECTS:libsecipc_client>
		$<TARGET_OBJECTS:libsecurity_apple_csp>
		$<TARGET_OBJECTS:libsecurity_apple_cspdl>
		$<TARGET_OBJECTS:libsecurity_apple_file_dl>
		$<TARGET_OBJECTS:libsecurity_apple_x509_cl>
		#$<TARGET_OBJECTS:libsecurity_apple_x509_tp>
		$<TARGET_OBJECTS:libsecurity_authorization>
		$<TARGET_OBJECTS:libsecurity_cdsa_client>
		$<TARGET_OBJECTS:libsecurity_cdsa_plugin>
		$<TARGET_OBJECTS:libsecurity_cdsa_utilities>
		#$<TARGET_OBJECTS:libsecurity_cdsa_utils>
		$<TARGET_OBJECTS:libsecurity_checkpw>
		$<TARGET_OBJECTS:libsecurity_cms>
		$<TARGET_OBJECTS:libsecurity_codesigning>
		$<TARGET_OBJECTS:libsecurity_comcryption>
		$<TARGET_OBJECTS:libsecurity_cryptkit>
		$<TARGET_OBJECTS:libsecurity_cssm>
		$<TARGET_OBJECTS:libsecurity_filedb>
		#$<TARGET_OBJECTS:libsecurity_keychain>
		$<TARGET_OBJECTS:libsecurity_keychain_DER>
		$<TARGET_OBJECTS:libsecurity_manifest>
		$<TARGET_OBJECTS:libsecurity_mds>
		$<TARGET_OBJECTS:libsecurity_ocspd>
		$<TARGET_OBJECTS:libsecurity_pkcs12>
		$<TARGET_OBJECTS:libsecurity_sd_cspdl>
		$<TARGET_OBJECTS:libsecurity_smime>
		#$<TARGET_OBJECTS:libsecurity_ssl>
		$<TARGET_OBJECTS:libsecurity_transform>
		$<TARGET_OBJECTS:libsecurity_translocate>
		$<TARGET_OBJECTS:libsecurity_utilities>
		$<TARGET_OBJECTS:libsecurityd_client>
		$<TARGET_OBJECTS:libutilities>

	DEPENDENCIES
		system
		#coretls_cfhelpers
		objc
		pam.2
		bsm.0
		auto
		z
		xar
		sqlite3
		CoreFoundation

		# Static libraries
		#libsecurity_asn1	
		#libSecItemShimOSX
		#libSecTrustOSX
		#libSecureObjectSync	
		#libsecurity_cdsa_utils	
		#libsecurity_apple_x509_tp
		#libsecurity_keychain
		#libsecurity_ssl
)
