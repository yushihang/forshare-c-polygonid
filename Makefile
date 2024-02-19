IOS_OUT=ios

#go install golang.org/x/mobile/cmd/gomobile@latest
ios-arm64:
	GOOS=ios \
	GOARCH=arm64 \
	CGO_ENABLED=1 \
	CLANGARCH=arm64 \
	SDK=iphoneos \
	CC=$(PWD)/clangwrap.sh \
	CGO_CFLAGS="-fembed-bitcode" \
	go build -ldflags="-s -w" -buildmode=c-archive -o $(IOS_OUT)/libpolygonid-ios-arm64.a ./cmd/polygonid


ios-simulator-x86_64:
	GOOS=ios \
	GOARCH=amd64 \
	CGO_ENABLED=1 \
	CLANGARCH=x86_64 \
	SDK=iphonesimulator \
	CC=$(PWD)/clangwrap.sh \
	CGO_CFLAGS="-fembed-bitcode" \
	go build -ldflags="-s -w" -tags ios -buildmode=c-archive -o $(IOS_OUT)/libpolygonid-ios-simulator-x86_64.a ./cmd/polygonid

ios-simulator-arm64:
	GOOS=ios \
	GOARCH=arm64 \
	CGO_ENABLED=1 \
	CLANGARCH=arm64 \
	CC=$(PWD)/clangwrap1.sh \
	SDK=iphonesimulator \
	CGO_CFLAGS="-fembed-bitcode" \
	go build -ldflags="-s -w" -tags ios -buildmode=c-archive -o $(IOS_OUT)/libpolygonid-ios-simulator-arm64.a ./cmd/polygonid

darwin-arm64:
	GOOS=darwin \
	GOARCH=arm64 \
	CGO_ENABLED=1 \
	CLANGARCH=arm64 \
	go build -buildmode=c-archive -o $(IOS_OUT)/libpolygonid-darwin-arm64.a ./cmd/polygonid

iosmake: ios-arm64 ios-simulator-x86_64
	lipo $(IOS_OUT)/libpolygonid-ios.a $(IOS_OUT)/libpolygonid-ios-simulator.a -create -output $(IOS_OUT)/libpolygonid.go get golang.org/x/mobile/cmd/gomobile@nonea
	cp $(IOS_OUT)/libpolygonid-ios.h $(IOS_OUT)/libpolygonid.h

dylib:
	go build -buildmode=c-shared -o $(IOS_OUT)/libpolygonid.dylib ./cmd/polygonid

ANDROID_OUT=android
ANDROID_NDK_HOME?=$(ANDROID_HOME)/ndk/22.1.7171670

android-armeabi-v7a:
	GOOS=android \
	GOARCH=arm \
	CGO_ENABLED=1 \
	CC=$(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/darwin-x86_64/bin/armv7a-linux-androideabi21-clang \
	go build -ldflags="-s -w" -x -buildmode=c-shared -o $(ANDROID_OUT)/jnilibs/armeabi-v7a/libpolygonid.so ./cmd/polygonid

android-arm64-v8a:
	GOOS=android \
	GOARCH=arm64 \
	CGO_ENABLED=1 \
	CC=$(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android21-clang \
	go build -ldflags="-s -w" -x -buildmode=c-shared -o $(ANDROID_OUT)/jnilibs/arm64-v8a/libpolygonid.so ./cmd/polygonid

android-x86:
	GOOS=android \
	GOARCH=386 \
	CGO_ENABLED=1 \
	CC=$(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/darwin-x86_64/bin/i686-linux-android21-clang \
	go build -ldflags="-s -w" -x -buildmode=c-shared -o $(ANDROID_OUT)/jnilibs/x86/libpolygonid.so ./cmd/polygonid

android-x86-64:
	GOOS=android \
	GOARCH=amd64 \
	CGO_ENABLED=1 \
	CC=$(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/darwin-x86_64/bin/x86_64-linux-android21-clang \
	go build -ldflags="-s -w" -x -buildmode=c-shared -o $(ANDROID_OUT)/jnilibs/x86-64/libpolygonid.so ./cmd/polygonid

android: android-armeabi-v7a android-arm64-v8a android-x86 android-x86-64

all: android ios
