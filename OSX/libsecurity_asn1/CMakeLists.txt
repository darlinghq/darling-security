project(libsecurity_asn1)

add_security_library(security_asn1
	FAT
	SOURCES
		lib/certExtensionTemplates.c
		lib/csrTemplates.c
		lib/keyTemplates.c
		lib/nameTemplates.c
		lib/nsprPortX.c
		lib/nssUtils.c
		lib/ocspTemplates.c
		lib/oidsalg.c
		lib/oidsattr.c
		lib/oidsocsp.c
		lib/osKeyTemplates.c
		lib/pkcs12Templates.c
		lib/pkcs7Templates.c
		lib/plarena.c
		lib/SecAsn1Coder.c
		lib/secasn1d.c
		lib/secasn1e.c
		lib/SecAsn1Templates.c
		lib/secasn1u.c
		lib/secErrorStr.c
		lib/SecNssCoder.cpp
		lib/secport.c
		lib/X509Templates.c
	INCLUDES
		${SECURITY_PROJECT_DIR}/header_symlinks/iOS

		# not listed in xcode builds files, but necessary
		${CMAKE_CURRENT_SOURCE_DIR}/../include
)
