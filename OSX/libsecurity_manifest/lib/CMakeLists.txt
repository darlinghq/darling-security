project(security_manifest)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/../../sec
)

add_library(security_manifest OBJECT
	AppleManifest.cpp
	Download.cpp
	ManifestSigner.cpp
	SecureDownloadInternal.c
	ManifestInternal.cpp
	SecureDownload.cpp
	Manifest.cpp
	SecManifest.cpp
)
