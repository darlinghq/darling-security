#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Stress Darwin upward-library handling with Clang's long-command filelist.

Run on a Linux host with CMake, Clang and Darling's built cctools ld64:
  python3 darling/tests/test-upward-filelist.py --clang clang-19 \
    --ld /path/to/cctools/ld64/src/x86_64-apple-darwin20-ld \
    --output /new/private/test-directory

The synthetic dylibs implement no Security API and need no SDK. The fixed
option is generated from the production CMake file, rather than duplicated
in this test. Outputs and compiler diagnostics are retained for inspection.
"""

import argparse
import json
import os
from pathlib import Path
import re
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--clang', required=True)
    parser.add_argument('--ld', required=True)
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--cmake-file', type=Path,
                        default=Path(__file__).resolve().parents[2] / 'OSX/CMakeLists.txt')
    args = parser.parse_args()
    output = args.output.absolute()
    output.mkdir(parents=True, exist_ok=False)
    environment = dict(os.environ, TMPDIR=str(output))
    fixture = output / 'fixture.c'
    fixture.write_text('int fixture(void) { return 7; }\n')
    source = args.cmake_file.read_text()
    blocks = re.findall(
        r'target_link_options\(Security_\$\{APPLE_ARCH_(?:32|64)BIT\} PRIVATE.*?\n\t\)',
        source, re.S)
    assert len(blocks) == 2, 'expected final Security options for both architectures'
    results = []

    def run(label, command):
        (output / (label + '.json')).write_text(json.dumps(command, indent=2) + '\n')
        result = subprocess.run(command, cwd=output, env=environment,
                                capture_output=True, text=True)
        (output / (label + '.log')).write_text(result.stdout + result.stderr)
        return result

    for arch in ('i386', 'x86_64'):
        base = [args.clang, '-target', arch + '-apple-darwin20',
                '-mmacosx-version-min=11.0', '-nostdlib', '-fuse-ld=' + args.ld]
        obj = output / (arch + '.o')
        foundation = output / ('Foundation-' + arch)
        result = run(arch + '-compile', base + ['-c', str(fixture), '-o', str(obj)])
        assert result.returncode == 0, result.stderr
        result = run(arch + '-foundation', base + [
            '-dynamiclib', '-Wl,-install_name,/test/Foundation',
            '-o', str(foundation), str(obj)])
        assert result.returncode == 0, result.stderr

        # Generate real target options without building the Security source tree.
        cmake_source = output / ('cmake-' + arch)
        cmake_source.mkdir()
        (cmake_source / 'dummy.c').write_text('int dummy;\n')
        (cmake_source / 'CMakeLists.txt').write_text(
            'cmake_minimum_required(VERSION 3.13)\nproject(check_options C)\n'
            'set(APPLE_ARCH_32BIT i386)\nset(APPLE_ARCH_64BIT x86_64)\n'
            'add_library(Foundation SHARED IMPORTED)\n'
            'set_target_properties(Foundation PROPERTIES IMPORTED_LOCATION "'
            + str(foundation) + '")\n'
            'add_library(Security_i386 SHARED dummy.c)\n'
            'add_library(Security_x86_64 SHARED dummy.c)\n'
            + '\n'.join(blocks) + '\n'
            + 'file(GENERATE OUTPUT "${CMAKE_BINARY_DIR}/options.txt" CONTENT '
            '"$<JOIN:$<TARGET_PROPERTY:Security_' + arch + ',LINK_OPTIONS>,\n>")\n')
        cmake_build = cmake_source / 'build'
        result = run(arch + '-cmake', [
            'cmake', '-S', str(cmake_source), '-B', str(cmake_build)])
        assert result.returncode == 0, result.stderr
        options = (cmake_build / 'options.txt').read_text().splitlines()
        upward = [option.split(',', 2)[2] for option in options
                  if option.startswith('-Wl,-upward_library,')]
        assert len(upward) == 1
        assert Path(upward[0]).resolve() == foundation.resolve()

        # Unused dylib overrides lengthen the command without changing its
        # dependencies. This exercises actual driver execution, not just -###.
        padding = ['-Wl,-dylib_file,/unused/' + str(index) + '/' + 'p' * 650
                   + ':/unused/path' for index in range(230)]
        for fixed in (False, True):
            operand = upward[0] if fixed else str(foundation)
            label = arch + ('-fixed' if fixed else '-original')
            command = base + [
                '-dynamiclib', '-v', '-save-temps', '-Wl,-upward_library,' + operand,
            ] + padding + [str(obj), str(foundation), '-o', str(output / label)]
            result = run(label, command)
            assert '-filelist' in result.stderr, 'driver did not exercise filelist handling'
            if fixed:
                assert result.returncode == 0, result.stderr[-2000:]
            else:
                # A compiler which already fixes this issue may also succeed.
                assert result.returncode == 0 or 'file not found: -filelist' in result.stderr
            results.append({'case': label, 'returncode': result.returncode,
                            'baseline_bug_reproduced': not fixed and result.returncode != 0})

    (output / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
    print('UPWARD_FILELIST_REGRESSION_PASS', len(results), 'cases')


if __name__ == '__main__':
    main()
