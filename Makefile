NAME=LoveBoard
DYLIB=$(NAME).dylib
PLIST=$(NAME).plist
DEB=$(NAME).deb

all: $(DYLIB)

.PHONY: all clean package

clean:
	rm -rf tmp
	rm -f $(DYLIB)
	rm -f $(DEB)

package: $(DEB)
	
$(DEB): $(DYLIB) $(PLIST) LOVE_GAME DEBIAN
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
	mv tmp.deb $@


$(DYLIB): hook.m
	clang $< -dynamiclib -o $@ -Linc -Iinc -lsubstrate -framework Foundation -arch arm64 -arch armv7 -isysroot `xcrun --sdk iphoneos --show-sdk-path`

install: $(DEB)
	scp $(DEB) 5s:.
	ssh 5s "dpkg -i $(DEB)"
	ssh 5s "rm $(DEB)"
