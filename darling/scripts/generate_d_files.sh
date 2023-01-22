# In the more recent versions of Darling, you shouldn't need to manually build
# usdtheadergen. However, instruction are provided incase you need to.
#
# 1) Building usdtheadergen.
# ````
# clang -ldtrace usdtheadergen.c -o usdtheadergen
# ````
# 2) Replace `xcrun usdtheadergen` with the path to your local built
# usdtheadergen executable.

set -e
BUILT_PRODUCTS_DIR=$(realpath ../../..)
PROJECT_DIR=$(realpath ../../..)
mkdir -p "${BUILT_PRODUCTS_DIR}/derived_src"
mkdir -p "${BUILT_PRODUCTS_DIR}/derived_src/security_utilities/"
mkdir -p "${BUILT_PRODUCTS_DIR}/cstemp"

xcrun usdtheadergen -C -s "${PROJECT_DIR}/securityd/src/securityd.d" -o "${BUILT_PRODUCTS_DIR}/derived_src/securityd_dtrace.h"
xcrun usdtheadergen -C -s "${PROJECT_DIR}/OSX/libsecurity_utilities/lib/security_utilities.d" -o "${BUILT_PRODUCTS_DIR}/derived_src/security_utilities/utilities_dtrace.h"
xcrun usdtheadergen -C -s "${PROJECT_DIR}/OSX/libsecurity_codesigning/lib/security_codesigning.d" -o "${BUILT_PRODUCTS_DIR}/cstemp/codesigning_dtrace.h"
