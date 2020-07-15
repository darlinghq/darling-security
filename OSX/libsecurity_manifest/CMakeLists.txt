project(libsecurity_manifest)

add_macos_legacy_lib(security_manifest
	SOURCES
		lib/AppleManifest.cpp
		lib/Download.cpp
		lib/Manifest.cpp
		lib/ManifestInternal.cpp
		lib/ManifestSigner.cpp
		lib/SecManifest.cpp
		lib/SecureDownload.cpp
		lib/SecureDownloadInternal.c
)
