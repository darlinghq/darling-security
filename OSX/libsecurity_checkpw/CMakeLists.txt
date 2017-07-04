add_library(libsecurity_checkpw OBJECT
	lib/checkpw.c
)
make_fat(libsecurity_checkpw)
