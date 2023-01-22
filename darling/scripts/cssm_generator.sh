BUILT_PRODUCTS_DIR=$(realpath `dirname "$0"`/../..)
PROJECT_DIR=$BUILT_PRODUCTS_DIR
SRCROOT=$BUILT_PRODUCTS_DIR

TARGET="${BUILT_PRODUCTS_DIR}/derived_src"
CONFIG="${PROJECT_DIR}/OSX/libsecurity_cssm/lib/generator.cfg"

mkdir -p ${TARGET}
/usr/bin/perl ${PROJECT_DIR}/OSX/libsecurity_cssm/lib/generator.pl "${SRCROOT}/OSX/libsecurity_cssm/lib/" "${CONFIG}" "${TARGET}"