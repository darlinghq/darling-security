project(libDER)

add_security_library(DER
	FAT
	SOURCES
		libDER/DER_CertCrl.c
		libDER/DER_Decode.c
		libDER/DER_Digest.c
		libDER/DER_Encode.c
		libDER/DER_Keys.c
		libDER/oids.c
)
