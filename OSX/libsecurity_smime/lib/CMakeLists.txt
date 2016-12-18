project(security_smime)

add_definitions(
	-Wno-enum-conversion
)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/../../sec
)

add_library(security_smime OBJECT
	cert.c
	cmsarray.c
	cmsasn1.c
	cmsattr.c
	cmscinfo.c
	cmscipher.c
	SecCMS.c
	cmsdecode.c
	cmsdigdata.c
	cmsdigest.c
	cmsencdata.c
	cmsencode.c
	cmsenvdata.c
	cmsmessage.c
	cmspubkey.c
	cmsrecinfo.c
	cmsreclist.c
	cmssigdata.c
	cmssiginfo.c
	cmsutil.c
	cryptohi.c
	plhash.c
	secalgid.c
	secitem.c
	secoid.c
	smimeutil.c
	siginfoUtils.cpp
	tsaSupport.c
)

set_property(TARGET security_smime PROPERTY COMPILE_FLAGS "-include limits.h -include stdio.h -include errno.h")
