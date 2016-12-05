project(security_filedb)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_filedb OBJECT
	AppleDatabase.cpp
	AtomicFile.cpp
	DbIndex.cpp
	DbQuery.cpp
	DbValue.cpp
	MetaAttribute.cpp
	MetaRecord.cpp
	SelectionPredicate.cpp
	ReadWriteSection.cpp
)
