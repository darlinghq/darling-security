project(libsecurity_cms)

add_macos_legacy_lib(security_cms
	SOURCES
		../libsecurity_smime/lib/cert.c
		../libsecurity_smime/lib/cmsarray.c
		../libsecurity_smime/lib/cmsasn1.c
		../libsecurity_smime/lib/cmsattr.c
		../libsecurity_smime/lib/cmscinfo.c
		../libsecurity_smime/lib/cmscipher.c
		../libsecurity_smime/lib/cmsdecode.c
		../libsecurity_smime/lib/cmsdigdata.c
		../libsecurity_smime/lib/cmsdigest.c
		../libsecurity_smime/lib/cmsencdata.c
		../libsecurity_smime/lib/cmsencode.c
		../libsecurity_smime/lib/cmsenvdata.c
		../libsecurity_smime/lib/cmsmessage.c
		../libsecurity_smime/lib/cmspubkey.c
		../libsecurity_smime/lib/cmsrecinfo.c
		../libsecurity_smime/lib/cmsreclist.c
		../libsecurity_smime/lib/cmssigdata.c
		../libsecurity_smime/lib/cmssiginfo.c
		../libsecurity_smime/lib/cmsutil.c
		../libsecurity_smime/lib/cryptohi.c
		../libsecurity_smime/lib/plhash.c
		../libsecurity_smime/lib/secalgid.c
		../libsecurity_smime/lib/SecCMS.c
		../libsecurity_smime/lib/secitem.c
		../libsecurity_smime/lib/secoid.c
		../libsecurity_smime/lib/siginfoUtils.cpp
		../libsecurity_smime/lib/smimeutil.c
		../libsecurity_smime/lib/tsaSupport.c
		../libsecurity_smime/lib/tsaTemplates.c
		lib/CMSDecoder.cpp
		lib/CMSEncoder.cpp
		lib/CMSUtils.cpp
	INCLUDES
		${CMAKE_CURRENT_SOURCE_DIR}/../libsecurity_smime/lib
)
