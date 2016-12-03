project(libsecurity_transform)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/..
)

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

set_property(TARGET security_transform PROPERTY COMPILE_FLAGS "-include forceinclude.h")
