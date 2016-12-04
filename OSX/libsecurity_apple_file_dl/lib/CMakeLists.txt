project(security_apple_file_dl)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_apple_file_dl OBJECT
	AppleDLBuiltin.cpp
	AppleFileDL.cpp
)
