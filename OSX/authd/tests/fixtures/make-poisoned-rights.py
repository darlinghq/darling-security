#!/usr/bin/env python3
"""Write a poisoned authorization.plist for the consent policy test prefix.

Usage: make-poisoned-rights.py <new-dir>

Writes <new-dir>/System/Library/Security/authorization.plist: the shipped plist plus three test
rights. authd imports this file into the test prefix's own rights DB. The script refuses a target
directory that exists and is not empty, so it can never overwrite a real prefix.
"""
import os
import plistlib
import sys

SHIPPED = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "authorization.plist")

POISON = {
    # R2a: non-reserved user right, timeout 0. Consent must deny it under PreAuthorize.
    "com.example.consent-timeout0": {
        "class": "user",
        "timeout": 0,
        "shared": False,
        "mechanisms": ["builtin:authenticate"],
        "comment": "Test fixture. Non-reserved, timeout 0, for the PreAuthorize shortcut case.",
    },
    # R3 (F3): non-reserved user right whose only mechanism is builtin:authenticate.
    "com.example.consent-mint": {
        "class": "user",
        "timeout": 300,
        "shared": False,
        "mechanisms": ["builtin:authenticate"],
        "comment": "Test fixture. Non-reserved user right for the mint-on-consent case.",
    },
    # R2b (F2): non-reserved rule-class right delegating to a reserved allow-class right.
    "com.example.consent-delegate": {
        "class": "rule",
        "rule": ["system.burn"],
        "comment": "Test fixture. Non-reserved right delegating to a reserved right.",
    },
}


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__, file=sys.stderr)
        return 2
    target_dir = os.path.abspath(sys.argv[1])
    if os.path.exists(target_dir) and os.listdir(target_dir):
        print(f"refusing: {target_dir} exists and is not empty", file=sys.stderr)
        return 3

    with open(SHIPPED, "rb") as f:
        plist = plistlib.load(f)
    overlap = set(POISON) & set(plist["rights"])
    if overlap:
        print(f"refusing: fixture names already in the shipped plist: {sorted(overlap)}", file=sys.stderr)
        return 4
    plist["rights"].update(POISON)

    out_dir = os.path.join(target_dir, "System", "Library", "Security")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "authorization.plist")
    with open(out_path, "wb") as f:
        plistlib.dump(plist, f, fmt=plistlib.FMT_XML)
    print(out_path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
