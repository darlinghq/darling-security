project(libsecurity_filedb)

add_macos_legacy_lib(security_filedb
	SOURCES
		lib/AppleDatabase.cpp
		lib/AtomicFile.cpp
		lib/DbIndex.cpp
		lib/DbQuery.cpp
		lib/DbValue.cpp
		lib/MetaAttribute.cpp
		lib/MetaRecord.cpp
		lib/ReadWriteSection.cpp
		lib/SelectionPredicate.cpp
)
