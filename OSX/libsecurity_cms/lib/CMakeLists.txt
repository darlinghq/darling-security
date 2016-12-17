project(security_cms)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_cms OBJECT
	CMSDecoder.cpp
	CMSEncoder.cpp
	CMSUtils.cpp
)
