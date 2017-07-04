add_library(libsecurity_comcryption OBJECT
	lib/comcryption.c
	lib/comcryptPriv.c
)
make_fat(libsecurity_comcryption)
