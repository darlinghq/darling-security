project(XPCTimeStampingService)

add_darling_executable(XPCTimeStampingService
	main-tsa.m
	timestampclient.m
)

target_link_libraries(XPCTimeStampingService
	Foundation
	Security
	CoreFoundation

	# implied dependencies
	objc
	system
)

install(TARGETS XPCTimeStampingService DESTINATION libexec/darling/System/Library/Frameworks/Security.framework/Versions/A/XPCServices)
