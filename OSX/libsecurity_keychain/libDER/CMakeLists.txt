project(libDER)

cmake_minimum_required(VERSION 2.4.0)
enable_language(C ASM)

if(COMMAND cmake_policy)
	cmake_policy(SET CMP0003 NEW)
	cmake_policy(SET CMP0005 NEW)
endif(COMMAND cmake_policy)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -msse -msse2 -msse3 -w -nostdinc -fPIC")

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/libDER)

set(der_sources
	libDER/DER_CertCrl.c
	libDER/DER_Decode.c
	libDER/DER_Digest.c
	libDER/DER_Encode.c
	libDER/DER_Keys.c
	libDER/oids.c
	libDERUtils/fileIo.c
	libDERUtils/libDERUtils.c
	libDERUtils/printFields.c
)

add_library(der OBJECT ${der_sources})

