project(libsecurity_pkcs12)

add_macos_legacy_lib(security_pkcs12
	SOURCES
		lib/pkcs12BagAttrs.cpp
		lib/pkcs12Coder.cpp
		lib/pkcs12Crypto.cpp
		lib/pkcs12Decode.cpp
		lib/pkcs12Encode.cpp
		lib/pkcs12Keychain.cpp
		lib/pkcs12SafeBag.cpp
		lib/pkcs12Templates.cpp
		lib/pkcs12Utils.cpp
		lib/pkcs7Templates.cpp
		lib/SecPkcs12.cpp
)
