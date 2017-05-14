project(security_regressions)

add_library(security_regressions OBJECT
	testenv.c
	testmore.c
	testcert.c
	testpolicy.m
	test-00-test.c
)
