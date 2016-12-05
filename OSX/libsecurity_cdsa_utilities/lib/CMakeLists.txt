project(security_cdsa_utilities)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_cdsa_utilities OBJECT
	acl_any.cpp
	acl_codesigning.cpp
	acl_comment.cpp
	acl_password.cpp
	acl_process.cpp
	acl_protectedpw.cpp
	acl_threshold.cpp
	callback.cpp
	constdata.cpp
	context.cpp
	cssmacl.cpp
	cssmaclpod.cpp
	cssmalloc.cpp
	cssmcert.cpp
	cssmcred.cpp
	cssmdata.cpp
	cssmdates.cpp
	cssmdb.cpp
	cssmdbname.cpp
	cssmendian.cpp
	cssmerrors.cpp
	cssmlist.cpp
	cssmtrust.cpp
	cssmwalkers.cpp
	db++.cpp
	handleobject.cpp
	handletemplates.cpp
	KeySchema.cpp
	Schema.cpp
	uniformrandom.cpp
	walkers.cpp
	cssmkey.cpp
	cssmpods.cpp
	AuthorizationData.cpp
	acl_preauth.cpp
	aclsubject.cpp
	objectacl.cpp
	acl_secret.cpp
	acl_prompted.cpp
	osxverifier.cpp
	u32handleobject.cpp
)

set_property(SOURCE cssmerrors.cpp PROPERTY COMPILE_FLAGS "-include ../../libsecurity_utilities/dtrace_fake.h")
