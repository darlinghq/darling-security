project(libsecurity_utilities)

add_definitions(
	-D__strong=
)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/.. # dtrace_fake.h
)

add_library(security_utilities OBJECT
	adornments.cpp
	alloc.cpp
	blob.cpp
	bufferfifo.cpp
	buffers.cpp
	ccaudit.cpp
	cfclass.cpp
	cfmach++.cpp
	cfmunge.cpp
	cfutilities.cpp
	coderepository.cpp
	daemon.cpp
	debugging.cpp
	debugging_internal.cpp
	devrandom.cpp
	#dispatch.cpp
	dyldcache.cpp
	endian.cpp
	errors.cpp
	fdmover.cpp
	fdsel.cpp
	globalizer.cpp
	hashing.cpp
	headermap.cpp
	hosts.cpp
	inetreply.cpp
	#iodevices.cpp
	ip++.cpp
	kq++.cpp
	logging.cpp
	mach++.cpp
	macho++.cpp
	machrunloopserver.cpp
	machserver.cpp
	#muscle++.cpp
	osxcode.cpp
	#pcsc++.cpp
	#powerwatch.cpp
	seccfobject.cpp
	selector.cpp
	simpleprefs.cpp
	socks++.cpp
	socks++4.cpp
	socks++5.cpp
	sqlite++.cpp
	streams.cpp
	superblob.cpp
	threading.cpp
	timeflow.cpp
	tqueue.cpp
	trackingallocator.cpp
	transactions.cpp
	typedvalue.cpp
	unix++.cpp
	unixchild.cpp
	url.cpp
	utilities.cpp
	vproc++.cpp
)

set_property(TARGET security_utilities PROPERTY
	COMPILE_FLAGS "-include dtrace_fake.h -include security-duct.h")
