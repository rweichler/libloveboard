NAME=LoveBoard
DYLIB=$(NAME).dylib
PLIST=$(NAME).plist


all: $(DYLIB)


package: $(DYLIB) $(PLIST)
	rm -rf tmp
	mkdir tmp
	cp -r DEBIAN tmp/
	# substrate
	mkdir tmp/Library
	mkdir tmp/Library/MobileSubstrate
	mkdir tmp/Library/MobileSubstrate/DynamicLibraries
	cp $(DYLIB) tmp/Library/MobileSubstrate/DynamicLibraries
	cp $(PLIST) tmp/Library/MobileSubstrate/DynamicLibraries
	# game
	mkdir tmp/var
	mkdir tmp/var/mobile
	cp -r LOVE_GAME tmp/var/mobile
	# liblove
	mkdir tmp/usr
	mkdir tmp/usr/lib
	cp liblove.dylib tmp/usr/lib/
	dpkg-deb -Zgzip -b tmp
	mv tmp.deb LoveBoard.deb


$(DYLIB): hook.m
	clang $< -dynamiclib -o $@ -Linc -Iinc -lsubstrate -framework Foundation -arch arm64 -isysroot `xcrun --sdk iphoneos --show-sdk-path`
