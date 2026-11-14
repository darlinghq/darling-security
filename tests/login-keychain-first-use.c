// Copyright (C) 2026 Lubos Dolezel
//
// Security framework, user's login keychain on first use. Darling has no
// login window, so the first process that needs the default keychain, the
// login keychain or the search list sets up the login keychain as macOS's
// login does: ~/Library/Keychains/login.keychain-db, empty password,
// unlocked, in the search list, the default keychain. Checked through
// SecKeychainCopyDefault, SecKeychainGetPath, SecKeychainCopySearchList,
// SecKeychainGetStatus, SecItemAdd to the default keychain and
// SecItemCopyMatching from another process.
//
// Every case runs in child processes with HOME set to a new temporary
// directory, so the user's own keychain is never touched. Prints PASSED or
// FAIL lines; exit status 0 on success.
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <ftw.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <Security/Security.h>
#include <CoreFoundation/CoreFoundation.h>

static int g_failures = 0;
#define CHECK(cond) do { if (!(cond)) { printf("FAIL %d: %s\n", __LINE__, #cond); g_failures++; } } while (0)

#define SERVICE "org.darlinghq.test.login-keychain"
#define SECRET "first-use-secret"
static const char *g_self;

static void login_path(char *buf, size_t len)
{
	snprintf(buf, len, "%s/Library/Keychains/login.keychain-db", getenv("HOME"));
}

static int path_of(SecKeychainRef kc, char *buf, UInt32 len)
{
	UInt32 l = len - 1;
	if (SecKeychainGetPath(kc, &l, buf) != errSecSuccess)
		return -1;
	buf[l < len ? l : len - 1] = 0;
	return 0;
}

static CFMutableDictionaryRef query(const char *account)
{
	CFMutableDictionaryRef q = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFDictionarySetValue(q, kSecClass, kSecClassGenericPassword);
	CFStringRef s = CFStringCreateWithCString(NULL, SERVICE, kCFStringEncodingUTF8);
	CFStringRef a = CFStringCreateWithCString(NULL, account, kCFStringEncodingUTF8);
	CFDictionarySetValue(q, kSecAttrService, s);
	CFDictionarySetValue(q, kSecAttrAccount, a);
	CFRelease(s);
	CFRelease(a);
	return q;
}

static OSStatus add_item(const char *account)
{
	CFMutableDictionaryRef q = query(account);
	CFDataRef d = CFDataCreate(NULL, (const UInt8 *) SECRET, strlen(SECRET));
	CFDictionarySetValue(q, kSecValueData, d);
	CFRelease(d);
	OSStatus st = SecItemAdd(q, NULL);
	CFRelease(q);
	return st;
}

static OSStatus find_item(const char *account)
{
	CFMutableDictionaryRef q = query(account);
	CFDictionarySetValue(q, kSecReturnData, kCFBooleanTrue);
	CFDictionarySetValue(q, kSecMatchLimit, kSecMatchLimitOne);
	CFTypeRef r = NULL;
	OSStatus st = SecItemCopyMatching(q, &r);
	CFRelease(q);
	if (st == errSecSuccess) {
		CHECK(r && CFGetTypeID(r) == CFDataGetTypeID());
		if (r && CFGetTypeID(r) == CFDataGetTypeID()) {
			CHECK(CFDataGetLength(r) == (CFIndex) strlen(SECRET));
			CHECK(memcmp(CFDataGetBytePtr(r), SECRET, strlen(SECRET)) == 0);
		}
	}
	if (r)
		CFRelease(r);
	return st;
}

// Keychain paths come back with symbolic links resolved (/tmp is /private/tmp), as on macOS.
static int same_path(const char* a, const char* b)
{
	char ra[PATH_MAX], rb[PATH_MAX];
	if (!realpath(a, ra) || !realpath(b, rb))
		return 0;
	return strcmp(ra, rb) == 0;
}

// Child: the default keychain is the login keychain, set up as on macOS.
static void child_default(void)
{
	char expect[1024], got[1024];
	login_path(expect, sizeof(expect));

	SecKeychainRef kc = NULL;
	OSStatus st = SecKeychainCopyDefault(&kc);
	printf("SecKeychainCopyDefault: %d\n", (int) st);
	CHECK(st == errSecSuccess && kc);
	if (!kc)
		return;
	CHECK(path_of(kc, got, sizeof(got)) == 0);
	CHECK(same_path(got, expect));

	SecKeychainStatus ks = 0;
	CHECK(SecKeychainGetStatus(kc, &ks) == errSecSuccess);
	CHECK((ks & kSecUnlockStateStatus) && (ks & kSecReadPermStatus) && (ks & kSecWritePermStatus));

	SecKeychainSettings set = { SEC_KEYCHAIN_SETTINGS_VERS1 };
	CHECK(SecKeychainCopySettings(kc, &set) == errSecSuccess);
	CHECK(!set.lockOnSleep);

	// The empty password unlocks it again after an explicit lock.
	CHECK(SecKeychainLock(kc) == errSecSuccess);
	CHECK(SecKeychainUnlock(kc, 0, "", true) == errSecSuccess);

	struct stat sb;
	CHECK(stat(expect, &sb) == 0 && (sb.st_mode & 077) == 0);
	char dir[1024];
	snprintf(dir, sizeof(dir), "%s/Library/Keychains", getenv("HOME"));
	CHECK(stat(dir, &sb) == 0 && (sb.st_mode & 077) == 0);

	// Search list: the login keychain first, the system keychain after it.
	CFArrayRef list = NULL;
	CHECK(SecKeychainCopySearchList(&list) == errSecSuccess && list);
	if (list) {
		CFIndex n = CFArrayGetCount(list);
		CHECK(n >= 2);
		int system = 0;
		for (CFIndex i = 0; i < n; i++) {
			if (path_of((SecKeychainRef) CFArrayGetValueAtIndex(list, i), got, sizeof(got)) != 0)
				continue;
			if (i == 0)
				CHECK(same_path(got, expect));
			if (strcmp(got, "/Library/Keychains/System.keychain") == 0)
				system = 1;
		}
		CHECK(system);
		CFRelease(list);
	}

	SecKeychainRef login = NULL;
	CHECK(SecKeychainCopyDomainDefault(kSecPreferencesDomainUser, &login) == errSecSuccess && login);
	if (login)
		CFRelease(login);
	CFRelease(kc);
}

// Child: SecItemAdd without kSecUseKeychain goes to the default keychain.
static void child_add(const char *account)
{
	OSStatus st = add_item(account);
	printf("SecItemAdd(%s): %d\n", account, (int) st);
	CHECK(st == errSecSuccess);
	CHECK(add_item(account) == errSecDuplicateItem);
	CHECK(find_item(account) == errSecSuccess);
}

static void child_find(const char *account)
{
	OSStatus st = find_item(account);
	printf("find(%s) from a new process: %d\n", account, (int) st);
	CHECK(st == errSecSuccess);
}

// Child: an existing unreadable login keychain is used, never replaced.
static void child_corrupt(void)
{
	char p[1024];
	login_path(p, sizeof(p));
	SecKeychainRef kc = NULL;
	OSStatus st = SecKeychainCopyDefault(&kc);
	printf("corrupt: SecKeychainCopyDefault: %d\n", (int) st);
	if (kc)
		CFRelease(kc);
	st = add_item("corrupt");
	printf("corrupt: SecItemAdd: %d\n", (int) st);
	CHECK(st != errSecSuccess);
}

static pid_t spawn(const char *home, const char *what, const char *arg)
{
	pid_t pid = fork();
	if (pid == 0) {
		setenv("HOME", home, 1);
		execl(g_self, g_self, what, arg, (char *) NULL);
		_exit(127);
	}
	return pid;
}

static int wait_ok(pid_t pid)
{
	int status = 0;
	waitpid(pid, &status, 0);
	return WIFEXITED(status) && WEXITSTATUS(status) == 0;
}

static int run(const char *home, const char *what, const char *arg)
{
	return wait_ok(spawn(home, what, arg ? arg : ""));
}

static int rm_entry(const char *path, const struct stat *sb, int flag, struct FTW *ftw)
{
	(void) sb; (void) flag; (void) ftw;
	return remove(path);
}

static void new_home(char *buf, size_t len)
{
	snprintf(buf, len, "/tmp/login-kc-test.XXXXXX");
	if (!mkdtemp(buf)) {
		perror("mkdtemp");
		exit(2);
	}
}

static void write_file(const char *home, const char *content, size_t len)
{
	char p[1024];
	snprintf(p, sizeof(p), "%s/Library", home);
	mkdir(p, 0700);
	snprintf(p, sizeof(p), "%s/Library/Keychains", home);
	mkdir(p, 0700);
	snprintf(p, sizeof(p), "%s/Library/Keychains/login.keychain-db", home);
	int fd = open(p, O_WRONLY | O_CREAT | O_EXCL, 0600);
	if (len)
		write(fd, content, len);
	close(fd);
}

static int read_file(const char *home, char *buf, size_t len)
{
	char p[1024];
	snprintf(p, sizeof(p), "%s/Library/Keychains/login.keychain-db", home);
	int fd = open(p, O_RDONLY);
	if (fd < 0)
		return -1;
	int n = (int) read(fd, buf, len);
	close(fd);
	return n;
}

int main(int argc, char **argv)
{
	setvbuf(stdout, NULL, _IONBF, 0);
	g_self = argv[0];

	if (argc > 1) {
		const char *arg = argc > 2 ? argv[2] : "";
		if (!strcmp(argv[1], "default"))
			child_default();
		else if (!strcmp(argv[1], "add"))
			child_add(arg);
		else if (!strcmp(argv[1], "find"))
			child_find(arg);
		else if (!strcmp(argv[1], "corrupt"))
			child_corrupt();
		return g_failures != 0;
	}

	char home[256];

	// 1. Fresh home: the first SecKeychainCopyDefault sets everything up,
	// an item added to the default keychain is found from another process.
	new_home(home, sizeof(home));
	CHECK(run(home, "default", NULL));
	CHECK(run(home, "add", "one"));
	CHECK(run(home, "find", "one"));
	CHECK(run(home, "default", NULL));
	nftw(home, rm_entry, 16, FTW_DEPTH | FTW_PHYS);

	// 2. Fresh home, first use is SecItemAdd itself.
	new_home(home, sizeof(home));
	CHECK(run(home, "add", "direct"));
	CHECK(run(home, "find", "direct"));
	nftw(home, rm_entry, 16, FTW_DEPTH | FTW_PHYS);

	// 3. Several processes use a fresh home at the same time: one keychain,
	// every item in it.
	new_home(home, sizeof(home));
	{
		const char *acc[] = { "c0", "c1", "c2", "c3", "c4", "c5" };
		pid_t pids[6];
		for (int i = 0; i < 6; i++)
			pids[i] = spawn(home, "add", acc[i]);
		for (int i = 0; i < 6; i++)
			CHECK(wait_ok(pids[i]));
		for (int i = 0; i < 6; i++)
			CHECK(run(home, "find", acc[i]));
		CHECK(run(home, "default", NULL));
	}
	nftw(home, rm_entry, 16, FTW_DEPTH | FTW_PHYS);

	// 4. A login keychain that is not a keychain is left alone.
	new_home(home, sizeof(home));
	{
		static const char junk[] = "this is not a keychain file\n";
		write_file(home, junk, sizeof(junk) - 1);
		CHECK(run(home, "corrupt", NULL));
		char buf[256];
		int n = read_file(home, buf, sizeof(buf));
		CHECK(n == (int) sizeof(junk) - 1 && memcmp(buf, junk, n) == 0);
	}
	nftw(home, rm_entry, 16, FTW_DEPTH | FTW_PHYS);

	// 5. An empty login.keychain-db (interrupted creation) is replaced.
	new_home(home, sizeof(home));
	write_file(home, NULL, 0);
	CHECK(run(home, "default", NULL));
	CHECK(run(home, "add", "after-empty"));
	nftw(home, rm_entry, 16, FTW_DEPTH | FTW_PHYS);

	// 6. A group/other-readable ~/Library/Keychains is made owner-only
	// before the keychain is created in it.
	new_home(home, sizeof(home));
	{
		char p[512];
		snprintf(p, sizeof(p), "%s/Library", home);
		mkdir(p, 0700);
		snprintf(p, sizeof(p), "%s/Library/Keychains", home);
		mkdir(p, 0755);
		chmod(p, 0755);
		CHECK(run(home, "default", NULL));
	}
	nftw(home, rm_entry, 16, FTW_DEPTH | FTW_PHYS);

	printf(g_failures ? "FAILED\n" : "PASSED\n");
	return g_failures != 0;
}
