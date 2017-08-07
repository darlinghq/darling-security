include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_darling_static_library(security_filedb FAT
	SOURCES
		lib/DbQuery.cpp
		lib/AtomicFile.cpp
		lib/AppleDatabase.cpp
		lib/MetaRecord.cpp
		lib/DbIndex.cpp
		lib/DbValue.cpp
		lib/SelectionPredicate.cpp
		lib/MetaAttribute.cpp
		lib/ReadWriteSection.cpp
)
