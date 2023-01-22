/*
 * Generated by dtrace(1M).
 */

#ifndef	_UTILITIES_DTRACE_H
#define	_UTILITIES_DTRACE_H

#if !defined(DTRACE_PROBES_DISABLED) || !DTRACE_PROBES_DISABLED
#include <unistd.h>

#endif /* !defined(DTRACE_PROBES_DISABLED) || !DTRACE_PROBES_DISABLED */

#ifdef	__cplusplus
extern "C" {
#endif

#define SECURITY_DEBUG_STABILITY "___dtrace_stability$security_debug$v1$1_1_0_1_1_0_1_1_0_1_1_0_1_1_0"

#define SECURITY_DEBUG_TYPEDEFS "___dtrace_typedefs$security_debug$v2"

#if !defined(DTRACE_PROBES_DISABLED) || !DTRACE_PROBES_DISABLED

#define	SECURITY_DEBUG_DELAY(arg0) \
do { \
	__asm__ volatile(".reference " SECURITY_DEBUG_TYPEDEFS); \
	__dtrace_probe$security_debug$delay$v1$63686172202a(arg0); \
	__asm__ volatile(".reference " SECURITY_DEBUG_STABILITY); \
} while (0)
#define	SECURITY_DEBUG_DELAY_ENABLED() \
	({ int _r = __dtrace_isenabled$security_debug$delay$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_DEBUG_LOG(arg0, arg1) \
do { \
	__asm__ volatile(".reference " SECURITY_DEBUG_TYPEDEFS); \
	__dtrace_probe$security_debug$log$v1$63686172202a$63686172202a(arg0, arg1); \
	__asm__ volatile(".reference " SECURITY_DEBUG_STABILITY); \
} while (0)
#define	SECURITY_DEBUG_LOG_ENABLED() \
	({ int _r = __dtrace_isenabled$security_debug$log$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_DEBUG_LOGP(arg0, arg1, arg2) \
do { \
	__asm__ volatile(".reference " SECURITY_DEBUG_TYPEDEFS); \
	__dtrace_probe$security_debug$logp$v1$63686172202a$766f6964202a$63686172202a(arg0, arg1, arg2); \
	__asm__ volatile(".reference " SECURITY_DEBUG_STABILITY); \
} while (0)
#define	SECURITY_DEBUG_LOGP_ENABLED() \
	({ int _r = __dtrace_isenabled$security_debug$logp$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_DEBUG_REFCOUNT_CREATE(arg0) \
do { \
	__asm__ volatile(".reference " SECURITY_DEBUG_TYPEDEFS); \
	__dtrace_probe$security_debug$refcount__create$v1$766f6964202a(arg0); \
	__asm__ volatile(".reference " SECURITY_DEBUG_STABILITY); \
} while (0)
#define	SECURITY_DEBUG_REFCOUNT_CREATE_ENABLED() \
	({ int _r = __dtrace_isenabled$security_debug$refcount__create$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_DEBUG_REFCOUNT_DOWN(arg0, arg1) \
do { \
	__asm__ volatile(".reference " SECURITY_DEBUG_TYPEDEFS); \
	__dtrace_probe$security_debug$refcount__down$v1$766f6964202a$756e7369676e6564(arg0, arg1); \
	__asm__ volatile(".reference " SECURITY_DEBUG_STABILITY); \
} while (0)
#define	SECURITY_DEBUG_REFCOUNT_DOWN_ENABLED() \
	({ int _r = __dtrace_isenabled$security_debug$refcount__down$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_DEBUG_REFCOUNT_UP(arg0, arg1) \
do { \
	__asm__ volatile(".reference " SECURITY_DEBUG_TYPEDEFS); \
	__dtrace_probe$security_debug$refcount__up$v1$766f6964202a$756e7369676e6564(arg0, arg1); \
	__asm__ volatile(".reference " SECURITY_DEBUG_STABILITY); \
} while (0)
#define	SECURITY_DEBUG_REFCOUNT_UP_ENABLED() \
	({ int _r = __dtrace_isenabled$security_debug$refcount__up$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_DEBUG_SEC_CREATE(arg0, arg1, arg2) \
do { \
	__asm__ volatile(".reference " SECURITY_DEBUG_TYPEDEFS); \
	__dtrace_probe$security_debug$sec__create$v1$766f6964202a$63686172202a$756e7369676e6564(arg0, arg1, arg2); \
	__asm__ volatile(".reference " SECURITY_DEBUG_STABILITY); \
} while (0)
#define	SECURITY_DEBUG_SEC_CREATE_ENABLED() \
	({ int _r = __dtrace_isenabled$security_debug$sec__create$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_DEBUG_SEC_DESTROY(arg0) \
do { \
	__asm__ volatile(".reference " SECURITY_DEBUG_TYPEDEFS); \
	__dtrace_probe$security_debug$sec__destroy$v1$766f6964202a(arg0); \
	__asm__ volatile(".reference " SECURITY_DEBUG_STABILITY); \
} while (0)
#define	SECURITY_DEBUG_SEC_DESTROY_ENABLED() \
	({ int _r = __dtrace_isenabled$security_debug$sec__destroy$v1(); \
		__asm__ volatile(""); \
		_r; })


extern void __dtrace_probe$security_debug$delay$v1$63686172202a(const char *);
extern int __dtrace_isenabled$security_debug$delay$v1(void);
extern void __dtrace_probe$security_debug$log$v1$63686172202a$63686172202a(const char *, const char *);
extern int __dtrace_isenabled$security_debug$log$v1(void);
extern void __dtrace_probe$security_debug$logp$v1$63686172202a$766f6964202a$63686172202a(const char *, const void *, const char *);
extern int __dtrace_isenabled$security_debug$logp$v1(void);
extern void __dtrace_probe$security_debug$refcount__create$v1$766f6964202a(const void *);
extern int __dtrace_isenabled$security_debug$refcount__create$v1(void);
extern void __dtrace_probe$security_debug$refcount__down$v1$766f6964202a$756e7369676e6564(const void *, unsigned);
extern int __dtrace_isenabled$security_debug$refcount__down$v1(void);
extern void __dtrace_probe$security_debug$refcount__up$v1$766f6964202a$756e7369676e6564(const void *, unsigned);
extern int __dtrace_isenabled$security_debug$refcount__up$v1(void);
extern void __dtrace_probe$security_debug$sec__create$v1$766f6964202a$63686172202a$756e7369676e6564(const void *, const char *, unsigned);
extern int __dtrace_isenabled$security_debug$sec__create$v1(void);
extern void __dtrace_probe$security_debug$sec__destroy$v1$766f6964202a(const void *);
extern int __dtrace_isenabled$security_debug$sec__destroy$v1(void);

#else

#define	SECURITY_DEBUG_DELAY(arg0) \
do { \
	} while (0)
#define	SECURITY_DEBUG_DELAY_ENABLED() (0)
#define	SECURITY_DEBUG_LOG(arg0, arg1) \
do { \
	} while (0)
#define	SECURITY_DEBUG_LOG_ENABLED() (0)
#define	SECURITY_DEBUG_LOGP(arg0, arg1, arg2) \
do { \
	} while (0)
#define	SECURITY_DEBUG_LOGP_ENABLED() (0)
#define	SECURITY_DEBUG_REFCOUNT_CREATE(arg0) \
do { \
	} while (0)
#define	SECURITY_DEBUG_REFCOUNT_CREATE_ENABLED() (0)
#define	SECURITY_DEBUG_REFCOUNT_DOWN(arg0, arg1) \
do { \
	} while (0)
#define	SECURITY_DEBUG_REFCOUNT_DOWN_ENABLED() (0)
#define	SECURITY_DEBUG_REFCOUNT_UP(arg0, arg1) \
do { \
	} while (0)
#define	SECURITY_DEBUG_REFCOUNT_UP_ENABLED() (0)
#define	SECURITY_DEBUG_SEC_CREATE(arg0, arg1, arg2) \
do { \
	} while (0)
#define	SECURITY_DEBUG_SEC_CREATE_ENABLED() (0)
#define	SECURITY_DEBUG_SEC_DESTROY(arg0) \
do { \
	} while (0)
#define	SECURITY_DEBUG_SEC_DESTROY_ENABLED() (0)

#endif /* !defined(DTRACE_PROBES_DISABLED) || !DTRACE_PROBES_DISABLED */

#define SECURITY_EXCEPTION_STABILITY "___dtrace_stability$security_exception$v1$1_1_0_1_1_0_1_1_0_1_1_0_1_1_0"

#define SECURITY_EXCEPTION_TYPEDEFS "___dtrace_typedefs$security_exception$v2$4454457863657074696f6e"

#if !defined(DTRACE_PROBES_DISABLED) || !DTRACE_PROBES_DISABLED

#define	SECURITY_EXCEPTION_COPY(arg0, arg1) \
do { \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_TYPEDEFS); \
	__dtrace_probe$security_exception$copy$v1$4454457863657074696f6e$4454457863657074696f6e(arg0, arg1); \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_STABILITY); \
} while (0)
#define	SECURITY_EXCEPTION_COPY_ENABLED() \
	({ int _r = __dtrace_isenabled$security_exception$copy$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_EXCEPTION_HANDLED(arg0) \
do { \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_TYPEDEFS); \
	__dtrace_probe$security_exception$handled$v1$4454457863657074696f6e(arg0); \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_STABILITY); \
} while (0)
#define	SECURITY_EXCEPTION_HANDLED_ENABLED() \
	({ int _r = __dtrace_isenabled$security_exception$handled$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_EXCEPTION_THROW_CF(arg0) \
do { \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_TYPEDEFS); \
	__dtrace_probe$security_exception$throw__cf$v1$4454457863657074696f6e(arg0); \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_STABILITY); \
} while (0)
#define	SECURITY_EXCEPTION_THROW_CF_ENABLED() \
	({ int _r = __dtrace_isenabled$security_exception$throw__cf$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_EXCEPTION_THROW_CSSM(arg0, arg1) \
do { \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_TYPEDEFS); \
	__dtrace_probe$security_exception$throw__cssm$v1$4454457863657074696f6e$756e7369676e6564(arg0, arg1); \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_STABILITY); \
} while (0)
#define	SECURITY_EXCEPTION_THROW_CSSM_ENABLED() \
	({ int _r = __dtrace_isenabled$security_exception$throw__cssm$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_EXCEPTION_THROW_MACH(arg0, arg1) \
do { \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_TYPEDEFS); \
	__dtrace_probe$security_exception$throw__mach$v1$4454457863657074696f6e$696e74(arg0, arg1); \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_STABILITY); \
} while (0)
#define	SECURITY_EXCEPTION_THROW_MACH_ENABLED() \
	({ int _r = __dtrace_isenabled$security_exception$throw__mach$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_EXCEPTION_THROW_OSSTATUS(arg0, arg1) \
do { \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_TYPEDEFS); \
	__dtrace_probe$security_exception$throw__osstatus$v1$4454457863657074696f6e$696e74(arg0, arg1); \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_STABILITY); \
} while (0)
#define	SECURITY_EXCEPTION_THROW_OSSTATUS_ENABLED() \
	({ int _r = __dtrace_isenabled$security_exception$throw__osstatus$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_EXCEPTION_THROW_OTHER(arg0, arg1, arg2) \
do { \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_TYPEDEFS); \
	__dtrace_probe$security_exception$throw__other$v1$4454457863657074696f6e$756e7369676e6564$63686172202a(arg0, arg1, arg2); \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_STABILITY); \
} while (0)
#define	SECURITY_EXCEPTION_THROW_OTHER_ENABLED() \
	({ int _r = __dtrace_isenabled$security_exception$throw__other$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_EXCEPTION_THROW_PCSC(arg0, arg1) \
do { \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_TYPEDEFS); \
	__dtrace_probe$security_exception$throw__pcsc$v1$4454457863657074696f6e$756e7369676e6564(arg0, arg1); \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_STABILITY); \
} while (0)
#define	SECURITY_EXCEPTION_THROW_PCSC_ENABLED() \
	({ int _r = __dtrace_isenabled$security_exception$throw__pcsc$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_EXCEPTION_THROW_SQLITE(arg0, arg1, arg2) \
do { \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_TYPEDEFS); \
	__dtrace_probe$security_exception$throw__sqlite$v1$4454457863657074696f6e$696e74$63686172202a(arg0, arg1, arg2); \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_STABILITY); \
} while (0)
#define	SECURITY_EXCEPTION_THROW_SQLITE_ENABLED() \
	({ int _r = __dtrace_isenabled$security_exception$throw__sqlite$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_EXCEPTION_THROW_UNIX(arg0, arg1) \
do { \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_TYPEDEFS); \
	__dtrace_probe$security_exception$throw__unix$v1$4454457863657074696f6e$696e74(arg0, arg1); \
	__asm__ volatile(".reference " SECURITY_EXCEPTION_STABILITY); \
} while (0)
#define	SECURITY_EXCEPTION_THROW_UNIX_ENABLED() \
	({ int _r = __dtrace_isenabled$security_exception$throw__unix$v1(); \
		__asm__ volatile(""); \
		_r; })


extern void __dtrace_probe$security_exception$copy$v1$4454457863657074696f6e$4454457863657074696f6e(DTException, DTException);
extern int __dtrace_isenabled$security_exception$copy$v1(void);
extern void __dtrace_probe$security_exception$handled$v1$4454457863657074696f6e(DTException);
extern int __dtrace_isenabled$security_exception$handled$v1(void);
extern void __dtrace_probe$security_exception$throw__cf$v1$4454457863657074696f6e(DTException);
extern int __dtrace_isenabled$security_exception$throw__cf$v1(void);
extern void __dtrace_probe$security_exception$throw__cssm$v1$4454457863657074696f6e$756e7369676e6564(DTException, unsigned);
extern int __dtrace_isenabled$security_exception$throw__cssm$v1(void);
extern void __dtrace_probe$security_exception$throw__mach$v1$4454457863657074696f6e$696e74(DTException, int);
extern int __dtrace_isenabled$security_exception$throw__mach$v1(void);
extern void __dtrace_probe$security_exception$throw__osstatus$v1$4454457863657074696f6e$696e74(DTException, int);
extern int __dtrace_isenabled$security_exception$throw__osstatus$v1(void);
extern void __dtrace_probe$security_exception$throw__other$v1$4454457863657074696f6e$756e7369676e6564$63686172202a(DTException, unsigned, const char *);
extern int __dtrace_isenabled$security_exception$throw__other$v1(void);
extern void __dtrace_probe$security_exception$throw__pcsc$v1$4454457863657074696f6e$756e7369676e6564(DTException, unsigned);
extern int __dtrace_isenabled$security_exception$throw__pcsc$v1(void);
extern void __dtrace_probe$security_exception$throw__sqlite$v1$4454457863657074696f6e$696e74$63686172202a(DTException, int, const char *);
extern int __dtrace_isenabled$security_exception$throw__sqlite$v1(void);
extern void __dtrace_probe$security_exception$throw__unix$v1$4454457863657074696f6e$696e74(DTException, int);
extern int __dtrace_isenabled$security_exception$throw__unix$v1(void);

#else

#define	SECURITY_EXCEPTION_COPY(arg0, arg1) \
do { \
	} while (0)
#define	SECURITY_EXCEPTION_COPY_ENABLED() (0)
#define	SECURITY_EXCEPTION_HANDLED(arg0) \
do { \
	} while (0)
#define	SECURITY_EXCEPTION_HANDLED_ENABLED() (0)
#define	SECURITY_EXCEPTION_THROW_CF(arg0) \
do { \
	} while (0)
#define	SECURITY_EXCEPTION_THROW_CF_ENABLED() (0)
#define	SECURITY_EXCEPTION_THROW_CSSM(arg0, arg1) \
do { \
	} while (0)
#define	SECURITY_EXCEPTION_THROW_CSSM_ENABLED() (0)
#define	SECURITY_EXCEPTION_THROW_MACH(arg0, arg1) \
do { \
	} while (0)
#define	SECURITY_EXCEPTION_THROW_MACH_ENABLED() (0)
#define	SECURITY_EXCEPTION_THROW_OSSTATUS(arg0, arg1) \
do { \
	} while (0)
#define	SECURITY_EXCEPTION_THROW_OSSTATUS_ENABLED() (0)
#define	SECURITY_EXCEPTION_THROW_OTHER(arg0, arg1, arg2) \
do { \
	} while (0)
#define	SECURITY_EXCEPTION_THROW_OTHER_ENABLED() (0)
#define	SECURITY_EXCEPTION_THROW_PCSC(arg0, arg1) \
do { \
	} while (0)
#define	SECURITY_EXCEPTION_THROW_PCSC_ENABLED() (0)
#define	SECURITY_EXCEPTION_THROW_SQLITE(arg0, arg1, arg2) \
do { \
	} while (0)
#define	SECURITY_EXCEPTION_THROW_SQLITE_ENABLED() (0)
#define	SECURITY_EXCEPTION_THROW_UNIX(arg0, arg1) \
do { \
	} while (0)
#define	SECURITY_EXCEPTION_THROW_UNIX_ENABLED() (0)

#endif /* !defined(DTRACE_PROBES_DISABLED) || !DTRACE_PROBES_DISABLED */

#define SECURITY_MACHSERVER_STABILITY "___dtrace_stability$security_machserver$v1$1_1_0_1_1_0_1_1_0_1_1_0_1_1_0"

#define SECURITY_MACHSERVER_TYPEDEFS "___dtrace_typedefs$security_machserver$v2"

#if !defined(DTRACE_PROBES_DISABLED) || !DTRACE_PROBES_DISABLED

#define	SECURITY_MACHSERVER_ALLOC_REGISTER(arg0, arg1) \
do { \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_TYPEDEFS); \
	__dtrace_probe$security_machserver$alloc__register$v1$766f6964202a$766f6964202a(arg0, arg1); \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_STABILITY); \
} while (0)
#define	SECURITY_MACHSERVER_ALLOC_REGISTER_ENABLED() \
	({ int _r = __dtrace_isenabled$security_machserver$alloc__register$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_MACHSERVER_ALLOC_RELEASE(arg0, arg1) \
do { \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_TYPEDEFS); \
	__dtrace_probe$security_machserver$alloc__release$v1$766f6964202a$766f6964202a(arg0, arg1); \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_STABILITY); \
} while (0)
#define	SECURITY_MACHSERVER_ALLOC_RELEASE_ENABLED() \
	({ int _r = __dtrace_isenabled$security_machserver$alloc__release$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_MACHSERVER_BEGIN(arg0, arg1) \
do { \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_TYPEDEFS); \
	__dtrace_probe$security_machserver$begin$v1$756e7369676e6564$696e74(arg0, arg1); \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_STABILITY); \
} while (0)
#define	SECURITY_MACHSERVER_BEGIN_ENABLED() \
	({ int _r = __dtrace_isenabled$security_machserver$begin$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_MACHSERVER_END() \
do { \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_TYPEDEFS); \
	__dtrace_probe$security_machserver$end$v1(); \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_STABILITY); \
} while (0)
#define	SECURITY_MACHSERVER_END_ENABLED() \
	({ int _r = __dtrace_isenabled$security_machserver$end$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_MACHSERVER_END_THREAD(arg0) \
do { \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_TYPEDEFS); \
	__dtrace_probe$security_machserver$end_thread$v1$696e74(arg0); \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_STABILITY); \
} while (0)
#define	SECURITY_MACHSERVER_END_THREAD_ENABLED() \
	({ int _r = __dtrace_isenabled$security_machserver$end_thread$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_MACHSERVER_PORT_ADD(arg0) \
do { \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_TYPEDEFS); \
	__dtrace_probe$security_machserver$port__add$v1$756e7369676e6564(arg0); \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_STABILITY); \
} while (0)
#define	SECURITY_MACHSERVER_PORT_ADD_ENABLED() \
	({ int _r = __dtrace_isenabled$security_machserver$port__add$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_MACHSERVER_PORT_REMOVE(arg0) \
do { \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_TYPEDEFS); \
	__dtrace_probe$security_machserver$port__remove$v1$756e7369676e6564(arg0); \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_STABILITY); \
} while (0)
#define	SECURITY_MACHSERVER_PORT_REMOVE_ENABLED() \
	({ int _r = __dtrace_isenabled$security_machserver$port__remove$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_MACHSERVER_REAP(arg0, arg1) \
do { \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_TYPEDEFS); \
	__dtrace_probe$security_machserver$reap$v1$756e7369676e6564$756e7369676e6564(arg0, arg1); \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_STABILITY); \
} while (0)
#define	SECURITY_MACHSERVER_REAP_ENABLED() \
	({ int _r = __dtrace_isenabled$security_machserver$reap$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_MACHSERVER_RECEIVE(arg0) \
do { \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_TYPEDEFS); \
	__dtrace_probe$security_machserver$receive$v1$646f75626c65(arg0); \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_STABILITY); \
} while (0)
#define	SECURITY_MACHSERVER_RECEIVE_ENABLED() \
	({ int _r = __dtrace_isenabled$security_machserver$receive$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_MACHSERVER_RECEIVE_ERROR(arg0) \
do { \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_TYPEDEFS); \
	__dtrace_probe$security_machserver$receive_error$v1$756e7369676e6564(arg0); \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_STABILITY); \
} while (0)
#define	SECURITY_MACHSERVER_RECEIVE_ERROR_ENABLED() \
	({ int _r = __dtrace_isenabled$security_machserver$receive_error$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_MACHSERVER_SEND_ERROR(arg0, arg1) \
do { \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_TYPEDEFS); \
	__dtrace_probe$security_machserver$send_error$v1$756e7369676e6564$756e7369676e6564(arg0, arg1); \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_STABILITY); \
} while (0)
#define	SECURITY_MACHSERVER_SEND_ERROR_ENABLED() \
	({ int _r = __dtrace_isenabled$security_machserver$send_error$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_MACHSERVER_START_THREAD(arg0) \
do { \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_TYPEDEFS); \
	__dtrace_probe$security_machserver$start_thread$v1$696e74(arg0); \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_STABILITY); \
} while (0)
#define	SECURITY_MACHSERVER_START_THREAD_ENABLED() \
	({ int _r = __dtrace_isenabled$security_machserver$start_thread$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_MACHSERVER_TIMER_END(arg0) \
do { \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_TYPEDEFS); \
	__dtrace_probe$security_machserver$timer__end$v1$696e74(arg0); \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_STABILITY); \
} while (0)
#define	SECURITY_MACHSERVER_TIMER_END_ENABLED() \
	({ int _r = __dtrace_isenabled$security_machserver$timer__end$v1(); \
		__asm__ volatile(""); \
		_r; })
#define	SECURITY_MACHSERVER_TIMER_START(arg0, arg1, arg2) \
do { \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_TYPEDEFS); \
	__dtrace_probe$security_machserver$timer__start$v1$766f6964202a$696e74$646f75626c65(arg0, arg1, arg2); \
	__asm__ volatile(".reference " SECURITY_MACHSERVER_STABILITY); \
} while (0)
#define	SECURITY_MACHSERVER_TIMER_START_ENABLED() \
	({ int _r = __dtrace_isenabled$security_machserver$timer__start$v1(); \
		__asm__ volatile(""); \
		_r; })


extern void __dtrace_probe$security_machserver$alloc__register$v1$766f6964202a$766f6964202a(const void *, const void *);
extern int __dtrace_isenabled$security_machserver$alloc__register$v1(void);
extern void __dtrace_probe$security_machserver$alloc__release$v1$766f6964202a$766f6964202a(const void *, const void *);
extern int __dtrace_isenabled$security_machserver$alloc__release$v1(void);
extern void __dtrace_probe$security_machserver$begin$v1$756e7369676e6564$696e74(unsigned, int);
extern int __dtrace_isenabled$security_machserver$begin$v1(void);
extern void __dtrace_probe$security_machserver$end$v1(void);
extern int __dtrace_isenabled$security_machserver$end$v1(void);
extern void __dtrace_probe$security_machserver$end_thread$v1$696e74(int);
extern int __dtrace_isenabled$security_machserver$end_thread$v1(void);
extern void __dtrace_probe$security_machserver$port__add$v1$756e7369676e6564(unsigned);
extern int __dtrace_isenabled$security_machserver$port__add$v1(void);
extern void __dtrace_probe$security_machserver$port__remove$v1$756e7369676e6564(unsigned);
extern int __dtrace_isenabled$security_machserver$port__remove$v1(void);
extern void __dtrace_probe$security_machserver$reap$v1$756e7369676e6564$756e7369676e6564(unsigned, unsigned);
extern int __dtrace_isenabled$security_machserver$reap$v1(void);
extern void __dtrace_probe$security_machserver$receive$v1$646f75626c65(double);
extern int __dtrace_isenabled$security_machserver$receive$v1(void);
extern void __dtrace_probe$security_machserver$receive_error$v1$756e7369676e6564(unsigned);
extern int __dtrace_isenabled$security_machserver$receive_error$v1(void);
extern void __dtrace_probe$security_machserver$send_error$v1$756e7369676e6564$756e7369676e6564(unsigned, unsigned);
extern int __dtrace_isenabled$security_machserver$send_error$v1(void);
extern void __dtrace_probe$security_machserver$start_thread$v1$696e74(int);
extern int __dtrace_isenabled$security_machserver$start_thread$v1(void);
extern void __dtrace_probe$security_machserver$timer__end$v1$696e74(int);
extern int __dtrace_isenabled$security_machserver$timer__end$v1(void);
extern void __dtrace_probe$security_machserver$timer__start$v1$766f6964202a$696e74$646f75626c65(const void *, int, double);
extern int __dtrace_isenabled$security_machserver$timer__start$v1(void);

#else

#define	SECURITY_MACHSERVER_ALLOC_REGISTER(arg0, arg1) \
do { \
	} while (0)
#define	SECURITY_MACHSERVER_ALLOC_REGISTER_ENABLED() (0)
#define	SECURITY_MACHSERVER_ALLOC_RELEASE(arg0, arg1) \
do { \
	} while (0)
#define	SECURITY_MACHSERVER_ALLOC_RELEASE_ENABLED() (0)
#define	SECURITY_MACHSERVER_BEGIN(arg0, arg1) \
do { \
	} while (0)
#define	SECURITY_MACHSERVER_BEGIN_ENABLED() (0)
#define	SECURITY_MACHSERVER_END() \
do { \
	} while (0)
#define	SECURITY_MACHSERVER_END_ENABLED() (0)
#define	SECURITY_MACHSERVER_END_THREAD(arg0) \
do { \
	} while (0)
#define	SECURITY_MACHSERVER_END_THREAD_ENABLED() (0)
#define	SECURITY_MACHSERVER_PORT_ADD(arg0) \
do { \
	} while (0)
#define	SECURITY_MACHSERVER_PORT_ADD_ENABLED() (0)
#define	SECURITY_MACHSERVER_PORT_REMOVE(arg0) \
do { \
	} while (0)
#define	SECURITY_MACHSERVER_PORT_REMOVE_ENABLED() (0)
#define	SECURITY_MACHSERVER_REAP(arg0, arg1) \
do { \
	} while (0)
#define	SECURITY_MACHSERVER_REAP_ENABLED() (0)
#define	SECURITY_MACHSERVER_RECEIVE(arg0) \
do { \
	} while (0)
#define	SECURITY_MACHSERVER_RECEIVE_ENABLED() (0)
#define	SECURITY_MACHSERVER_RECEIVE_ERROR(arg0) \
do { \
	} while (0)
#define	SECURITY_MACHSERVER_RECEIVE_ERROR_ENABLED() (0)
#define	SECURITY_MACHSERVER_SEND_ERROR(arg0, arg1) \
do { \
	} while (0)
#define	SECURITY_MACHSERVER_SEND_ERROR_ENABLED() (0)
#define	SECURITY_MACHSERVER_START_THREAD(arg0) \
do { \
	} while (0)
#define	SECURITY_MACHSERVER_START_THREAD_ENABLED() (0)
#define	SECURITY_MACHSERVER_TIMER_END(arg0) \
do { \
	} while (0)
#define	SECURITY_MACHSERVER_TIMER_END_ENABLED() (0)
#define	SECURITY_MACHSERVER_TIMER_START(arg0, arg1, arg2) \
do { \
	} while (0)
#define	SECURITY_MACHSERVER_TIMER_START_ENABLED() (0)

#endif /* !defined(DTRACE_PROBES_DISABLED) || !DTRACE_PROBES_DISABLED */


#ifdef	__cplusplus
}
#endif

#endif	/* _UTILITIES_DTRACE_H */
