project(libsecurity_asn1)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(security_asn1_sources
	certExtensionTemplates.c
	csrTemplates.c
	keyTemplates.c
	nameTemplates.c
	nsprPortX.c
	nssUtils.c
	ocspTemplates.c
	oidsalg.c
	oidsattr.c
	oidsocsp.c
	osKeyTemplates.c
	pkcs12Templates.c
	pkcs7Templates.c
	plarena.c
	SecAsn1Coder.c
	secasn1d.c
	secasn1e.c
	SecAsn1Templates.c
	secasn1u.c
	secErrorStr.c
	SecNssCoder.cpp
	secport.c
	X509Templates.c
)

add_library(security_asn1 OBJECT ${security_asn1_sources})

