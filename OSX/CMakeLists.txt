project(Security.framework)

add_definitions(
	-Wno-c++11-extensions
	-D__nullable=
	-D__nonnull=
)

add_subdirectory(libsecurity_keychain/libDER)
add_subdirectory(libsecurity_keychain/lib)
#add_subdirectory(libsecurity_authorization/lib)

add_library(Security SHARED empty.c)

target_link_libraries(Security z security_keychain )#libsecurity_authorization)

install(TARGETS Security DESTINATION ${CMAKE_INSTALL_LIBDIR}/darling)
