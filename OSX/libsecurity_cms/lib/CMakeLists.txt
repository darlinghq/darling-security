project(security_cms)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(security_cms OBJECT
	# CMSDecoder.cpp	FIXME: dispatch_qos_class_t
	# CMSEncoder.cpp	FIXME: CF_BRIDGED_TYPE
	CMSUtils.cpp
)
