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
# keyring with secret-tool between the steps of the guest program. Every bus
# address the driver uses, and the session bus and runtime directory that the
# guest inherits, are checked to lie in its own temporary directory; the driver
# stops if one does not. The private buses have no service directories, so
# nothing is activated on them. Needs
# darling, dbus-daemon, dbus-monitor, gnome-keyring-daemon and secret-tool on
# the host, and for the "refused" scenario dbus-python and PyGObject.
#
# Scenarios:
#   on       the preference is true: the whole add / duplicate / copy / update /
#            delete cycle of two password items runs through the SecItem API and
#            the keyring is checked between the steps; dbus-monitor records the
#            bus during the guest's steps, and the record must show that the
#            session was opened with "dh-ietf1024-sha256-aes128-cbc-pkcs7" (never
#            "plain") and must not hold any of the secret values
#   refused  the same cycle against secret-service-mock.py on a second private
#            bus, a service that refuses every algorithm but "plain": the backend
#            asks for the encrypted algorithm first, then falls back to "plain",
#            and the cycle works
#   off      the preference is absent: an add leaves nothing in the keyring
#   nobus    the preference is true but the session bus cannot be reached: an
#            add leaves nothing in the keyring and the call is answered by the
#            keychain database as before
# The scenarios without the backend do not judge the keychain database's own
# answers (that is not what is tested here); they check that nothing is sent to
# the host and that the calls return.

import json
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

for tool in ("darling", "dbus-daemon", "dbus-monitor", "gnome-keyring-daemon", "secret-tool", "busctl"):
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
# the guest and every darling command get the private bus and runtime directory, never the user's
os.environ["DBUS_SESSION_BUS_ADDRESS"] = address
os.environ["XDG_RUNTIME_DIR"] = host_env["XDG_RUNTIME_DIR"]
for name in ("DBUS_SYSTEM_BUS_ADDRESS", "PULSE_SERVER"):
    os.environ.pop(name, None)
procs = []


def require_private(bus_address):
    # stop before anything could reach a bus that this driver did not start
    if not bus_address.startswith(f"unix:path={work}/") or ";" in bus_address:
        print(f"ABORT: {bus_address!r} is not a private bus of this test")
        sys.exit(2)

SERVICE = "org.darlinghq.test.secretservice"
DH_ALGORITHM = "dh-ietf1024-sha256-aes128-cbc-pkcs7"
# every secret value that the guest program stores
SECRET_VALUES = (b"s3cr3t-text-value", b"updated-text-value", bytes([0x62, 0x69, 0x6e, 0x00, 0xff, 0x7f, 0x7a]))
mock_address = f"unix:path={work}/mock-bus"
mock_state = os.path.join(work, "mock-state.json")


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


def start_bus(bus_address):
    require_private(bus_address)
    path = bus_address[len("unix:path="):]
    # a session bus without service directories, so that no service is activated on it
    config = path + ".conf"
    with open(config, "w") as f:
        f.write('<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN"\n'
                ' "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">\n'
                "<busconfig><type>session</type><auth>EXTERNAL</auth>"
                f"<listen>{bus_address}</listen>"
                '<policy context="default"><allow send_destination="*" eavesdrop="true"/>'
                '<allow eavesdrop="true"/><allow own="*"/></policy></busconfig>\n')
    bus = subprocess.Popen(["dbus-daemon", f"--config-file={config}", "--nofork", "--nopidfile"],
                           env=host_env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    procs.append(bus)
    end = time.time() + 10
    while not os.path.exists(path) and time.time() < end:
        time.sleep(0.1)


def owns_secrets(bus_address):
    names = subprocess.run(["busctl", f"--address={bus_address}", "list", "--no-legend"],
                           capture_output=True, text=True).stdout
    return "org.freedesktop.secrets" in names


def start_host_services():
    start_bus(address)
    keyring = subprocess.Popen(["gnome-keyring-daemon", "--foreground", "--components=secrets", "--unlock"],
                               env=host_env, stdin=subprocess.PIPE, stdout=subprocess.DEVNULL,
                               stderr=subprocess.DEVNULL)
    procs.append(keyring)
    keyring.stdin.write(b"throwaway-password\n")
    keyring.stdin.close()
    end = time.time() + 20
    while time.time() < end:
        if owns_secrets(address):
            return True
        time.sleep(0.3)
    return False


def start_mock_service():
    try:
        import dbus  # noqa: F401
        from gi.repository import GLib  # noqa: F401
    except ImportError:
        return None
    start_bus(mock_address)
    mock = subprocess.Popen([sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                                          "secret-service-mock.py"), mock_address, mock_state],
                            stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    procs.append(mock)
    end = time.time() + 20
    while time.time() < end:
        if owns_secrets(mock_address):
            return True
        time.sleep(0.3)
    return False


def mock_items():
    with open(mock_state) as f:
        return json.load(f)


def mock_secret(*kv):
    wanted = dict(zip(kv[0::2], kv[1::2]))
    for item in mock_items()["items"]:
        if all(item["attributes"].get(k) == v for k, v in wanted.items()):
            return bytes.fromhex(item["secret"])
    return None


def mock_items_text():
    return "\n".join(f"attribute.{k} = {v}" for item in mock_items()["items"] for k, v in item["attributes"].items())


class Monitor:
    """dbus-monitor on one of the private buses while a guest step runs."""

    def __init__(self, bus_address, path):
        require_private(bus_address)
        self.file = open(path, "w")
        self.path = path
        self.proc = subprocess.Popen(["dbus-monitor", f"--address={bus_address}"], stdin=subprocess.DEVNULL,
                                     stdout=self.file, stderr=subprocess.STDOUT)
        procs.append(self.proc)
        time.sleep(1)

    def stop(self):
        time.sleep(0.5)
        self.proc.terminate()
        self.proc.wait(timeout=10)
        procs.remove(self.proc)
        self.file.close()
        with open(self.path) as f:
            return f.read()


def darling(*args, env=None, timeout=180, out=None):
    env = env or os.environ
    require_private(env.get("DBUS_SESSION_BUS_ADDRESS", ""))
    if not env.get("XDG_RUNTIME_DIR", "").startswith(work + "/"):
        print("ABORT: the guest would get the user's runtime directory")
        sys.exit(2)
    f = open(out, "w") if out else subprocess.DEVNULL
    try:
        return subprocess.run(["timeout", "-s", "KILL", str(timeout), "darling", "shell", *args],
                              env=env, stdin=subprocess.DEVNULL, stdout=f, stderr=subprocess.STDOUT)
    finally:
        if out:
            f.close()


def restart_prefix(bus_address):
    require_private(bus_address)
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


def step(arch, name, scenario, monitor_address=None, record=None):
    exe = os.path.join(bindir, f"secret-service-backend.{arch}")
    out = os.path.join(work, f"{scenario}-{arch}-{name}.out")
    monitor = Monitor(monitor_address, os.path.join(work, f"{scenario}-{arch}-{name}.bus")) if monitor_address else None
    darling("/Volumes/SystemRoot" + exe, name, out=out)
    if monitor is not None:
        record.append(monitor.stop())
    text = open(out).read()
    if "returned -34018" in text:
        print("SKIP: the guest program has no keychain entitlements, see the header of this script")
        sys.exit(0)
    check("ALL PASSED" in text and "FAIL" not in text,
          f"{scenario}/{arch}: step {name}" + ("" if "ALL PASSED" in text else f": {text.strip()[-300:]!r}"))
    return text


def cycle(arch, scenario, monitor_address=None, secret_of=keyring_secret, items_of=keyring_items):
    generic = ("class", "generic", "service", SERVICE, "account", "alice")
    internet = ("class", "internet", "server", "secretservice.example.test", "account", "bob")
    record = []
    step(arch, "add", scenario, monitor_address, record)
    check(secret_of(*generic) == b"s3cr3t-text-value", f"{scenario}/{arch}: the generic password is in the keyring")
    check(secret_of(*internet) == SECRET_VALUES[2], f"{scenario}/{arch}: the internet password is in the keyring")
    items = items_of()
    check("attribute.service = " + SERVICE in items and "attribute.comment = first" in items,
          f"{scenario}/{arch}: the keyring item carries the SecItem attributes")
    step(arch, "add-again", scenario, monitor_address, record)
    step(arch, "copy", scenario, monitor_address, record)
    step(arch, "update", scenario, monitor_address, record)
    step(arch, "copy-updated", scenario, monitor_address, record)
    check(secret_of(*generic) == b"updated-text-value", f"{scenario}/{arch}: the update reached the keyring")
    check("attribute.comment = second" in items_of(), f"{scenario}/{arch}: the attribute update reached the keyring")
    step(arch, "delete", scenario, monitor_address, record)
    step(arch, "gone", scenario, monitor_address, record)
    check(secret_of(*generic) is None and secret_of(*internet) is None,
          f"{scenario}/{arch}: no item is left in the keyring")
    return "".join(record)


def wire_checks(arch, scenario, record):
    # dbus-monitor prints a byte array as a quoted string when it is text and
    # as hex bytes otherwise; look for every value in both forms
    flat = "".join(record.split()).lower()
    check("member=CreateItem" in record and "member=GetSecret" in record and "member=SetSecret" in record,
          f"{scenario}/{arch}: the bus record holds the CreateItem, GetSecret and SetSecret calls")
    check("member=OpenSession" in record and f'string "{DH_ALGORITHM}"' in record,
          f"{scenario}/{arch}: the session was opened with {DH_ALGORITHM}")
    check('string "plain"' not in record, f"{scenario}/{arch}: no plain session was asked for")
    leaked = [v for v in SECRET_VALUES if v.hex() in flat or (v.isascii() and v.decode() in record)]
    check(not leaked, f"{scenario}/{arch}: no secret value is on the bus in the clear" +
          ("" if not leaked else f": {leaked!r}"))


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
    mock_ready = start_mock_service()
    if mock_ready is None:
        print("SKIP: refused: dbus-python or PyGObject is not installed")
    else:
        check(mock_ready, "the mock service owns org.freedesktop.secrets on the second bus")
    for arch in archs:
        print(f"--- {arch} ---")
        set_preference(False)
        restart_prefix(address)
        nothing_sent(arch, "off")

        set_preference(True)
        restart_prefix(address)
        wire_checks(arch, "on", cycle(arch, "on", monitor_address=address))

        if mock_ready:
            asked_before = len(mock_items()["algorithms"])
            restart_prefix(mock_address)
            cycle(arch, "refused", secret_of=mock_secret, items_of=mock_items_text)
            algorithms = mock_items()["algorithms"][asked_before:]
            check(algorithms == [DH_ALGORITHM, "plain"],
                  f"refused/{arch}: the backend asked for {DH_ALGORITHM}, then fell back to plain: {algorithms!r}")

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
