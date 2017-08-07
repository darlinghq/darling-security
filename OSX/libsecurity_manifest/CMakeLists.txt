include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_darling_static_library(security_manifest FAT
	SOURCES
		lib/ManifestSigner.cpp
		lib/Manifest.cpp
		lib/SecManifest.cpp
		lib/SecureDownloadInternal.c
		lib/SecureDownload.cpp
		lib/ManifestInternal.cpp
		lib/Download.cpp
		lib/AppleManifest.cpp
)
