#include <stddef.h>
#define CF_ASSUME_NONNULL_BEGIN
#ifndef CF_IMPLICIT_BRIDGING_ENABLED
#	define CF_IMPLICIT_BRIDGING_ENABLED
#	define CF_IMPLICIT_BRIDGING_DISABLED
#endif
#define CF_ASSUME_NONNULL_END
#ifndef __nullable
#	define __nullable
#	define __nonnull
#	define __weak
#endif
#ifndef CF_RETURNS_RETAINED
#	define CF_RETURNS_RETAINED
#	define CF_RETURNS_NOT_RETAINED
#endif

