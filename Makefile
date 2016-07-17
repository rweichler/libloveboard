NAME=LoveBoard
DYLIB=$(NAME).dylib
PLIST=$(NAME).plist
DEB=$(NAME).deb
LUA=lua
LOCY=locy

all: $(DYLIB) $(LOCY)

.PHONY: all clean package

clean:
	rm -rf tmp
	rm -f $(DYLIB)
	rm -f $(DEB)
	rm -f $(LOCY)

package: $(DEB)
	
$(DEB): $(DYLIB) $(LOCY) $(PLIST) $(LUA) DEBIAN
	@rm -rf tmp
	@mkdir tmp
	# deb info
	@cp -r DEBIAN tmp/
	# substrate
	@mkdir tmp/Library
	@mkdir tmp/Library/MobileSubstrate
	@mkdir tmp/Library/MobileSubstrate/DynamicLibraries
	@cp $(DYLIB) tmp/Library/MobileSubstrate/DynamicLibraries
	@cp $(PLIST) tmp/Library/MobileSubstrate/DynamicLibraries
	# game
	@mkdir tmp/var
	@mkdir tmp/var/mobile
	@cp -r $(LUA) tmp/var/mobile/LoveBoard
	# liblove
	@mkdir tmp/usr
	@mkdir tmp/usr/lib
	@cp libloveboard.dylib tmp/usr/lib/
	# relove command
	@mkdir tmp/usr/bin
	@cp relove tmp/usr/bin/
	# locy command
	@cp locy tmp/usr/bin/
	# pack it up ($@)
	@dpkg-deb -Zgzip -b tmp > /dev/null
	@mv tmp.deb $@


$(DYLIB): hook.m luahack.h
	clang $< -dynamiclib -o $@ -Linc -Iinc -lsubstrate -lrocketbootstrap -framework Foundation -arch arm64 -arch armv7 -isysroot `xcrun --sdk iphoneos --show-sdk-path` -Wno-objc-method-access

$(LOCY): locy.c
	clang $< -o $@ -Linc -Iinc -lrocketbootstrap -framework CoreFoundation -arch arm64 -arch armv7 -isysroot `xcrun --sdk iphoneos --show-sdk-path`

SSH_FLAGS=-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

install: $(DEB)
	scp $(SSH_FLAGS) $(DEB) 5s:.
	ssh $(SSH_FLAGS) 5s "dpkg -i $(DEB)"
	ssh $(SSH_FLAGS) 5s "rm $(DEB)"
