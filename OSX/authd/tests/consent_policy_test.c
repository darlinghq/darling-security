// Guest-side policy test for consent-mode authd. Runs inside a Darling prefix against the authd
// built from this tree. It is not wired into CMake.
//
// Environment:
//   AUTHD_TEST_FIXTURE=1   the test prefix's authorization.plist is the poisoned fixture from
//                          tests/fixtures/make-poisoned-rights.py. Without it the fixture cases SKIP.
//   AUTHD_TEST_LOG=<path>  authd's log file in the test prefix. Without it the I3 case SKIPs.
#include <Security/Authorization.h>
#include <Security/AuthorizationPriv.h>
#include <Security/AuthorizationTags.h>
#include <Security/AuthorizationTagsPriv.h>

#include <pwd.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#define INTERACTIVE (kAuthorizationFlagDefaults | kAuthorizationFlagExtendRights | kAuthorizationFlagInteractionAllowed)

static int failures;

typedef struct {
    OSStatus status;
    bool granted;
} outcome_t;

// granted is true only if the call succeeded and, for a PreAuthorize call, the right came back
// without kAuthorizationFlagCanNotPreAuthorize.
static outcome_t copy_right(const char *right, AuthorizationFlags flags, AuthorizationEnvironment *env)
{
    outcome_t out = { errAuthorizationInternal, false };
    AuthorizationRef ref = NULL;
    if (AuthorizationCreate(NULL, NULL, kAuthorizationFlagDefaults, &ref) != errAuthorizationSuccess) {
        return out;
    }

    AuthorizationItem item = { right, 0, NULL, 0 };
    AuthorizationRights rights = { 1, &item };
    AuthorizationItemSet *authorized = NULL;
    out.status = AuthorizationCopyRights(ref, &rights, env, flags, &authorized);

    out.granted = out.status == errAuthorizationSuccess;
    if (out.granted && (flags & kAuthorizationFlagPreAuthorize)) {
        out.granted = false;
        if (authorized) {
            for (UInt32 i = 0; i < authorized->count; i++) {
                const AuthorizationItem *got = &authorized->items[i];
                if (strcmp(got->name, right) == 0 && !(got->flags & kAuthorizationFlagCanNotPreAuthorize)) {
                    out.granted = true;
                }
            }
        }
    }

    if (authorized) {
        AuthorizationFreeItemSet(authorized);
    }
    AuthorizationFree(ref, kAuthorizationFlagDefaults);
    return out;
}

static void expect_denied(const char *label, const char *right, AuthorizationFlags flags, AuthorizationEnvironment *env)
{
    outcome_t out = copy_right(right, flags, env);
    if (out.granted) {
        printf("FAIL: %s: '%s' was granted\n", label, right);
        failures++;
    } else if ((flags & kAuthorizationFlagInteractionAllowed)
               ? out.status != errAuthorizationDenied
               : (out.status != errAuthorizationDenied && out.status != errAuthorizationInteractionNotAllowed)) {
        // With InteractionAllowed set, consent denial must be errAuthorizationDenied (not -60007 or -60008).
        printf("FAIL: %s: '%s' status %d is not a policy denial\n", label, right, (int)out.status);
        failures++;
    } else {
        printf("ok:   %s: '%s' denied (status %d)\n", label, right, (int)out.status);
    }
}

static void expect_status(const char *label, const char *right, AuthorizationFlags flags, AuthorizationEnvironment *env, OSStatus want)
{
    outcome_t out = copy_right(right, flags, env);
    if (out.status != want) {
        printf("FAIL: %s: '%s' status %d, want %d\n", label, right, (int)out.status, (int)want);
        failures++;
    } else {
        printf("ok:   %s: '%s' status %d\n", label, right, (int)out.status);
    }
}

static void skip(const char *label, const char *why)
{
    printf("SKIP: %s (%s)\n", label, why);
}

// R1, and I4 for the name gate (engine_authorize, consent_right_is_reserved). The first group are
// user-class rights, which consent denies anyway. The second group are allow-class rights in
// the shipped DB (verified in authorization.plist): only the gate denies them, so removing the
// gate makes them granted and this case fails.
static void test_reserved_rights_denied(void)
{
    static const char *const userClass[] = {
        "", "system", "com.apple", "config", "sys",
        "system.privilege.admin", "SYSTEM.privilege.ADMIN", "system.privilege.admin.",
        "com.apple.x", "config.modify.foo", "sys.openfile.x",
    };
    static const char *const allowClass[] = {
        "system.burn", "system.hdd.smart", "system.privilege.taskport.safe", "config.add.",
    };
    for (size_t i = 0; i < sizeof(userClass) / sizeof(userClass[0]); i++) {
        expect_denied("I4 reserved user-class right", userClass[i], INTERACTIVE, NULL);
    }
    for (size_t i = 0; i < sizeof(allowClass) / sizeof(allowClass[0]); i++) {
        expect_denied("R1 reserved allow-class right", allowClass[i], INTERACTIVE, NULL);
    }
}

// R2a, F1 (_evaluate_class_user PreAuthorize shortcut). The fixture right is non-reserved, user class,
// timeout 0. With the shortcut restored it returns Success and the right comes back granted.
static void test_preauthorize_timeout0_not_granted(void)
{
    if (getenv("AUTHD_TEST_FIXTURE") == NULL) {
        skip("R2a F1 preauthorize timeout 0", "AUTHD_TEST_FIXTURE not set");
        return;
    }
    expect_denied("R2a F1 preauthorize timeout 0", "com.example.consent-timeout0",
                  INTERACTIVE | kAuthorizationFlagPreAuthorize, NULL);
}

// R2b, F2 (_evaluate_class_rule delegate gate). The fixture right is a non-reserved rule-class right
// whose only delegate is system.burn, an allow-class reserved right. With the delegate gate removed
// the delegate succeeds and the request is granted.
static void test_delegate_to_reserved_denied(void)
{
    if (getenv("AUTHD_TEST_FIXTURE") == NULL) {
        skip("R2b F2 delegate to reserved", "AUTHD_TEST_FIXTURE not set");
        return;
    }
    expect_denied("R2b F2 delegate to reserved", "com.example.consent-delegate", INTERACTIVE, NULL);
}

// R3, F3 (mint only on ConsentConfirmed, engine.c mint sites). The fixture right has mechanisms
// [builtin:authenticate], which is the one mechanism the consent helper recognises. The helper
// answers Denied, so nothing is minted. The kill mutant makes the helper return success for this
// mechanism and removes the ConsentConfirmed check at both mint sites; the right is then granted.
static void test_no_credential_without_consent(void)
{
    if (getenv("AUTHD_TEST_FIXTURE") == NULL) {
        skip("R3 F3 mint on consent", "AUTHD_TEST_FIXTURE not set");
        return;
    }
    expect_denied("R3 F3 mint on consent", "com.example.consent-mint", INTERACTIVE, NULL);
}

static long file_size(const char *path)
{
    struct stat st;
    return stat(path, &st) == 0 ? (long)st.st_size : 0;
}

// True if needle appears in the file after offset; sets *readable to false if fopen fails.
static bool file_contains_after(const char *path, long offset, const char *needle, bool *readable)
{
    FILE *f = fopen(path, "r");
    if (!f) {
        *readable = false;
        return false;
    }
    *readable = true;
    bool found = false;
    if (fseek(f, offset, SEEK_SET) == 0) {
        char line[4096];
        while (!found && fgets(line, sizeof(line), f)) {
            found = strstr(line, needle) != NULL;
        }
    }
    fclose(f);
    return found;
}

// R3, I3 (_parse_environment early return, F5). A client username and a wrong password go in the
// environment. Restoring the early-return body makes authd call checkpw, which logs "checkpw()" at
// error level. The right is denied either way, so the log is the only observable for this branch.
static void test_client_password_never_checked(void)
{
    const char *logPath = getenv("AUTHD_TEST_LOG");
    struct passwd *pw = getpwuid(getuid());
    if (logPath == NULL || pw == NULL) {
        skip("R3 I3 client password", "AUTHD_TEST_LOG not set or no passwd entry");
        return;
    }

    const char *wrong = "consent-test-not-the-password";
    AuthorizationItem envItems[2] = {
        { kAuthorizationEnvironmentUsername, strlen(pw->pw_name), (void *)pw->pw_name, 0 },
        { kAuthorizationEnvironmentPassword, strlen(wrong), (void *)wrong, 0 },
    };
    AuthorizationEnvironment env = { 2, envItems };

    long before = file_size(logPath);
    expect_denied("R3 I3 client password", "com.example.consent-test", INTERACTIVE, &env);
    sleep(1); // os_log output may lag the call

    bool readable = false;
    if (file_contains_after(logPath, before, "checkpw", &readable)) {
        printf("FAIL: I3 client password: authd called checkpw() on a client password\n");
        failures++;
    } else if (!readable) {
        printf("FAIL: I3 client password: could not open AUTHD_TEST_LOG '%s'\n", logPath);
        failures++;
    } else {
        printf("ok:   R3 I3 client password: no checkpw() call logged\n");
    }
}

// R3, F4 (sheet flag). The sheet flag without InteractionAllowed. With the flag stripped, the
// interaction check returns errAuthorizationInteractionNotAllowed. Without the strip the sheet path
// skips that check and the request ends in consent denial (errAuthorizationDenied).
// Kills removal of both strips (the unconditional one and the original NDEBUG one). Removing only
// the unconditional strip survives, because the NDEBUG strip already removes the flag for creators
// that are not Apple-signed, and this test client is not Apple-signed.
static void test_sheet_flag_not_honoured(void)
{
    struct passwd *pw = getpwuid(getuid());
    if (pw == NULL) {
        skip("R3 F4 sheet flag", "no passwd entry");
        return;
    }
    AuthorizationItem envItems[1] = {
        { kAuthorizationEnvironmentUsername, strlen(pw->pw_name), (void *)pw->pw_name, 0 },
    };
    AuthorizationEnvironment env = { 1, envItems };
    expect_status("R3 F4 sheet flag", "com.example.consent-test",
                  kAuthorizationFlagDefaults | kAuthorizationFlagExtendRights | kAuthorizationFlagSheet,
                  &env, errAuthorizationInteractionNotAllowed);
}

int main(void)
{
    test_reserved_rights_denied();
    test_preauthorize_timeout0_not_granted();
    test_delegate_to_reserved_denied();
    test_no_credential_without_consent();
    test_client_password_never_checked();
    test_sheet_flag_not_honoured();

    if (failures) {
        printf("%d failure(s)\n", failures);
        return 1;
    }
    printf("consent_policy_test: no failures\n");
    return 0;
}
