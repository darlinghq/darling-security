add_library(libsecurity_cms OBJECT
	lib/CMSDecoder.cpp
	lib/CMSEncoder.cpp
	lib/CMSUtils.cpp
)
make_fat(libsecurity_cms)
