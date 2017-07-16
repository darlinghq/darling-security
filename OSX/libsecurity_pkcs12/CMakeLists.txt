add_library(libsecurity_pkcs12 OBJECT
	lib/pkcs12Crypto.cpp
	lib/pkcs12Utils.cpp
	lib/pkcs12Decode.cpp
	lib/pkcs12BagAttrs.cpp
	lib/pkcs12Coder.cpp
	lib/pkcs12Encode.cpp
	lib/SecPkcs12.cpp
	lib/pkcs12SafeBag.cpp
	lib/pkcs12Keychain.cpp
	lib/pkcs7Templates.cpp
	lib/pkcs12Templates.cpp
)
make_fat(libsecurity_pkcs12)
