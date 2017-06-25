include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_library(libsecurity_apple_file_dl OBJECT
	lib/AppleDLBuiltin.cpp
	lib/AppleFileDL.cpp
)
make_fat(libsecurity_apple_file_dl)
