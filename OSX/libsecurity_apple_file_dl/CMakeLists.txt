include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_darling_static_library(security_apple_file_dl FAT
	SOURCES
		lib/AppleDLBuiltin.cpp
		lib/AppleFileDL.cpp
)
