include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}/lib
)

add_library(libsecurity_filedb OBJECT
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
make_fat(libsecurity_filedb)
