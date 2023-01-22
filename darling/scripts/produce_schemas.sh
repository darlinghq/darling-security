PROJECT_DIR=$(cd ../.. && pwd)
BUILT_PRODUCTS_DIR="$PROJECT_DIR/gen"
mkdir -p $BUILT_PRODUCTS_DIR/derived_src

TARGET=$BUILT_PRODUCTS_DIR/derived_src/KeySchema.cpp
/usr/bin/m4 ${PROJECT_DIR}/OSX/libsecurity_cdsa_utilities/lib/KeySchema.m4 > $TARGET.new
cmp -s $TARGET.new $TARGET || mv $TARGET.new $TARGET

TARGET=$BUILT_PRODUCTS_DIR/derived_src/Schema.cpp
/usr/bin/m4 ${PROJECT_DIR}/OSX/libsecurity_cdsa_utilities/lib/Schema.m4 > $TARGET.new
cmp -s $TARGET.new $TARGET || mv $TARGET.new $TARGET