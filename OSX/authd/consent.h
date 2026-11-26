// Consent mode for Darling: password authentication is replaced by a yes/no confirmation.
#ifndef _SECURITY_AUTH_CONSENT_H_
#define _SECURITY_AUTH_CONSENT_H_

#include <stdbool.h>

// True for right names in Apple's reserved namespaces. Rights there are denied before any
// rule lookup, whatever the rights database contains, because the code that honours them
// (installers, ServiceManagement, preference panes) assumes real authentication happened.
// Reserved: the empty name; the names system, com.apple, config, sys; and any name that
// starts with system., com.apple., config. or sys. ASCII case-insensitive.
bool consent_right_is_reserved(const char *right);

// Outcome of the consent step. Only ConsentConfirmed, an explicit answer from the user,
// may mint a credential; a mechanism list that merely succeeds is not an answer.
typedef enum {
    ConsentNotAsked = 0,
    ConsentDeclined,
    ConsentConfirmed,
} consent_answer_t;

#endif /* !_SECURITY_AUTH_CONSENT_H_ */
