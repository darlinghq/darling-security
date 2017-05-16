project(libsecurity_utilities)

add_definitions(-D__strong=)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/.. # dtrace_fake.h
)

add_library(security_utilities OBJECT
	alloc.cpp
	bufferfifo.cpp
	buffers.cpp
	cfmunge.cpp
	cfutilities.cpp
	dispatch.cpp
	daemon.cpp
	debugging.cpp
	devrandom.cpp
	dyldcache.cpp
	endian.cpp
	errors.cpp
	fdmover.cpp
	fdsel.cpp
	globalizer.cpp
	headermap.cpp
	hosts.cpp
	inetreply.cpp
	ip++.cpp
	logging.cpp
	mach++.cpp
	mach_notify.c
	macho++.cpp
	machrunloopserver.cpp
	machserver.cpp
	powerwatch.cpp
	selector.cpp
	socks++.cpp
	socks++4.cpp
	socks++5.cpp
	streams.cpp
	threading.cpp
	timeflow.cpp
	tqueue.cpp
	trackingallocator.cpp
	typedvalue.cpp
	unix++.cpp
	url.cpp
	utilities.cpp
	cfclass.cpp
	seccfobject.cpp
	pcsc++.cpp
	unixchild.cpp
	osxcode.cpp
	cfmach++.cpp
	adornments.cpp
	muscle++.cpp
	transactions.cpp
	simpleprefs.cpp
	iodevices.cpp
	coderepository.cpp
	ccaudit.cpp
	hashing.cpp
	blob.cpp
	superblob.cpp
	crc.c
	vproc++.cpp
	sqlite++.cpp
	kq++.cpp
	debugging_internal.cpp
)

set_property(TARGET security_utilities PROPERTY
	COMPILE_FLAGS "-include dtrace_fake.h -include security-duct.h")
