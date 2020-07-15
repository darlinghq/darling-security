project(XPCKeychainSandboxCheck)

add_darling_executable(XPCKeychainSandboxCheck
	main.c
)
target_compile_options(XPCKeychainSandboxCheck PRIVATE
	-fobjc-arc
)

target_link_libraries(XPCKeychainSandboxCheck
	CoreFoundation

	# implied dependencies
	system
)

install(TARGETS XPCKeychainSandboxCheck DESTINATION libexec/darling/System/Library/Frameworks/Security.framework/Versions/A/XPCServices)
