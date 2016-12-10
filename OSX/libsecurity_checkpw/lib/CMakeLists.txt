project(security_checkpw)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_checkpw OBJECT
	checkpw.c
)
