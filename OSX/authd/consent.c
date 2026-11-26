#include "consent.h"

#include <string.h>
#include <strings.h>

static const char *const kReservedNames[] = {
    "system",
    "com.apple",
    "config",
    "sys",
};

static const char *const kReservedPrefixes[] = {
    "system.",
    "com.apple.",
    "config.",
    "sys.",
};

bool consent_right_is_reserved(const char *right)
{
    if (right == NULL || right[0] == '\0') {
        return true;
    }
    for (size_t i = 0; i < sizeof(kReservedNames) / sizeof(kReservedNames[0]); i++) {
        if (strcasecmp(right, kReservedNames[i]) == 0) {
            return true;
        }
    }
    for (size_t i = 0; i < sizeof(kReservedPrefixes) / sizeof(kReservedPrefixes[0]); i++) {
        if (strncasecmp(right, kReservedPrefixes[i], strlen(kReservedPrefixes[i])) == 0) {
            return true;
        }
    }
    return false;
}
