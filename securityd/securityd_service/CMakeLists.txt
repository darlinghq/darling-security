project(securityd_service)

add_security_library(securitydservice_client
	FAT
	C_STANDARD "gnu99"
	CXX_STANDARD "gnu++0x"
	SOURCES
		securityd_service/securityd_service_client.c
)
