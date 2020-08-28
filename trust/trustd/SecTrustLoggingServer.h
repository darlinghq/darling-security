/*
 * Copyright (c) 2016-2018 Apple Inc. All Rights Reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 *
 * SecTrustLoggingServer.h - logging for certificate trust evaluation engine
 *
 */

#ifndef _SECURITY_SECTRUSTLOGGINGSERVER_H_
#define _SECURITY_SECTRUSTLOGGINGSERVER_H_

#include <xpc/xpc.h>
#include <CoreFoundation/CoreFoundation.h>

void DisableLocalization(void);

// i have a sneaking suspicion that Apple neutered this file and that this is where
// `TrustdHealthAnalyticsLogErrorCodeForDatabase` *should* be defined,
// so that's what i'll do:
void TrustdHealthAnalyticsLogErrorCodeForDatabase(int location, int operation, int error_type, int error_code);
// note that i'm not entirely sure about that last parameter type
// and those other parameters are dependent on the types of the following definitions

// this is also probably where these were supposed to be defined:

enum /* location */ {
	TACAIssuerCache,
	TAOCSPCache,
	TARevocationDb,
	TATrustStore,
};

enum /* operation */ {
	TAOperationRead,
	TAOperationWrite,
	TAOperationCreate,
	TAOperationOpen,
};

enum /* error type (?) */ {
	TAFatalError,
	TARecoverableError,
};

// i'm guessing this is also where this belongs:
bool SecNetworkingAnalyticsReport(CFStringRef event_name, xpc_object_t tls_analytics_attributes, CFErrorRef *error);

// same with this:
void TrustdHealthAnalyticsLogErrorCode(int event, int error_type, int error_code);

enum /* event */ {
	TAEventValidUpdate,
};

// same here:
void TrustdHealthAnalyticsLogEvaluationCompleted();

// and you guessed it, same here:
void TrustdHealthAnalyticsLogSuccess(int event);

#endif /* _SECURITY_SECTRUSTLOGGINGSERVER_H_ */
