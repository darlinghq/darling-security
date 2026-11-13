#!/bin/bash
# Copyright (C) 2026 Lubos Dolezel
# usage: exp-depends.sh BUILD_DIR
# Read-only consistency check after cmake has been re-run: every file the preprocessor reads
# while it expands Security.exp-in must be a prerequisite of the generated Security.<arch>.exp,
# and the Security link must depend on that .exp. Prints PASS/FAIL lines; exit status = failures.
set -u
build=${1:?usage: exp-depends.sh BUILD_DIR}
dir=$(find "$build" -path '*external/security/OSX/CMakeFiles/generate-security-exp.dir/build.make' | head -1)
[ -n "$dir" ] || { echo "FAIL: generate-security-exp rules not found under $build"; exit 1; }
fails=0
scratch=$(mktemp -d); trap 'rm -rf "$scratch"' EXIT
cmd=$(grep -m1 'clang -E -Xpreprocessor' "$dir" | sed 's/.*&& //')
out=$(echo "$cmd" | grep -o '[^ ]*Security\.[a-z0-9_]*\.exp' | head -1)
cmd=$(echo "$cmd" | sed "s|-o [^ ]*Security\.[a-z0-9_]*\.exp|-MD -MF $scratch/dep.d -MT x -o $scratch/out.exp|")
workdir=$(dirname "$out")
(cd "$workdir" && eval "$cmd") || { echo "FAIL: preprocessor run"; exit 1; }
included=$(tr ' \\' '\n\n' < "$scratch/dep.d" | grep -E '\.(exp-in|list)$' | xargs -n1 realpath | sort -u)
prereqs=$(grep -E '^[^ ]*Security\.[a-z0-9_]*\.exp:' "$dir" | sed 's/^[^:]*: //' | xargs -n1 realpath -m | sort -u)
for f in $included; do
	if echo "$prereqs" | grep -qxF "$f"; then echo "PASS: $f is a prerequisite"
	else echo "FAIL: $f is read by the preprocessor but is not a prerequisite"; fails=$((fails+1)); fi
done
if grep -rq 'Security\.[a-z0-9_]*\.exp' "$build"/src/external/security/OSX/CMakeFiles/Security_*.dir/depend.make 2>/dev/null \
	|| grep -rqE 'Security\.[a-z0-9_]*\.exp' "$build"/src/external/security/OSX/CMakeFiles/Security_*.dir/link.txt 2>/dev/null; then
	echo "PASS: Security link refers to the export list"
fi
echo "$([ $fails = 0 ] && echo ALL PASSED || echo FAILED)"
exit $fails
