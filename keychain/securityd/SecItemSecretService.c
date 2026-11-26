/*
 * Copyright (c) 2026 Darling contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "SecItemSecretService.h"

#include <Security/SecBase.h>
#include <Security/SecItem.h>
#include <utilities/SecCFError.h>
#include <utilities/SecCFRelease.h>

#ifdef DARLING_USE_SECRET_SERVICE

#include <libsecret/secret.h>
#include <glib.h>

#include <inttypes.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/*
 * The freedesktop Secret Service stores string attributes and text values.
 * SecItem attributes are flattened to strings and kSecValueData is carried as
 * base64 so arbitrary binary values survive the round trip.
 */
static const SecretSchema kDarlingSecItemSchema = {
    "org.darling.Security.SecItem",
    SECRET_SCHEMA_DONT_MATCH_NAME,
    {
        { "class",              SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "service",            SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "account",            SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "access-group",       SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "server",             SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "protocol",           SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "port",               SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "path",               SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "security-domain",    SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "authentication-type", SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "generic",            SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "label",              SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "description",        SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "comment",            SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "creator",            SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "type",               SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "value-encoding",     SECRET_SCHEMA_ATTRIBUTE_STRING },
        { NULL, 0 }
    }
};

static gsize gAttributeNamesInitialized = 0;
static GHashTable *gAttributeNames = NULL;

static void
AddAttributeName(GHashTable *names, CFTypeRef key, const char *name)
{
    g_hash_table_insert(names, (gpointer)key, (gpointer)name);
}

static GHashTable *
GetAttributeNames(void)
{
    if (g_once_init_enter(&gAttributeNamesInitialized)) {
        GHashTable *names = g_hash_table_new(g_direct_hash, g_direct_equal);
        AddAttributeName(names, kSecAttrService, "service");
        AddAttributeName(names, kSecAttrAccount, "account");
        AddAttributeName(names, kSecAttrAccessGroup, "access-group");
        AddAttributeName(names, kSecAttrServer, "server");
        AddAttributeName(names, kSecAttrProtocol, "protocol");
        AddAttributeName(names, kSecAttrPort, "port");
        AddAttributeName(names, kSecAttrPath, "path");
        AddAttributeName(names, kSecAttrSecurityDomain, "security-domain");
        AddAttributeName(names, kSecAttrAuthenticationType, "authentication-type");
        AddAttributeName(names, kSecAttrGeneric, "generic");
        AddAttributeName(names, kSecAttrLabel, "label");
        AddAttributeName(names, kSecAttrDescription, "description");
        AddAttributeName(names, kSecAttrComment, "comment");
        AddAttributeName(names, kSecAttrCreator, "creator");
        AddAttributeName(names, kSecAttrType, "type");
        gAttributeNames = names;
        g_once_init_leave(&gAttributeNamesInitialized, 1);
    }
    return gAttributeNames;
}

/*
 * Once a Secret Service call fails there is no session bus or usable default
 * collection. Keep subsequent SecItem calls on the SQLite path instead of
 * retrying a blocking D-Bus operation for every item.
 */
static bool gSecretServiceDisabled = false;

static bool
SecretServiceEnabled(void)
{
    return !gSecretServiceDisabled;
}

static void
DisableSecretService(GError *error)
{
    if (error != NULL) {
        g_error_free(error);
        gSecretServiceDisabled = true;
    }
}

static char *
CopyCFStringUTF8(CFStringRef string)
{
    if (string == NULL)
        return NULL;

    CFIndex maximum = CFStringGetMaximumSizeForEncoding(CFStringGetLength(string),
        kCFStringEncodingUTF8) + 1;
    char *buffer = g_malloc0((gsize)maximum);
    if (buffer == NULL)
        return NULL;
    if (!CFStringGetCString(string, buffer, (CFIndex)maximum, kCFStringEncodingUTF8)) {
        g_free(buffer);
        return NULL;
    }
    return buffer;
}

static char *
CopyCFTypeString(CFTypeRef value)
{
    if (value == NULL)
        return NULL;

    CFTypeID type = CFGetTypeID(value);
    if (type == CFStringGetTypeID())
        return CopyCFStringUTF8((CFStringRef)value);

    if (type == CFBooleanGetTypeID())
        return g_strdup(CFBooleanGetValue((CFBooleanRef)value) ? "true" : "false");

    if (type == CFNumberGetTypeID()) {
        int64_t number = 0;
        if (CFNumberGetValue((CFNumberRef)value, kCFNumberSInt64Type, &number))
            return g_strdup_printf("%" PRId64, number);
        return NULL;
    }

    if (type == CFDataGetTypeID()) {
        CFDataRef data = (CFDataRef)value;
        gsize length = (gsize)CFDataGetLength(data);
        return length == 0 ? g_strdup("") :
            g_base64_encode(CFDataGetBytePtr(data), length);
    }

    return NULL;
}

static char *
CopyClassString(CFTypeRef class)
{
    if (class == NULL)
        return NULL;
    if (CFEqual(class, kSecClassGenericPassword))
        return g_strdup("generic");
    if (CFEqual(class, kSecClassInternetPassword))
        return g_strdup("internet");
    return NULL;
}

static GHashTable *
CreateAttributeTable(CFDictionaryRef dictionary, bool includeClass)
{
    GHashTable *attributes = g_hash_table_new_full(g_str_hash, g_str_equal,
        g_free, g_free);
    if (attributes == NULL || dictionary == NULL)
        return attributes;

    if (includeClass) {
        char *class = CopyClassString(CFDictionaryGetValue(dictionary, kSecClass));
        if (class != NULL)
            g_hash_table_insert(attributes, g_strdup("class"), class);
    }

    GHashTable *names = GetAttributeNames();
    GHashTableIter iter;
    gpointer key = NULL;
    gpointer name = NULL;
    g_hash_table_iter_init(&iter, names);
    while (g_hash_table_iter_next(&iter, &key, &name)) {
        CFTypeRef value = CFDictionaryGetValue(dictionary, (CFTypeRef)key);
        if (value == NULL)
            continue;
        char *string = CopyCFTypeString(value);
        if (string == NULL)
            continue;
        g_hash_table_insert(attributes, g_strdup((const char *)name), string);
    }

    return attributes;
}

static void
MergeAttributes(GHashTable *destination, GHashTable *source)
{
    GHashTableIter iter;
    gpointer key = NULL;
    gpointer value = NULL;

    g_hash_table_iter_init(&iter, source);
    while (g_hash_table_iter_next(&iter, &key, &value))
        g_hash_table_insert(destination, g_strdup((const char *)key),
            g_strdup((const char *)value));
}

static bool
TablesEqual(GHashTable *left, GHashTable *right)
{
    if (g_hash_table_size(left) != g_hash_table_size(right))
        return false;

    GHashTableIter iter;
    gpointer key = NULL;
    gpointer value = NULL;
    g_hash_table_iter_init(&iter, left);
    while (g_hash_table_iter_next(&iter, &key, &value)) {
        const char *other = g_hash_table_lookup(right, key);
        if (other == NULL || strcmp((const char *)value, other) != 0)
            return false;
    }
    return true;
}

static bool
IsSupportedCredential(GHashTable *attributes)
{
    const char *class = g_hash_table_lookup(attributes, "class");
    if (class == NULL)
        return false;

    if (strcmp(class, "generic") == 0)
        return g_hash_table_lookup(attributes, "service") != NULL &&
               g_hash_table_lookup(attributes, "account") != NULL;

    if (strcmp(class, "internet") == 0)
        return g_hash_table_lookup(attributes, "server") != NULL &&
               g_hash_table_lookup(attributes, "account") != NULL;

    return false;
}

static CFDataRef
CopyDataValue(CFTypeRef value)
{
    if (value == NULL)
        return NULL;
    if (CFGetTypeID(value) == CFDataGetTypeID())
        return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)value);
    if (CFGetTypeID(value) == CFStringGetTypeID()) {
        char *string = CopyCFStringUTF8((CFStringRef)value);
        if (string == NULL)
            return NULL;
        CFDataRef data = CFDataCreate(kCFAllocatorDefault,
            (const UInt8 *)string, (CFIndex)strlen(string));
        g_free(string);
        return data;
    }
    return NULL;
}

static CFDataRef
CopyStoredValue(GHashTable *attributes, bool *serviceError)
{
    GError *error = NULL;
    gchar *encoded = secret_password_lookupv_sync(&kDarlingSecItemSchema,
        attributes, NULL, &error);
    if (error != NULL) {
        DisableSecretService(error);
        if (serviceError != NULL)
            *serviceError = true;
        return NULL;
    }
    if (encoded == NULL)
        return NULL;

    gsize length = 0;
    guchar *bytes = (guchar *)g_base64_decode(encoded, &length);
    CFDataRef data = bytes != NULL ? CFDataCreate(kCFAllocatorDefault,
        bytes, (CFIndex)length) : NULL;
    g_free(bytes);
    g_free(encoded);
    return data;
}

static bool
StoreValue(GHashTable *attributes, CFDataRef data)
{
    const char *label = g_hash_table_lookup(attributes, "label");
    if (label == NULL)
        label = "Darling keychain item";

    g_hash_table_insert(attributes, g_strdup("value-encoding"), g_strdup("base64"));
    gsize length = (gsize)CFDataGetLength(data);
    gchar *encoded = length == 0 ? g_strdup("") :
        g_base64_encode(CFDataGetBytePtr(data), length);
    GError *error = NULL;
    gboolean stored = secret_password_storev_sync(&kDarlingSecItemSchema,
        attributes, NULL, label, encoded, NULL, &error);
    DisableSecretService(error);
    g_free(encoded);
    return stored;
}

static bool
ClearStoredValues(GHashTable *attributes, bool *serviceError)
{
    GError *error = NULL;
    gboolean cleared = secret_password_clearv_sync(&kDarlingSecItemSchema,
        attributes, NULL, &error);
    if (error != NULL) {
        DisableSecretService(error);
        if (serviceError != NULL)
            *serviceError = true;
        return false;
    }
    return cleared;
}

SecItemSecretServiceResult
SecItemSecretServiceAdd(CFDictionaryRef attributes, CFDataRef data, CFErrorRef *error)
{
    if (!SecretServiceEnabled())
        return kSecItemSecretServiceUnavailable;

    GHashTable *itemAttributes = CreateAttributeTable(attributes, true);
    if (!IsSupportedCredential(itemAttributes)) {
        g_hash_table_unref(itemAttributes);
        return kSecItemSecretServiceUnavailable;
    }

    bool serviceError = false;
    CFDataRef existing = CopyStoredValue(itemAttributes, &serviceError);
    if (serviceError) {
        g_hash_table_unref(itemAttributes);
        return kSecItemSecretServiceUnavailable;
    }
    if (existing != NULL) {
        CFRelease(existing);
        SecError(errSecDuplicateItem, error,
            CFSTR("Secret Service item already exists"));
        g_hash_table_unref(itemAttributes);
        return kSecItemSecretServiceFailed;
    }

    CFDataRef empty = NULL;
    if (data == NULL)
        empty = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)"", 0);
    bool stored = StoreValue(itemAttributes, data != NULL ? data : empty);
    CFReleaseNull(empty);
    g_hash_table_unref(itemAttributes);

    if (!stored) {
        if (!SecretServiceEnabled())
            return kSecItemSecretServiceUnavailable;
        SecError(errSecInternalComponent, error,
            CFSTR("failed to store item in Secret Service"));
        return kSecItemSecretServiceFailed;
    }
    return kSecItemSecretServiceHandled;
}

SecItemSecretServiceResult
SecItemSecretServiceCopy(CFDictionaryRef query, CFDataRef *data, CFErrorRef *error)
{
    if (!SecretServiceEnabled())
        return kSecItemSecretServiceUnavailable;

    GHashTable *queryAttributes = CreateAttributeTable(query, true);
    if (!IsSupportedCredential(queryAttributes)) {
        g_hash_table_unref(queryAttributes);
        return kSecItemSecretServiceUnavailable;
    }

    bool serviceError = false;
    CFDataRef value = CopyStoredValue(queryAttributes, &serviceError);
    g_hash_table_unref(queryAttributes);

    if (serviceError)
        return kSecItemSecretServiceUnavailable;
    if (value == NULL) {
        SecError(errSecItemNotFound, error,
            CFSTR("no matching Secret Service item found"));
        return kSecItemSecretServiceFailed;
    }

    *data = value;
    return kSecItemSecretServiceHandled;
}

SecItemSecretServiceResult
SecItemSecretServiceUpdate(CFDictionaryRef query, CFDictionaryRef attributesToUpdate,
    CFErrorRef *error)
{
    if (!SecretServiceEnabled())
        return kSecItemSecretServiceUnavailable;

    GHashTable *queryAttributes = CreateAttributeTable(query, true);
    if (!IsSupportedCredential(queryAttributes)) {
        g_hash_table_unref(queryAttributes);
        return kSecItemSecretServiceUnavailable;
    }

    bool serviceError = false;
    CFDataRef existing = CopyStoredValue(queryAttributes, &serviceError);
    if (serviceError) {
        g_hash_table_unref(queryAttributes);
        return kSecItemSecretServiceUnavailable;
    }
    if (existing == NULL) {
        g_hash_table_unref(queryAttributes);
        SecError(errSecItemNotFound, error,
            CFSTR("no matching Secret Service item found"));
        return kSecItemSecretServiceFailed;
    }

    GHashTable *updateAttributes = CreateAttributeTable(attributesToUpdate, false);
    CFDataRef newValue = CopyDataValue(CFDictionaryGetValue(attributesToUpdate,
        kSecValueData));
    CFDataRef valueToStore = newValue != NULL ? newValue : existing;

    GHashTable *newAttributes = g_hash_table_new_full(g_str_hash, g_str_equal,
        g_free, g_free);
    MergeAttributes(newAttributes, queryAttributes);
    MergeAttributes(newAttributes, updateAttributes);

    bool sameIdentity = TablesEqual(queryAttributes, newAttributes);
    bool stored = StoreValue(newAttributes, valueToStore);
    bool cleared = true;
    if (stored && !sameIdentity)
        cleared = ClearStoredValues(queryAttributes, &serviceError);

    CFReleaseNull(newValue);
    CFReleaseNull(existing);
    g_hash_table_unref(queryAttributes);
    g_hash_table_unref(updateAttributes);
    g_hash_table_unref(newAttributes);

    if (serviceError || (!stored && !SecretServiceEnabled()))
        return kSecItemSecretServiceUnavailable;
    if (!stored || !cleared) {
        SecError(errSecInternalComponent, error,
            CFSTR("failed to update item in Secret Service"));
        return kSecItemSecretServiceFailed;
    }
    return kSecItemSecretServiceHandled;
}

SecItemSecretServiceResult
SecItemSecretServiceDelete(CFDictionaryRef query, CFErrorRef *error)
{
    if (!SecretServiceEnabled())
        return kSecItemSecretServiceUnavailable;

    GHashTable *queryAttributes = CreateAttributeTable(query, true);
    if (!IsSupportedCredential(queryAttributes)) {
        g_hash_table_unref(queryAttributes);
        return kSecItemSecretServiceUnavailable;
    }

    bool serviceError = false;
    bool cleared = ClearStoredValues(queryAttributes, &serviceError);
    g_hash_table_unref(queryAttributes);

    if (serviceError)
        return kSecItemSecretServiceUnavailable;
    if (!cleared) {
        SecError(errSecItemNotFound, error,
            CFSTR("no matching Secret Service item found"));
        return kSecItemSecretServiceFailed;
    }
    return kSecItemSecretServiceHandled;
}

#else /* !DARLING_USE_SECRET_SERVICE */

SecItemSecretServiceResult
SecItemSecretServiceAdd(CFDictionaryRef attributes, CFDataRef data, CFErrorRef *error)
{
    (void)attributes;
    (void)data;
    (void)error;
    return kSecItemSecretServiceUnavailable;
}

SecItemSecretServiceResult
SecItemSecretServiceCopy(CFDictionaryRef query, CFDataRef *data, CFErrorRef *error)
{
    (void)query;
    (void)data;
    (void)error;
    return kSecItemSecretServiceUnavailable;
}

SecItemSecretServiceResult
SecItemSecretServiceUpdate(CFDictionaryRef query, CFDictionaryRef attributesToUpdate,
    CFErrorRef *error)
{
    (void)query;
    (void)attributesToUpdate;
    (void)error;
    return kSecItemSecretServiceUnavailable;
}

SecItemSecretServiceResult
SecItemSecretServiceDelete(CFDictionaryRef query, CFErrorRef *error)
{
    (void)query;
    (void)error;
    return kSecItemSecretServiceUnavailable;
}

#endif /* DARLING_USE_SECRET_SERVICE */
