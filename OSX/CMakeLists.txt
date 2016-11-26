project(Security.framework)

add_subdirectory(libsecurity_keychain/libDER)
add_subdirectory(libsecurity_keychain/lib)

add_library(Security SHARED empty.c)

target_link_libraries(Security security_keychain)

install(TARGETS Security DESTINATION ${CMAKE_INSTALL_LIBDIR}/darling)
