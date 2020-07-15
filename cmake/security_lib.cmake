include(CMakeParseArguments)

# add_security_library
# Helper function for adding Security libraries
# (because there's a lot of them, and it's easier to configure all necessary options with a single function)
#
# Options:
# 	FAT
# 		Build the library for both x86_64 and i386.
# 	OBJC_ARC
# 		Enable Objective-C ARC for the library.
#
# Single-value arguments:
# 	OUTPUT_NAME
# 		The filename for the built library. This is combined with PREFIX and SUFFIX to produce the full filename.
# 		Defaults to the target name.
# 	PREFIX
# 		The prefix to add to the library filename.
# 		Defaults to `lib`.
# 	SUFFIX
# 		The suffix to add to the library filename.
# 		Defaults to `.dylib`.
# 	C_STANDARD
# 		The C standard to use when compiling the code. E.g. `gnu99`, `c99`, etc.
# 	CXX_STANDARD
# 		The C++ standard to use when compiling the code. E.g. `gnu++11`, `c++1`, etc.
#
# Multi-value arguments:
# 	SOURCES
# 		A list of sources to use to build the library.
# 		Can include any source that `add_darling_static_library` supports.
# 	LIBRARIES
# 		A list of libraries to link to. If target names are provided, they are also added as dependencies.
# 	INCLUDES
# 		A list of directories to add as private header directories.
# 	DEFINITIONS
# 		A list of preprocessor definitions to add as private preprocessor definitions.
# 		Supports the same syntax as `add_compile_definitions`.
# 	FLAGS
# 		A list of flags to pass to the compiler when compiling the library.
# 		Supports the same syntax as `add_compile_options`.
function(add_security_library name)
	cmake_parse_arguments(SECLIB "FAT;OBJC_ARC" "OUTPUT_NAME;PREFIX;SUFFIX;C_STANDARD;CXX_STANDARD" "SOURCES;LIBRARIES;INCLUDES;DEFINITIONS;FLAGS" ${ARGN})

	add_darling_static_library(${name} ${SECLIB_FAT} SOURCES ${SECLIB_SOURCES})

	if(SECLIB_OBJC_ARC)
		target_compile_options(${name} PRIVATE -fobjc-arc)
	endif()

	if(DEFINED SECLIB_OUTPUT_NAME)
		set_target_properties(${name} PROPERTIES OUTPUT_NAME "${SECLIB_OUTPUT_NAME}")
	endif()

	if(DEFINED SECLIB_PREFIX)
		set_target_properties(${name} PROPERTIES PREFIX "${SECLIB_PREFIX}")
	endif()

	if(DEFINED SECLIB_SUFFIX)
		set_target_properties(${name} PROPERTIES SUFFIX "${SECLIB_SUFFIX}")
	endif()

	if(SECLIB_C_STANDARD)
		set(SECLIB_C_STANDARD_VALID TRUE)
		if(SECLIB_C_STANDARD MATCHES "[cC][0-9]+([a-zA-Z])?")
			set_property(TARGET ${name} PROPERTY C_EXTENSIONS OFF)
		elseif(SECLIB_C_STANDARD MATCHES "([gG][nN][uU])?[0-9]+([a-zA-Z])?")
			# the default is to enable extensions
			set_property(TARGET ${name} PROPERTY C_EXTENSIONS ON)
		else()
			set(SECLIB_C_STANDARD_VALID FALSE)
			message(WARNING "Unrecognized C standard: ${SECLIB_C_STANDARD}")
		endif()
		if(SECLIB_C_STANDARD_VALID)
			string(REGEX MATCH "[0-9]+" SECLIB_C_STANDARD_VERSION "${SECLIB_C_STANDARD}")
			set_property(TARGET ${name} PROPERTY C_STANDARD "${SECLIB_C_STANDARD_VERSION}")
		endif()
	endif()

	if(SECLIB_CXX_STANDARD)
		set(SECLIB_CXX_STANDARD_VALID TRUE)
		if(SECLIB_CXX_STANDARD MATCHES "[cC](\\+\\+|[xX][xX])[0-9]+([a-zA-Z])?")
			set_property(TARGET ${name} PROPERTY CXX_EXTENSIONS OFF)
		elseif(SECLIB_CXX_STANDARD MATCHES "([gG][nN][uU](\\+\\+|[xX][xX]))?[0-9]+([a-zA-Z])?")
			# the default is to enable extensions
			set_property(TARGET ${name} PROPERTY CXX_EXTENSIONS ON)
		else()
			set(SECLIB_CXX_STANDARD_VALID FALSE)
			message(WARNING "Unrecognized C standard: ${SECLIB_CXX_STANDARD}")
		endif()
		if(SECLIB_CXX_STANDARD_VALID)
			string(REGEX MATCH "[0-9]+" SECLIB_CXX_STANDARD_VERSION "${SECLIB_CXX_STANDARD}")
			set_property(TARGET ${name} PROPERTY CXX_STANDARD "${SECLIB_CXX_STANDARD_VERSION}")
		endif()
	endif()

	if(SECLIB_LIBRARIES)
		target_link_libraries(${name} ${SECLIB_LIBRARIES})
	endif()

	if(SECLIB_INCLUDES)
		target_include_directories(${name} PRIVATE ${SECLIB_INCLUDES})
	endif()

	if(SECLIB_DEFINITIONS)
		target_compile_definitions(${name} PRIVATE ${SECLIB_DEFINITIONS})
	endif()

	if (SECLIB_FLAGS)
		target_compile_options(${name} PRIVATE ${SECLIB_FLAGS})
	endif()
endfunction()
