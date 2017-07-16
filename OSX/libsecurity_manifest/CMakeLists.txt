include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_library(libsecurity_manifest OBJECT
	lib/ManifestSigner.cpp
	lib/Manifest.cpp
	lib/SecManifest.cpp
	lib/SecureDownloadInternal.c
	lib/SecureDownload.cpp
	lib/ManifestInternal.cpp
	lib/Download.cpp
	lib/AppleManifest.cpp
)
make_fat(libsecurity_manifest)
