project(Security.framework)

add_definitions(
	-Wno-c++11-extensions
	-D__nullable=
	-D__nonnull=
)

add_subdirectory(libsecurity_keychain/libDER)
add_subdirectory(libsecurity_keychain/lib)
add_subdirectory(libsecurity_authorization/lib)

SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/darling")
SET(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
add_library(Security SHARED
	$<TARGET_OBJECTS:security_authorization>
)

target_link_libraries(Security system auto)
install(TARGETS Security DESTINATION ${CMAKE_INSTALL_LIBDIR}/darling)

