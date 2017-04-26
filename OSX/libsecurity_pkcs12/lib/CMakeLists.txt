project(libsecurity_pkcs12)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
)

add_library(libsecurity_pkcs12 OBJECT
	pkcs12BagAttrs.cpp
	pkcs12Coder.cpp
	pkcs12Crypto.cpp
	pkcs12Decode.cpp
	pkcs12Encode.cpp
	pkcs12Keychain.cpp
	pkcs12SafeBag.cpp
	pkcs12Templates.cpp
	pkcs12Utils.cpp
	pkcs7Templates.cpp
	SecPkcs12.cpp
)
