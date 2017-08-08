include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_definitions(-DcmsSimpleContentInfoTemplate=SecCmsContentInfoTemplate)

add_darling_static_library(security_smime FAT
	SOURCES
		lib/cert.c
		lib/cmsarray.c
		lib/cmsasn1.c
		lib/cmsattr.c
		lib/cmscinfo.c
		lib/cmscipher.c
		lib/SecCMS.c
		lib/cmsdecode.c
		lib/cmsdigdata.c
		lib/cmsdigest.c
		lib/cmsencdata.c
		lib/cmsencode.c
		lib/cmsenvdata.c
		lib/cmsmessage.c
		lib/cmspubkey.c
		lib/cmsrecinfo.c
		lib/cmsreclist.c
		lib/cmssigdata.c
		lib/cmssiginfo.c
		lib/cmsutil.c
		lib/cryptohi.c
		lib/plhash.c
		lib/secalgid.c
		lib/secitem.c
		lib/secoid.c
		lib/smimeutil.c
		lib/siginfoUtils.cpp
		lib/tsaTemplates.c
		lib/tsaSupport.c
)
