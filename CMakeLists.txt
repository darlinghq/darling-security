project(Security)

add_definitions(
	-DNDEBUG=1
	-D__KEYCHAINCORE__=1
	-DOSSPINLOCK_USE_INLINED=0
)

add_subdirectory(OSX)
