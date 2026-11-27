#!/usr/bin/env python3
# Copyright (C) 2026 Lubos Dolezel
#
# Unit test of the transfer encryption of securityd's Secret Service backend.
#
# usage: python3 secret-service-crypto.py <bindir> [arch ...]
#
# <bindir> holds the guest program built from secret-service-crypto.c as
# secret-service-crypto.<arch> (default archs: x86_64 i386; it needs no
# entitlements). The program checks HKDF-SHA256 against RFC 5869 appendix A,
# AES-128-CBC against NIST SP 800-38A F.2.1 and the PKCS #7 padding on its own
# ("vectors"). This driver then checks the key exchange against an independent
# computation on the host: it makes a private key y in the 1024-bit MODP group
# of RFC 2409 (section 6.2, generator 2), gives the program the public key
# 2^y mod p, reads back the public key X and the session key of each of the
# program's exchanges, and compares each key with HKDF-SHA256 (no salt, no
# info, RFC 5869) of X^y mod p as 128 big-endian bytes, cut to 16 bytes: the
# key of the Secret Service algorithm "dh-ietf1024-sha256-aes128-cbc-pkcs7".
# The first run makes enough exchanges that some shared secrets have a leading
# zero byte (about one in 256), which must be kept; the second gives a peer key
# under 128 bytes (its leading zero bytes dropped, as services may send it).
# The guest runs in the prefix named by DPREFIX.

import hashlib
import hmac
import os
import secrets
import subprocess
import sys
import tempfile

if len(sys.argv) < 2:
    print("usage: secret-service-crypto.py <bindir> [arch ...]")
    sys.exit(2)
bindir = os.path.abspath(sys.argv[1])
archs = sys.argv[2:] or ["x86_64", "i386"]

# RFC 2409 section 6.2, the second Oakley group
P = int(
    "FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD1"
    "29024E088A67CC74020BBEA63B139B22514A08798E3404DD"
    "EF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245"
    "E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7ED"
    "EE386BFB5A899FA5AE9F24117C4B1FE649286651ECE65381"
    "FFFFFFFFFFFFFFFF", 16)
G = 2

failures = 0


def check(cond, what):
    global failures
    print(("PASS: " if cond else "FAIL: ") + what)
    if not cond:
        failures += 1


def hkdf_sha256(ikm, salt, info, length):
    prk = hmac.new(salt or bytes(32), ikm, hashlib.sha256).digest()
    okm, block = b"", b""
    for counter in range(1, -(-length // 32) + 1):
        block = hmac.new(prk, block + info + bytes([counter]), hashlib.sha256).digest()
        okm += block
    return okm[:length]


def run(arch, *args):
    exe = os.path.join(bindir, f"secret-service-crypto.{arch}")
    with tempfile.NamedTemporaryFile("w+", dir=os.environ.get("TMPDIR")) as out:
        subprocess.run(["timeout", "-s", "KILL", "120", "darling", "shell", "/Volumes/SystemRoot" + exe, *args],
                       stdin=subprocess.DEVNULL, stdout=out, stderr=subprocess.STDOUT)
        out.seek(0)
        return out.read()


# the host's own HKDF against RFC 5869 A.3, so that it can judge the guest's
check(hkdf_sha256(bytes([0x0b] * 22), b"", b"", 42).hex() ==
      "8da4e775a563c18f715f802a063c5a31b8a11f5c5ee1879ec3454e5f3c738d2d9d201395faa4b61a96c8",
      "host HKDF-SHA256 matches RFC 5869 A.3")
check(pow(G, P - 1, P) == 1 and P.bit_length() == 1024, "host group 2 prime is a 1024-bit probable prime")


def pi_times_power_of_two(bits):
    # floor(pi * 2^bits) by Machin's formula pi = 16 atan(1/5) - 4 atan(1/239), with guard bits
    guard = 64
    one = 1 << (bits + guard)

    def atan_inverse(x):
        total = term = one // x
        n, sign = 1, 1
        while term:
            term //= x * x
            n += 2
            sign = -sign
            total += sign * (term // n)
        return total
    return (16 * atan_inverse(5) - 4 * atan_inverse(239)) >> guard


# RFC 2409 section 6.2 defines the prime as 2^1024 - 2^960 - 1 + 2^64 * { [2^894 pi] + 129093 }
check(P == 2 ** 1024 - 2 ** 960 - 1 + 2 ** 64 * (pi_times_power_of_two(894) + 129093),
      "host group 2 prime equals the formula of RFC 2409 section 6.2")

for arch in archs:
    print(f"--- {arch} ---")
    text = run(arch, "vectors")
    for line in text.splitlines():
        if line.startswith(("PASS", "FAIL")):
            print(f"  {arch}: {line}")
    check("ALL PASSED" in text and "FAIL" not in text, f"{arch}: vectors")

    for short, count in ((False, 2500), (True, 20)):
        # a peer key with a zero top byte when short, to cover keys under 128 bytes
        while True:
            y = secrets.randbelow(P - 3) + 2
            Y = pow(G, y, P)
            if Y > 1 << 1016 if not short else Y < 1 << 1016:
                break
        peer = Y.to_bytes((Y.bit_length() + 7) // 8, "big")
        text = run(arch, "exchange", str(count), peer.hex())
        exchanges = [line.split() for line in text.splitlines() if line.startswith("public ")]
        matched = short_secrets = 0
        for words in exchanges:
            if len(words) != 4 or words[2] != "key":
                continue
            X = int(words[1], 16)
            shared = pow(X, y, P)
            if 1 < X < P - 1 and words[3] == hkdf_sha256(shared.to_bytes(128, "big"), b"", b"", 16).hex():
                matched += 1
                short_secrets += shared < 1 << 1016
        check(len(exchanges) == count and matched == count,
              f"{arch}: all {count} session keys match the host's computation (peer key of {len(peer)} bytes,"
              f" {matched} matched)" + ("" if matched == count else f": {text.strip()[-300:]!r}"))
        if not short:
            check(short_secrets > 0, f"{arch}: {short_secrets} of the shared secrets had a leading zero byte")

print("FAILED %d" % failures if failures else "ALL PASSED")
sys.exit(1 if failures else 0)
