#!/usr/bin/env python3
# Copyright (C) 2026 Lubos Dolezel
#
# Integration test: securityd's optional Secret Service backend.
#
# usage: python3 secret-service-backend.py <bindir> [arch ...]
#
# <bindir> holds the guest program built from secret-service-backend.c as
# secret-service-backend.<arch> (default archs: x86_64 i386), signed with the
# entitlements of secret-service-entitlements.plist: securityd's database only
# serves clients that have an application identifier or keychain access
# groups, and the guest's codesign is a stub that cannot embed them. On a Mac:
#   codesign -s - -f --entitlements secret-service-entitlements.plist secret-service-backend.<arch>
# (the program is built on the host as for any guest test and copied there).
# Without them every SecItem call is errSecMissingEntitlement (-34018) and the
# test prints SKIP.
#
# A private dbus-daemon plays the host's session bus with a private
# gnome-keyring-daemon (own HOME and XDG directories, a login keyring created
# with a throw-away password) as its Secret Service; the real session bus and
# keyring are never touched. The guest runs in the prefix named by DPREFIX
# (use a throw-away one): the driver sets and removes the preference
# SecretServiceBackend of /Library/Preferences/org.darlinghq.security with `defaults`, restarts the
# prefix between scenarios so that securityd reads it again, and looks at the
# keyring with secret-tool between the steps of the guest program. Needs
# darling, dbus-daemon, gnome-keyring-daemon and secret-tool on the host.
#
# Scenarios:
#   on       the preference is true: the whole add / duplicate / copy / update /
#            delete cycle of two password items runs through the SecItem API and
#            the keyring is checked between the steps
#   off      the preference is absent: an add leaves nothing in the keyring
#   nobus    the preference is true but the session bus cannot be reached: an
#            add leaves nothing in the keyring and the call is answered by the
#            keychain database as before
# The scenarios without the backend do not judge the keychain database's own
# answers (that is not what is tested here); they check that nothing is sent to
# the host and that the calls return.

import os
import shutil
import subprocess
import sys
import tempfile
import time

if len(sys.argv) < 2:
    print("usage: secret-service-backend.py <bindir> [arch ...]")
    sys.exit(2)
bindir = os.path.abspath(sys.argv[1])
archs = sys.argv[2:] or ["x86_64", "i386"]

for tool in ("darling", "dbus-daemon", "gnome-keyring-daemon", "secret-tool", "busctl"):
    if shutil.which(tool) is None:
        print(f"SKIP: {tool} is not installed")
        sys.exit(0)

failures = 0


def check(cond, what):
    global failures
    print(("PASS: " if cond else "FAIL: ") + what)
    if not cond:
        failures += 1


work = tempfile.mkdtemp(prefix="secsvc-test-", dir=os.environ.get("TMPDIR"))
bus_path = os.path.join(work, "bus")
address = f"unix:path={bus_path}"
for d in ("home", "run", "data"):
    os.mkdir(os.path.join(work, d), 0o700)
host_env = dict(os.environ, DBUS_SESSION_BUS_ADDRESS=address, HOME=os.path.join(work, "home"),
                XDG_RUNTIME_DIR=os.path.join(work, "run"), XDG_DATA_HOME=os.path.join(work, "data"))
procs = []

SERVICE = "org.darlinghq.test.secretservice"


def secret_tool(*args):
    return subprocess.run(["secret-tool", *args], env=host_env, capture_output=True, timeout=30)


def keyring_items():
    # attributes of every item of this test in the keyring, one block per item
    r = secret_tool("search", "--all", "class", "generic")
    r2 = secret_tool("search", "--all", "class", "internet")
    return (r.stdout + r.stderr + r2.stdout + r2.stderr).decode(errors="replace")


def keyring_secret(*kv):
    r = secret_tool("lookup", *kv)
    return r.stdout if r.returncode == 0 else None


def start_host_services():
    bus = subprocess.Popen(["dbus-daemon", "--session", f"--address={address}", "--nofork", "--nopidfile"],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    procs.append(bus)
    end = time.time() + 10
    while not os.path.exists(bus_path) and time.time() < end:
        time.sleep(0.1)
    keyring = subprocess.Popen(["gnome-keyring-daemon", "--foreground", "--components=secrets", "--unlock"],
                               env=host_env, stdin=subprocess.PIPE, stdout=subprocess.DEVNULL,
                               stderr=subprocess.DEVNULL)
    procs.append(keyring)
    keyring.stdin.write(b"throwaway-password\n")
    keyring.stdin.close()
    end = time.time() + 20
    while time.time() < end:
        names = subprocess.run(["busctl", f"--address={address}", "list", "--no-legend"],
                               capture_output=True, text=True).stdout
        if "org.freedesktop.secrets" in names:
            return True
        time.sleep(0.3)
    return False


def darling(*args, env=None, timeout=180, out=None):
    f = open(out, "w") if out else subprocess.DEVNULL
    try:
        return subprocess.run(["timeout", "-s", "KILL", str(timeout), "darling", "shell", *args],
                              env=env or os.environ, stdin=subprocess.DEVNULL, stdout=f, stderr=subprocess.STDOUT)
    finally:
        if out:
            f.close()


def restart_prefix(bus_address):
    subprocess.run(["darling", "shutdown"], env=os.environ, stdin=subprocess.DEVNULL,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=120)
    time.sleep(3)
    # the container's daemons get the bus address of the shell that starts the prefix
    darling("/bin/echo", "up", env=dict(os.environ, DBUS_SESSION_BUS_ADDRESS=bus_address), timeout=120)


def set_preference(on):
    # secd runs as root, so the setting is the system-wide one
    if on:
        darling("sudo", "defaults", "write", "/Library/Preferences/org.darlinghq.security", "SecretServiceBackend", "-bool", "YES")
    else:
        darling("sudo", "defaults", "delete", "/Library/Preferences/org.darlinghq.security", "SecretServiceBackend")


def step(arch, name, scenario):
    exe = os.path.join(bindir, f"secret-service-backend.{arch}")
    out = os.path.join(work, f"{scenario}-{arch}-{name}.out")
    darling("/Volumes/SystemRoot" + exe, name, out=out)
    text = open(out).read()
    if "returned -34018" in text:
        print("SKIP: the guest program has no keychain entitlements, see the header of this script")
        sys.exit(0)
    check("ALL PASSED" in text and "FAIL" not in text,
          f"{scenario}/{arch}: step {name}" + ("" if "ALL PASSED" in text else f": {text.strip()[-300:]!r}"))
    return text


def cycle(arch, scenario):
    generic = ("class", "generic", "service", SERVICE, "account", "alice")
    internet = ("class", "internet", "server", "secretservice.example.test", "account", "bob")
    step(arch, "add", scenario)
    check(keyring_secret(*generic) == b"s3cr3t-text-value", f"{scenario}/{arch}: the generic password is in the keyring")
    check(keyring_secret(*internet) is not None, f"{scenario}/{arch}: the internet password is in the keyring")
    items = keyring_items()
    check("attribute.service = " + SERVICE in items and "attribute.comment = first" in items,
          f"{scenario}/{arch}: the keyring item carries the SecItem attributes")
    step(arch, "add-again", scenario)
    step(arch, "copy", scenario)
    step(arch, "update", scenario)
    step(arch, "copy-updated", scenario)
    check(keyring_secret(*generic) == b"updated-text-value", f"{scenario}/{arch}: the update reached the keyring")
    check("attribute.comment = second" in keyring_items(), f"{scenario}/{arch}: the attribute update reached the keyring")
    step(arch, "delete", scenario)
    step(arch, "gone", scenario)
    check(keyring_secret(*generic) is None and keyring_secret(*internet) is None,
          f"{scenario}/{arch}: no item is left in the keyring")


def nothing_sent(arch, scenario):
    generic = ("class", "generic", "service", SERVICE, "account", "alice")
    internet = ("class", "internet", "server", "secretservice.example.test", "account", "bob")
    exe = os.path.join(bindir, f"secret-service-backend.{arch}")
    out = os.path.join(work, f"{scenario}-{arch}.out")
    darling("/Volumes/SystemRoot" + exe, "add", "copy", "delete", out=out, timeout=240)
    text = open(out).read()
    check("ALL PASSED" in text or "FAILED" in text, f"{scenario}/{arch}: the SecItem calls return")
    check(keyring_secret(*generic) is None and keyring_secret(*internet) is None,
          f"{scenario}/{arch}: nothing reaches the keyring")
    check(keyring_items().strip() == "" or SERVICE not in keyring_items(), f"{scenario}/{arch}: the keyring holds none of the attributes")


try:
    check(start_host_services(), "the private keyring owns org.freedesktop.secrets")
    for arch in archs:
        print(f"--- {arch} ---")
        set_preference(False)
        restart_prefix(address)
        nothing_sent(arch, "off")

        set_preference(True)
        restart_prefix(address)
        cycle(arch, "on")

        set_preference(True)
        restart_prefix(f"unix:path={work}/no-such-bus")
        nothing_sent(arch, "nobus")
        set_preference(False)
finally:
    for p in procs:
        p.terminate()
    for p in procs:
        try:
            p.wait(timeout=10)
        except subprocess.TimeoutExpired:
            p.kill()
    shutil.rmtree(work, ignore_errors=True)

print("FAILED %d" % failures if failures else "ALL PASSED")
sys.exit(1 if failures else 0)
