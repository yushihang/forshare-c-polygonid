#!/bin/sh
# To select a specific SDK, run 'xcodebuild -showsdks'
# You need to specify SDK & CLANGARCH

SDK_PATH=$(xcrun --sdk "$SDK" --show-sdk-path)
export SDK_PATH

if [ "$GOARCH" = "amd64" ]; then
    CARCH="x86_64"
elif [ "$GOARCH" = "arm64" ]; then
    CARCH="arm64"
fi

if [ "$SDK" = "iphoneos" ]; then
  export TARGET="$CARCH-apple-ios$MIN_VERSION"
elif [ "$SDK" = "iphonesimulator" ]; then
  export TARGET="$CARCH-apple-ios$MIN_VERSION-simulator"
fi


export IPHONEOS_DEPLOYMENT_TARGET=5.1
# cmd/cgo doesn't support llvm-gcc-4.2, so we have to use clang.
CLANG=`xcrun --sdk $SDK --find clang`

exec "$CLANG" -target "$TARGET" -isysroot "$SDK_PATH" "$@"

#xcodebuild -create-xcframework -library libpolygonid-ios.a -headers ./header  -library libpolygonid-ios-simulator.a -headers ./header  -output polygonid.xcframework