// Host-side test for the reserved right namespace (consent.c). Build and run with:
//   cc -Wall -Wextra -I OSX/authd -o consent_reserved_test OSX/authd/tests/consent_reserved_test.c OSX/authd/consent.c
#include "consent.h"

#include <stdio.h>

static int failures;

static void expect_reserved(const char *right, bool want)
{
    bool got = consent_right_is_reserved(right);
    if (got != want) {
        printf("FAIL: '%s' reserved=%d, want %d\n", right ? right : "(null)", got, want);
        failures++;
    }
}

int main(void)
{
    expect_reserved("", true);
    expect_reserved(NULL, true);

    expect_reserved("system", true);
    expect_reserved("SYSTEM", true);
    expect_reserved("com.apple", true);
    expect_reserved("config", true);
    expect_reserved("sys", true);

    expect_reserved("system.privilege.admin", true);
    expect_reserved("SYSTEM.privilege.ADMIN", true);
    expect_reserved("system.privilege.admin.", true);
    expect_reserved("com.apple.x", true);
    expect_reserved("config.modify.foo", true);
    expect_reserved("sys.openfile.x", true);

    expect_reserved("systematic", false);
    expect_reserved("system-x", false);
    expect_reserved("com.applefoo", false);
    expect_reserved("configx", false);
    expect_reserved("sysx.right", false);
    expect_reserved("com.example.consent-test", false);
    expect_reserved("default", false);

    if (failures) {
        printf("%d failure(s)\n", failures);
        return 1;
    }
    printf("consent_reserved_test: all cases passed\n");
    return 0;
}
