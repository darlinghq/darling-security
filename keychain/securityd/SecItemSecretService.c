/*
 * Copyright (c) 2026 Darling contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/*
 * Optional storage of password items in the host's freedesktop Secret Service.
 *
 * The Secret Service is a service of the host's session bus, and securityd runs
 * inside the prefix, so this talks to it through Darling's libdbus wrapper
 * (darling_dbus), as the other daemons that reach host services do, using the
 * "plain" session algorithm of the Secret Service API. The backend is off
 * unless the preference SecretServiceBackend of the domain
 * org.darlinghq.security is true; with the preference off or absent it never
 * loads the wrapper or opens a connection, and every function reports
 * kSecItemSecretServiceUnavailable.
 */

#include "SecItemSecretService.h"

#include <CoreFoundation/CoreFoundation.h>
#include <Security/SecBase.h>
#include <Security/SecItem.h>
#include <darling_dbus.h>
#include <pthread.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <utilities/SecCFError.h>
#include <utilities/SecCFRelease.h>

#define kSecretServiceName "org.freedesktop.secrets"
#define kSecretServicePath "/org/freedesktop/secrets"
#define kSecretServiceInterface "org.freedesktop.Secret.Service"
#define kSecretItemInterface "org.freedesktop.Secret.Item"
#define kSecretCollectionInterface "org.freedesktop.Secret.Collection"
#define kPropertiesInterface "org.freedesktop.DBus.Properties"
#define kCallTimeoutMs 10000
#define kMaxAttributes 24
#define kMaxPathLength 256

static const CFStringRef kPreferenceDomain = CFSTR("org.darlinghq.security");
static const CFStringRef kPreferenceKey = CFSTR("SecretServiceBackend");

struct Attribute {
    char *name;
    char *value;
};

struct AttributeSet {
    struct Attribute entries[kMaxAttributes];
    int count;
};

/*
 * The SecItem attributes that are stored, and the Secret Service attribute that
 * carries each. Everything is flattened to a string.
 */
static const struct {
    const CFStringRef *key;
    const char *name;
} kAttributeNames[] = {
    { &kSecAttrService, "service" },
    { &kSecAttrAccount, "account" },
    { &kSecAttrAccessGroup, "access-group" },
    { &kSecAttrServer, "server" },
    { &kSecAttrProtocol, "protocol" },
    { &kSecAttrPort, "port" },
    { &kSecAttrPath, "path" },
    { &kSecAttrSecurityDomain, "security-domain" },
    { &kSecAttrAuthenticationType, "authentication-type" },
    { &kSecAttrGeneric, "generic" },
    { &kSecAttrLabel, "label" },
    { &kSecAttrDescription, "description" },
    { &kSecAttrComment, "comment" },
    { &kSecAttrCreator, "creator" },
    { &kSecAttrType, "type" },
};

static pthread_mutex_t gLock = PTHREAD_MUTEX_INITIALIZER;
static bool gPreferenceRead = false;
static bool gPreferenceOn = false;
static bool gDisabled = false;
static const struct darling_dbus *gApi = NULL;
static DBusConnection *gConnection = NULL;
static char gSessionPath[kMaxPathLength];
static char gCollectionPath[kMaxPathLength];

#pragma mark - Attribute sets

static void
AttributeSetFree(struct AttributeSet *set)
{
    for (int i = 0; i < set->count; i++) {
        free(set->entries[i].name);
        free(set->entries[i].value);
    }
    set->count = 0;
}

static void
AttributeSetPut(struct AttributeSet *set, const char *name, char *value)
{
    for (int i = 0; i < set->count; i++) {
        if (strcmp(set->entries[i].name, name) == 0) {
            free(set->entries[i].value);
            set->entries[i].value = value;
            return;
        }
    }
    if (set->count == kMaxAttributes) {
        free(value);
        return;
    }
    set->entries[set->count].name = strdup(name);
    set->entries[set->count].value = value;
    set->count++;
}

static const char *
AttributeSetGet(const struct AttributeSet *set, const char *name)
{
    for (int i = 0; i < set->count; i++) {
        if (strcmp(set->entries[i].name, name) == 0)
            return set->entries[i].value;
    }
    return NULL;
}

static char *
EncodeBase64(const uint8_t *bytes, CFIndex length)
{
    static const char alphabet[] =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    char *out = malloc((size_t)((length + 2) / 3) * 4 + 1);
    if (out == NULL)
        return NULL;
    char *p = out;
    for (CFIndex i = 0; i < length; i += 3) {
        uint32_t chunk = (uint32_t)bytes[i] << 16;
        if (i + 1 < length)
            chunk |= (uint32_t)bytes[i + 1] << 8;
        if (i + 2 < length)
            chunk |= bytes[i + 2];
        *p++ = alphabet[(chunk >> 18) & 63];
        *p++ = alphabet[(chunk >> 12) & 63];
        *p++ = i + 1 < length ? alphabet[(chunk >> 6) & 63] : '=';
        *p++ = i + 2 < length ? alphabet[chunk & 63] : '=';
    }
    *p = '\0';
    return out;
}

static char *
CopyStringValue(CFTypeRef value)
{
    CFTypeID type = CFGetTypeID(value);
    if (type == CFStringGetTypeID()) {
        CFStringRef string = (CFStringRef)value;
        CFIndex size = CFStringGetMaximumSizeForEncoding(CFStringGetLength(string),
            kCFStringEncodingUTF8) + 1;
        char *buffer = malloc((size_t)size);
        if (buffer != NULL && !CFStringGetCString(string, buffer, size, kCFStringEncodingUTF8)) {
            free(buffer);
            buffer = NULL;
        }
        return buffer;
    }
    if (type == CFBooleanGetTypeID())
        return strdup(CFBooleanGetValue((CFBooleanRef)value) ? "true" : "false");
    if (type == CFNumberGetTypeID()) {
        int64_t number = 0;
        char text[32];
        if (!CFNumberGetValue((CFNumberRef)value, kCFNumberSInt64Type, &number))
            return NULL;
        snprintf(text, sizeof(text), "%lld", (long long)number);
        return strdup(text);
    }
    if (type == CFDataGetTypeID()) {
        CFDataRef data = (CFDataRef)value;
        return EncodeBase64(CFDataGetBytePtr(data), CFDataGetLength(data));
    }
    return NULL;
}

/*
 * The attributes of a SecItem dictionary that the backend stores. The class is
 * always recorded, so that generic and internet passwords never collide.
 */
static bool
AttributeSetFromDictionary(struct AttributeSet *set, CFDictionaryRef dictionary, bool withClass)
{
    memset(set, 0, sizeof(*set));
    if (dictionary == NULL)
        return false;
    if (withClass) {
        CFTypeRef class = CFDictionaryGetValue(dictionary, kSecClass);
        if (class != NULL && CFEqual(class, kSecClassGenericPassword))
            AttributeSetPut(set, "class", strdup("generic"));
        else if (class != NULL && CFEqual(class, kSecClassInternetPassword))
            AttributeSetPut(set, "class", strdup("internet"));
        else
            return false;
    }
    for (size_t i = 0; i < sizeof(kAttributeNames) / sizeof(kAttributeNames[0]); i++) {
        CFTypeRef value = CFDictionaryGetValue(dictionary, *kAttributeNames[i].key);
        char *string = value != NULL ? CopyStringValue(value) : NULL;
        if (string != NULL)
            AttributeSetPut(set, kAttributeNames[i].name, string);
    }
    return true;
}

/* Only passwords that are named well enough to be looked up again are handled. */
static bool
IsSupportedCredential(const struct AttributeSet *set)
{
    const char *class = AttributeSetGet(set, "class");
    if (class == NULL || AttributeSetGet(set, "account") == NULL)
        return false;
    if (strcmp(class, "generic") == 0)
        return AttributeSetGet(set, "service") != NULL;
    return AttributeSetGet(set, "server") != NULL;
}

static CFDataRef
CopyValueData(CFTypeRef value)
{
    if (value == NULL)
        return NULL;
    if (CFGetTypeID(value) == CFDataGetTypeID())
        return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)value);
    if (CFGetTypeID(value) == CFStringGetTypeID()) {
        char *string = CopyStringValue(value);
        if (string == NULL)
            return NULL;
        CFDataRef data = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)string, (CFIndex)strlen(string));
        free(string);
        return data;
    }
    return NULL;
}

#pragma mark - D-Bus helpers

static void
DisableLocked(void)
{
    gDisabled = true;
    if (gConnection != NULL) {
        gApi->connection_close(gConnection);
        gApi->connection_unref(gConnection);
        gConnection = NULL;
    }
}

static bool
PreferenceOn(void)
{
    if (!gPreferenceRead) {
        CFTypeRef value = CFPreferencesCopyAppValue(kPreferenceKey, kPreferenceDomain);
        gPreferenceOn = value != NULL && CFGetTypeID(value) == CFBooleanGetTypeID() &&
            CFBooleanGetValue((CFBooleanRef)value);
        if (value != NULL)
            CFRelease(value);
        gPreferenceRead = true;
    }
    return gPreferenceOn;
}

/*
 * The address of the host's session bus: the one the launcher passed on, or the
 * usual $XDG_RUNTIME_DIR/bus. Only a plain socket address is used.
 */
static bool
SessionBusAddress(char *buffer, size_t size)
{
    const char *env = getenv("DBUS_SESSION_BUS_ADDRESS");
    if (env != NULL && env[0] != '\0') {
        if (strncmp(env, "unix:path=", 10) != 0 && strncmp(env, "unix:abstract=", 14) != 0)
            return false;
        if (strchr(env, ';') != NULL || strstr(env, "unixexec") != NULL || strlen(env) >= size)
            return false;
        strcpy(buffer, env);
        return true;
    }
    const char *runtime = getenv("XDG_RUNTIME_DIR");
    if (runtime == NULL || runtime[0] != '/')
        return false;
    char *escaped = gApi->address_escape_value(runtime);
    if (escaped == NULL)
        return false;
    int length = snprintf(buffer, size, "unix:path=%s/bus", escaped);
    gApi->free(escaped);
    return length > 0 && (size_t)length < size;
}

static bool
AppendString(DBusMessageIter *iter, const char *string)
{
    return gApi->message_iter_append_basic(iter, DBUS_TYPE_STRING, &string);
}

static bool
AppendBool(DBusMessageIter *iter, bool value)
{
    dbus_bool_t flag = value ? TRUE : FALSE;
    return gApi->message_iter_append_basic(iter, DBUS_TYPE_BOOLEAN, &flag);
}

static bool
AppendPath(DBusMessageIter *iter, const char *path)
{
    return gApi->message_iter_append_basic(iter, DBUS_TYPE_OBJECT_PATH, &path);
}

static bool
AppendAttributes(DBusMessageIter *iter, const struct AttributeSet *set)
{
    DBusMessageIter array, entry;
    if (!gApi->message_iter_open_container(iter, DBUS_TYPE_ARRAY, "{ss}", &array))
        return false;
    for (int i = 0; i < set->count; i++) {
        if (!gApi->message_iter_open_container(&array, DBUS_TYPE_DICT_ENTRY, NULL, &entry) ||
            !AppendString(&entry, set->entries[i].name) ||
            !AppendString(&entry, set->entries[i].value) ||
            !gApi->message_iter_close_container(&array, &entry))
            return false;
    }
    return gApi->message_iter_close_container(iter, &array);
}

static bool
AppendBytes(DBusMessageIter *iter, const uint8_t *bytes, CFIndex length)
{
    DBusMessageIter array;
    if (!gApi->message_iter_open_container(iter, DBUS_TYPE_ARRAY, "y", &array))
        return false;
    for (CFIndex i = 0; i < length; i++) {
        if (!gApi->message_iter_append_basic(&array, DBUS_TYPE_BYTE, &bytes[i]))
            return false;
    }
    return gApi->message_iter_close_container(iter, &array);
}

/* The Secret struct (session, parameters, value, content type). */
static bool
AppendSecret(DBusMessageIter *iter, CFDataRef data)
{
    DBusMessageIter secret;
    if (!gApi->message_iter_open_container(iter, DBUS_TYPE_STRUCT, NULL, &secret) ||
        !AppendPath(&secret, gSessionPath) ||
        !AppendBytes(&secret, NULL, 0) ||
        !AppendBytes(&secret, CFDataGetBytePtr(data), CFDataGetLength(data)) ||
        !AppendString(&secret, "application/octet-stream"))
        return false;
    return gApi->message_iter_close_container(iter, &secret);
}

static DBusMessage *
NewCall(const char *path, const char *interface, const char *method)
{
    return gApi->message_new_method_call(kSecretServiceName, path, interface, method);
}

/* Sends the call and returns the reply, or NULL. A D-Bus error is not a lost bus. */
static DBusMessage *
Send(DBusMessage *message, bool *busFailure)
{
    DBusError error;
    gApi->error_init(&error);
    DBusMessage *reply = gApi->connection_send_with_reply_and_block(gConnection, message,
        kCallTimeoutMs, &error);
    gApi->message_unref(message);
    if (reply == NULL) {
        /* An error reply is the service saying no; anything else lost the connection. */
        if (busFailure != NULL)
            *busFailure = !gApi->connection_get_is_connected(gConnection) || error.name == NULL ||
                strncmp(error.name, "org.freedesktop.Secret.Error.", 29) != 0;
    }
    gApi->error_free(&error);
    return reply;
}

static bool
ReadPath(DBusMessageIter *iter, char *buffer)
{
    if (gApi->message_iter_get_arg_type(iter) != DBUS_TYPE_OBJECT_PATH)
        return false;
    const char *path = NULL;
    gApi->message_iter_get_basic(iter, &path);
    if (path == NULL || strlen(path) >= kMaxPathLength)
        return false;
    strcpy(buffer, path);
    return true;
}

/* Opens the connection, a plain session and the default collection, once. */
static bool
OpenLocked(void)
{
    if (gConnection != NULL)
        return true;
    if (gDisabled)
        return false;
    gApi = darling_dbus_get(0);
    if (gApi == NULL) {
        gDisabled = true;
        return false;
    }
    char address[1024];
    if (!SessionBusAddress(address, sizeof(address))) {
        gDisabled = true;
        return false;
    }
    DBusError error;
    gApi->error_init(&error);
    gConnection = gApi->connection_open_private(address, &error);
    if (gConnection == NULL || !gApi->bus_register(gConnection, &error)) {
        gApi->error_free(&error);
        if (gConnection != NULL) {
            gApi->connection_close(gConnection);
            gApi->connection_unref(gConnection);
            gConnection = NULL;
        }
        gDisabled = true;
        return false;
    }
    gApi->error_free(&error);

    DBusMessage *message = NewCall(kSecretServicePath, kSecretServiceInterface, "OpenSession");
    DBusMessageIter args, variant;
    gApi->message_iter_init_append(message, &args);
    if (!AppendString(&args, "plain") ||
        !gApi->message_iter_open_container(&args, DBUS_TYPE_VARIANT, "s", &variant) ||
        !AppendString(&variant, "") ||
        !gApi->message_iter_close_container(&args, &variant)) {
        gApi->message_unref(message);
        DisableLocked();
        return false;
    }
    DBusMessage *reply = Send(message, NULL);
    DBusMessageIter iter;
    bool ok = reply != NULL && gApi->message_iter_init(reply, &iter) &&
        gApi->message_iter_next(&iter) && ReadPath(&iter, gSessionPath);
    if (reply != NULL)
        gApi->message_unref(reply);

    if (ok) {
        message = NewCall(kSecretServicePath, kSecretServiceInterface, "ReadAlias");
        gApi->message_iter_init_append(message, &args);
        AppendString(&args, "default");
        reply = Send(message, NULL);
        ok = reply != NULL && gApi->message_iter_init(reply, &iter) &&
            ReadPath(&iter, gCollectionPath) && strcmp(gCollectionPath, "/") != 0;
        if (reply != NULL)
            gApi->message_unref(reply);
    }
    if (!ok) {
        DisableLocked();
        return false;
    }
    return true;
}

/* Asks the service to unlock the objects. A request for the user's input is not made. */
static bool
UnlockLocked(const char *path)
{
    DBusMessage *message = NewCall(kSecretServicePath, kSecretServiceInterface, "Unlock");
    DBusMessageIter args, array;
    gApi->message_iter_init_append(message, &args);
    if (!gApi->message_iter_open_container(&args, DBUS_TYPE_ARRAY, "o", &array) ||
        !AppendPath(&array, path) || !gApi->message_iter_close_container(&args, &array)) {
        gApi->message_unref(message);
        return false;
    }
    DBusMessage *reply = Send(message, NULL);
    DBusMessageIter iter;
    char prompt[kMaxPathLength];
    bool ok = reply != NULL && gApi->message_iter_init(reply, &iter) &&
        gApi->message_iter_next(&iter) && ReadPath(&iter, prompt) && strcmp(prompt, "/") == 0;
    if (reply != NULL)
        gApi->message_unref(reply);
    return ok;
}

enum Lookup {
    kLookupFound,
    kLookupNotFound,
    kLookupLocked,
    kLookupFailed,
};

/* Finds the item whose attributes include all of the given ones. */
static enum Lookup
FindItemLocked(const struct AttributeSet *attributes, char *itemPath)
{
    DBusMessage *message = NewCall(kSecretServicePath, kSecretServiceInterface, "SearchItems");
    DBusMessageIter args;
    gApi->message_iter_init_append(message, &args);
    if (!AppendAttributes(&args, attributes)) {
        gApi->message_unref(message);
        return kLookupFailed;
    }
    bool busFailure = false;
    DBusMessage *reply = Send(message, &busFailure);
    if (reply == NULL) {
        if (busFailure)
            DisableLocked();
        return kLookupFailed;
    }
    enum Lookup result = kLookupNotFound;
    DBusMessageIter iter, array;
    if (gApi->message_iter_init(reply, &iter)) {
        for (int list = 0; list < 2 && result == kLookupNotFound; list++) {
            if (gApi->message_iter_get_arg_type(&iter) != DBUS_TYPE_ARRAY)
                break;
            gApi->message_iter_recurse(&iter, &array);
            if (gApi->message_iter_get_arg_type(&array) == DBUS_TYPE_OBJECT_PATH &&
                ReadPath(&array, itemPath))
                result = list == 0 ? kLookupFound : kLookupLocked;
            if (!gApi->message_iter_next(&iter))
                break;
        }
    }
    gApi->message_unref(reply);
    return result;
}

/* Like FindItemLocked, but an item in a locked collection is unlocked first. */
static enum Lookup
FindUnlockedItemLocked(const struct AttributeSet *attributes, char *itemPath)
{
    enum Lookup found = FindItemLocked(attributes, itemPath);
    if (found == kLookupLocked)
        found = UnlockLocked(itemPath) ? kLookupFound : kLookupLocked;
    return found;
}

static CFDataRef
CopySecretLocked(const char *itemPath)
{
    DBusMessage *message = NewCall(itemPath, kSecretItemInterface, "GetSecret");
    DBusMessageIter args;
    gApi->message_iter_init_append(message, &args);
    AppendPath(&args, gSessionPath);
    DBusMessage *reply = Send(message, NULL);
    if (reply == NULL)
        return NULL;
    CFMutableDataRef data = NULL;
    DBusMessageIter iter, secret, bytes;
    if (gApi->message_iter_init(reply, &iter) &&
        gApi->message_iter_get_arg_type(&iter) == DBUS_TYPE_STRUCT) {
        gApi->message_iter_recurse(&iter, &secret);
        /* the session, the parameters, then the value */
        if (gApi->message_iter_next(&secret) && gApi->message_iter_next(&secret) &&
            gApi->message_iter_get_arg_type(&secret) == DBUS_TYPE_ARRAY) {
            data = CFDataCreateMutable(kCFAllocatorDefault, 0);
            gApi->message_iter_recurse(&secret, &bytes);
            while (gApi->message_iter_get_arg_type(&bytes) == DBUS_TYPE_BYTE) {
                uint8_t byte = 0;
                gApi->message_iter_get_basic(&bytes, &byte);
                CFDataAppendBytes(data, &byte, 1);
                if (!gApi->message_iter_next(&bytes))
                    break;
            }
        }
    }
    gApi->message_unref(reply);
    return data;
}

static bool
SetSecretLocked(const char *itemPath, CFDataRef data)
{
    DBusMessage *message = NewCall(itemPath, kSecretItemInterface, "SetSecret");
    DBusMessageIter args;
    gApi->message_iter_init_append(message, &args);
    if (!AppendSecret(&args, data)) {
        gApi->message_unref(message);
        return false;
    }
    DBusMessage *reply = Send(message, NULL);
    if (reply == NULL)
        return false;
    gApi->message_unref(reply);
    return true;
}

static bool
SetItemAttributesLocked(const char *itemPath, const struct AttributeSet *set)
{
    DBusMessage *message = NewCall(itemPath, kPropertiesInterface, "Set");
    DBusMessageIter args, variant;
    gApi->message_iter_init_append(message, &args);
    if (!AppendString(&args, kSecretItemInterface) || !AppendString(&args, "Attributes") ||
        !gApi->message_iter_open_container(&args, DBUS_TYPE_VARIANT, "a{ss}", &variant) ||
        !AppendAttributes(&variant, set) ||
        !gApi->message_iter_close_container(&args, &variant)) {
        gApi->message_unref(message);
        return false;
    }
    DBusMessage *reply = Send(message, NULL);
    if (reply == NULL)
        return false;
    gApi->message_unref(reply);
    return true;
}

static bool
SetItemLabelLocked(const char *itemPath, const char *label)
{
    DBusMessage *message = NewCall(itemPath, kPropertiesInterface, "Set");
    DBusMessageIter args, variant;
    gApi->message_iter_init_append(message, &args);
    if (!AppendString(&args, kSecretItemInterface) || !AppendString(&args, "Label") ||
        !gApi->message_iter_open_container(&args, DBUS_TYPE_VARIANT, "s", &variant) ||
        !AppendString(&variant, label) ||
        !gApi->message_iter_close_container(&args, &variant)) {
        gApi->message_unref(message);
        return false;
    }
    DBusMessage *reply = Send(message, NULL);
    if (reply == NULL)
        return false;
    gApi->message_unref(reply);
    return true;
}

/* Reads back the attributes of an item, to merge an update into them. */
static bool
ReadItemAttributesLocked(const char *itemPath, struct AttributeSet *set)
{
    memset(set, 0, sizeof(*set));
    DBusMessage *message = NewCall(itemPath, kPropertiesInterface, "Get");
    DBusMessageIter args, iter, variant, array, entry;
    gApi->message_iter_init_append(message, &args);
    AppendString(&args, kSecretItemInterface);
    AppendString(&args, "Attributes");
    DBusMessage *reply = Send(message, NULL);
    if (reply == NULL)
        return false;
    bool ok = false;
    if (gApi->message_iter_init(reply, &iter) &&
        gApi->message_iter_get_arg_type(&iter) == DBUS_TYPE_VARIANT) {
        gApi->message_iter_recurse(&iter, &variant);
        if (gApi->message_iter_get_arg_type(&variant) == DBUS_TYPE_ARRAY) {
            ok = true;
            gApi->message_iter_recurse(&variant, &array);
            while (gApi->message_iter_get_arg_type(&array) == DBUS_TYPE_DICT_ENTRY) {
                const char *name = NULL, *value = NULL;
                gApi->message_iter_recurse(&array, &entry);
                gApi->message_iter_get_basic(&entry, &name);
                if (gApi->message_iter_next(&entry))
                    gApi->message_iter_get_basic(&entry, &value);
                if (name != NULL && value != NULL)
                    AttributeSetPut(set, name, strdup(value));
                if (!gApi->message_iter_next(&array))
                    break;
            }
        }
    }
    gApi->message_unref(reply);
    return ok;
}

#pragma mark - Public entry points

SecItemSecretServiceResult
SecItemSecretServiceAdd(CFDictionaryRef attributes, CFDataRef data, CFErrorRef *error)
{
    SecItemSecretServiceResult result = kSecItemSecretServiceUnavailable;
    pthread_mutex_lock(&gLock);
    struct AttributeSet set;
    if (!PreferenceOn() || !AttributeSetFromDictionary(&set, attributes, true))
        goto out;
    if (!IsSupportedCredential(&set) || !OpenLocked()) {
        AttributeSetFree(&set);
        goto out;
    }

    char itemPath[kMaxPathLength];
    enum Lookup found = FindItemLocked(&set, itemPath);
    if (found == kLookupFailed) {
        AttributeSetFree(&set);
        goto out;
    }
    if (found != kLookupNotFound) {
        SecError(errSecDuplicateItem, error, CFSTR("Secret Service item already exists"));
        result = kSecItemSecretServiceFailed;
        AttributeSetFree(&set);
        goto out;
    }

    CFDataRef empty = NULL;
    if (data == NULL)
        data = empty = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)"", 0);

    /* a locked default collection is unlocked, never prompted for */
    bool unlocked = UnlockLocked(gCollectionPath);
    const char *label = AttributeSetGet(&set, "label");
    DBusMessage *message = NewCall(gCollectionPath, kSecretCollectionInterface, "CreateItem");
    DBusMessageIter args, properties, entry, variant;
    DBusMessage *reply = NULL;
    gApi->message_iter_init_append(message, &args);
    bool built = unlocked &&
        gApi->message_iter_open_container(&args, DBUS_TYPE_ARRAY, "{sv}", &properties) &&
        gApi->message_iter_open_container(&properties, DBUS_TYPE_DICT_ENTRY, NULL, &entry) &&
        AppendString(&entry, kSecretItemInterface ".Label") &&
        gApi->message_iter_open_container(&entry, DBUS_TYPE_VARIANT, "s", &variant) &&
        AppendString(&variant, label != NULL ? label : "Darling keychain item") &&
        gApi->message_iter_close_container(&entry, &variant) &&
        gApi->message_iter_close_container(&properties, &entry) &&
        gApi->message_iter_open_container(&properties, DBUS_TYPE_DICT_ENTRY, NULL, &entry) &&
        AppendString(&entry, kSecretItemInterface ".Attributes") &&
        gApi->message_iter_open_container(&entry, DBUS_TYPE_VARIANT, "a{ss}", &variant) &&
        AppendAttributes(&variant, &set) &&
        gApi->message_iter_close_container(&entry, &variant) &&
        gApi->message_iter_close_container(&properties, &entry) &&
        gApi->message_iter_close_container(&args, &properties) &&
        AppendSecret(&args, data) &&
        AppendBool(&args, false);
    if (built) {
        bool busFailure = false;
        reply = Send(message, &busFailure);
        if (reply == NULL && busFailure)
            DisableLocked();
    } else {
        gApi->message_unref(message);
    }
    CFReleaseNull(empty);
    AttributeSetFree(&set);

    DBusMessageIter iter;
    char created[kMaxPathLength], prompt[kMaxPathLength];
    bool stored = reply != NULL && gApi->message_iter_init(reply, &iter) &&
        ReadPath(&iter, created) && gApi->message_iter_next(&iter) &&
        ReadPath(&iter, prompt) && strcmp(prompt, "/") == 0;
    if (reply != NULL)
        gApi->message_unref(reply);
    if (stored) {
        result = kSecItemSecretServiceHandled;
    } else if (!gDisabled) {
        SecError(unlocked ? errSecInternalComponent : errSecInteractionNotAllowed, error,
            CFSTR("failed to store item in Secret Service"));
        result = kSecItemSecretServiceFailed;
    }
out:
    pthread_mutex_unlock(&gLock);
    return result;
}

SecItemSecretServiceResult
SecItemSecretServiceCopy(CFDictionaryRef query, CFDataRef *data, CFErrorRef *error)
{
    SecItemSecretServiceResult result = kSecItemSecretServiceUnavailable;
    pthread_mutex_lock(&gLock);
    struct AttributeSet set;
    if (!PreferenceOn() || !AttributeSetFromDictionary(&set, query, true))
        goto out;
    char itemPath[kMaxPathLength];
    if (IsSupportedCredential(&set) && OpenLocked()) {
        enum Lookup found = FindUnlockedItemLocked(&set, itemPath);
        if (found == kLookupFound) {
            CFDataRef value = CopySecretLocked(itemPath);
            if (value != NULL) {
                *data = value;
                result = kSecItemSecretServiceHandled;
            } else if (!gDisabled) {
                SecError(errSecInternalComponent, error, CFSTR("failed to read item from Secret Service"));
                result = kSecItemSecretServiceFailed;
            }
        } else if (found == kLookupLocked) {
            SecError(errSecInteractionNotAllowed, error, CFSTR("the Secret Service item is locked"));
            result = kSecItemSecretServiceFailed;
        }
        /* not found: the item may be one stored before the backend was switched on */
    }
    AttributeSetFree(&set);
out:
    pthread_mutex_unlock(&gLock);
    return result;
}

SecItemSecretServiceResult
SecItemSecretServiceUpdate(CFDictionaryRef query, CFDictionaryRef attributesToUpdate, CFErrorRef *error)
{
    SecItemSecretServiceResult result = kSecItemSecretServiceUnavailable;
    pthread_mutex_lock(&gLock);
    struct AttributeSet set;
    if (!PreferenceOn() || !AttributeSetFromDictionary(&set, query, true))
        goto out;
    char itemPath[kMaxPathLength];
    if (IsSupportedCredential(&set) && OpenLocked()) {
        enum Lookup found = FindUnlockedItemLocked(&set, itemPath);
        if (found == kLookupFound) {
            struct AttributeSet merged, changes;
            bool ok = ReadItemAttributesLocked(itemPath, &merged);
            AttributeSetFromDictionary(&changes, attributesToUpdate, false);
            for (int i = 0; ok && i < changes.count; i++)
                AttributeSetPut(&merged, changes.entries[i].name, strdup(changes.entries[i].value));
            ok = ok && SetItemAttributesLocked(itemPath, &merged);
            const char *label = AttributeSetGet(&changes, "label");
            ok = ok && (label == NULL || SetItemLabelLocked(itemPath, label));
            CFDataRef newValue = attributesToUpdate != NULL ?
                CopyValueData(CFDictionaryGetValue(attributesToUpdate, kSecValueData)) : NULL;
            ok = ok && (newValue == NULL || SetSecretLocked(itemPath, newValue));
            CFReleaseNull(newValue);
            AttributeSetFree(&merged);
            AttributeSetFree(&changes);
            if (ok) {
                result = kSecItemSecretServiceHandled;
            } else if (!gDisabled) {
                SecError(errSecInternalComponent, error, CFSTR("failed to update item in Secret Service"));
                result = kSecItemSecretServiceFailed;
            }
        } else if (found == kLookupLocked) {
            SecError(errSecInteractionNotAllowed, error, CFSTR("the Secret Service item is locked"));
            result = kSecItemSecretServiceFailed;
        }
    }
    AttributeSetFree(&set);
out:
    pthread_mutex_unlock(&gLock);
    return result;
}

SecItemSecretServiceResult
SecItemSecretServiceDelete(CFDictionaryRef query, CFErrorRef *error)
{
    SecItemSecretServiceResult result = kSecItemSecretServiceUnavailable;
    pthread_mutex_lock(&gLock);
    struct AttributeSet set;
    if (!PreferenceOn() || !AttributeSetFromDictionary(&set, query, true))
        goto out;
    char itemPath[kMaxPathLength];
    if (IsSupportedCredential(&set) && OpenLocked()) {
        enum Lookup found = FindUnlockedItemLocked(&set, itemPath);
        if (found == kLookupFound) {
            DBusMessage *message = NewCall(itemPath, kSecretItemInterface, "Delete");
            DBusMessage *reply = Send(message, NULL);
            DBusMessageIter iter;
            char prompt[kMaxPathLength];
            bool ok = reply != NULL && gApi->message_iter_init(reply, &iter) &&
                ReadPath(&iter, prompt) && strcmp(prompt, "/") == 0;
            if (reply != NULL)
                gApi->message_unref(reply);
            if (ok) {
                result = kSecItemSecretServiceHandled;
            } else if (!gDisabled) {
                SecError(errSecInternalComponent, error, CFSTR("failed to delete item from Secret Service"));
                result = kSecItemSecretServiceFailed;
            }
        } else if (found == kLookupLocked) {
            SecError(errSecInteractionNotAllowed, error, CFSTR("the Secret Service item is locked"));
            result = kSecItemSecretServiceFailed;
        }
    }
    AttributeSetFree(&set);
out:
    pthread_mutex_unlock(&gLock);
    return result;
}
