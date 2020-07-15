project(CodeSigningHelper)

include(darling_bundle)

add_bundle(CodeSigningHelper ""
	main.cpp
)

set_target_properties(CodeSigningHelper PROPERTIES
	OUTPUT_NAME "com.apple.CodeSigningHelper"
	PREFIX ""
	SUFFIX ""
)

target_link_libraries(CodeSigningHelper
	IOKit
	CoreFoundation
	Security
	security_utilities

	# implied dependencies
	cxx
	system
)

install(TARGETS CodeSigningHelper DESTINATION libexec/darling/System/Library/Frameworks/Security.framework/Versions/A/XPCServices)
