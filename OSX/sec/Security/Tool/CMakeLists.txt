add_definitions(-DkACMKeyAclParamRequirePasscode="ACMKeyAclParamRequirePasscode")

set(sources
	#add_internet_password.c
	codesign.c
	#keychain_add.c
	keychain_backup.c
	#keychain_find.c
	keychain_util.c
	log_control.c
	pkcs12_util.c
	scep.c
	show_certificates.c
	spc.c
	verify_cert.c
)

add_library(SecSecurityTool OBJECT ${sources})