# TODO: Get built version of usdtheadergen working in Darling.
#
# 1) Building usdtheadergen.
# ````
# # You can find usdtheadergen.c in the dtrace repo
# clang -ldtrace usdtheadergen.c -o usdtheadergen
# ````
# 2) Replace `xcrun usdtheadergen` with the path to your local built
# usdtheadergen executable.

set -e
PROJECT_DIR=$(cd ../.. && pwd)
BUILT_PRODUCTS_DIR="$PROJECT_DIR/gen"
mkdir -p "${BUILT_PRODUCTS_DIR}/derived_src"
mkdir -p "${BUILT_PRODUCTS_DIR}/derived_src/security_utilities/"
mkdir -p "${BUILT_PRODUCTS_DIR}/cstemp"

USDTHEADERGEN_EXEC="xcrun usdtheadergen"
# USDTHEADERGEN_EXEC="/Library/Developer/DarlingCLT/usr/bin/usdtheadergen"
$USDTHEADERGEN_EXEC -C -s "${PROJECT_DIR}/securityd/src/securityd.d" -o "${BUILT_PRODUCTS_DIR}/derived_src/securityd_dtrace.h"
$USDTHEADERGEN_EXEC -C -s "${PROJECT_DIR}/OSX/libsecurity_utilities/lib/security_utilities.d" -o "${BUILT_PRODUCTS_DIR}/derived_src/security_utilities/utilities_dtrace.h"
$USDTHEADERGEN_EXEC -C -s "${PROJECT_DIR}/OSX/libsecurity_codesigning/lib/security_codesigning.d" -o "${BUILT_PRODUCTS_DIR}/cstemp/codesigning_dtrace.h"
