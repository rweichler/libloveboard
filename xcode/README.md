1. `LOVE_GIT_PATH=$(pwd)`
2. `open platform/xcode/liblove.xcodeproj`
3. Build it
4. `cd ~/Library/Developer/Xcode/DerivedData/liblove-*/Build/Intermediates/liblove.build/Debug-iphoneos/liblove-ios.build/Objects-normal/arm64`
5. `clang++ -arch arm64 -isysroot $(xcrun --sdk iphoneos --show-sdk-path) -dynamiclib *.o -o libloveboard.dylib $LOVE_GIT_PATH/platform/xcode/ios/libraries/*/*.a -framework Foundation -framework CoreMotion -framework GameController -framework CoreGraphics -framework QuartzCore -framework AudioToolbox -framework UIKit -framework OpenGLES -framework OpenAL -lz`
6. `cd ../armv7`
7. Same command as before, but with `-arch armv7` instead of `-arch arm64`
8. `cd ..`
9. `lipo -create arm64/libloveboard.dylib armv7/libloveboard.dylib -output libloveboard.dylib`
10. Boom, done.
