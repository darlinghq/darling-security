/*
 * Copyright (c) 2026 Darling contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef _SECITEM_SECRET_SERVICE_H_
#define _SECITEM_SECRET_SERVICE_H_

#include <CoreFoundation/CoreFoundation.h>

/*
 * Result codes for the optional freedesktop Secret Service backend.
 *
 * Unavailable means the caller should continue with the normal SQLite
 * keychain path: the backend is switched off (the default), cannot reach the
 * Secret Service, does not handle this kind of item, or, for copy, update and
 * delete, does not hold the item. Handled means the operation was completed by
 * the backend. Failed means the backend was active and the operation failed;
 * the error object contains the public OSStatus.
 */
typedef enum {
    kSecItemSecretServiceUnavailable = 0,
    kSecItemSecretServiceHandled,
    kSecItemSecretServiceFailed
} SecItemSecretServiceResult;

SecItemSecretServiceResult SecItemSecretServiceAdd(CFDictionaryRef attributes,
    CFDataRef data, CFErrorRef *error);

SecItemSecretServiceResult SecItemSecretServiceCopy(CFDictionaryRef query,
    CFDataRef *data, CFErrorRef *error);

SecItemSecretServiceResult SecItemSecretServiceUpdate(CFDictionaryRef query,
    CFDictionaryRef attributesToUpdate, CFErrorRef *error);

SecItemSecretServiceResult SecItemSecretServiceDelete(CFDictionaryRef query,
    CFErrorRef *error);

#endif /* _SECITEM_SECRET_SERVICE_H_ */
