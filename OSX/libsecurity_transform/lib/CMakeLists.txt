project(libsecurity_transform)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -include ${CMAKE_CURRENT_SOURCE_DIR}/../forceinclude.h")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -include ${CMAKE_CURRENT_SOURCE_DIR}/../forceinclude.h")

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_SOURCE_DIR}/src/external/zlib)

set(security_transform_sources
	CEncryptDecrypt.c
	CoreFoundationBasics.cpp
	c++utils.cpp
	Digest.cpp
	EncodeDecodeTransforms.c
	EncryptTransform.cpp
	EncryptTransformUtilities.cpp
	GroupTransform.cpp
	LinkedList.cpp
	misc.c
	Monitor.cpp
	NullTransform.cpp
	SecCollectTransform.cpp
	SecCustomTransform.cpp
	SecDigestTransform.cpp
	SecEncryptTransform.cpp
	SecExternalSourceTransform.cpp
	SecGroupTransform.cpp
	SecMaskGenerationFunctionTransform.c
	SecNullTransform.cpp
	SecSignVerifyTransform.c
	SecTransform.cpp
	SecTransformReadTransform.cpp
	SingleShotSource.cpp
	Source.cpp
	StreamSource.cpp
	Transform.cpp
	TransformFactory.cpp
	Utilities.cpp
)

add_library(security_transform OBJECT ${security_transform_sources})

