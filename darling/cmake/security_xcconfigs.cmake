# some Xcode `.xcconfig` files translated into CMake functions

include(security_lib)
include(CMakeParseArguments)

function(add_macos_legacy_lib name)
	add_security_library(${name}
		FAT
		INCLUDES
			${SECURITY_PROJECT_DIR}/OSX/libsecurity_cssm/lib
			${SECURITY_PROJECT_DIR}/OSX/include
			${SECURITY_PROJECT_DIR}/OSX/utilities/src
			${SECURITY_PROJECT_DIR}/OSX/libsecurity_apple_csp/open_ssl
			${SECURITY_PROJECT_DIR}/OSX/lib${name}/lib
		${ARGN}
	)
endfunction()

function(add_lib_ios name)
	add_security_library(${name}
		FAT
		C_STANDARD gnu99
		INCLUDES
			${SECURITY_PROJECT_DIR}/OSX/libsecurity_smime
			#$(SYSTEM_LIBRARY_DIR)/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework/Headers
		DEFINITIONS
			SEC_IOS_ON_OSX=1
		${ARGN}
	)
endfunction()

function(add_lib_ios_shim name)
	add_lib_ios(${name}
		DEFINITIONS
			SECITEM_SHIM_OSX=1
		${ARGN}
	)
endfunction()
