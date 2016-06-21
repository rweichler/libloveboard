1. `open platform/xcode/liblove.xcodeproj`
2. Build it
3. `cd ~/Library/Developer/Xcode/DerivedData/liblove-*/Build/Intermediates/liblove.build/Debug-iphoneos/liblove-ios.build/Objects-normal/arm64
4. `clang++ -arch arm64 -isysroot `xcrun --sdk iphoneos --show-sdk-path` -dynamiclib *.o -o libloveboard.dylib ~/Downloads/love_ios/love-0.10.1-ios-source/platform/xcode/ios/libraries/*/*.a -framework Foundation -framework CoreMotion -framework GameController -framework CoreGraphics -framework QuartzCore -framework AudioToolbox -framework UIKit -framework OpenGLES -framework OpenAL -lz`
5. `cd ../armv7`
6. Same command as before, but with `-arch armv7` instead of `-arch arm64`
7. `cd ..`
8. `lipo -create arm64/libloveboard.dylib armv7/libloveboard.dylib -output libloveboard.dylib`
9. Boom, done.
