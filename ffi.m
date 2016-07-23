#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <ImageIO/ImageIO.h>
#include <MobileCoreServices/MobileCoreServices.h>

bool l_fix_png(const char *source, const char *dest)
{
    @autoreleasepool {
        CGImageRef image = [UIImage imageWithContentsOfFile:[NSString stringWithUTF8String:source]].CGImage;

        CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:[NSString stringWithUTF8String:dest]];
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
        if (!destination) {
            return false;
        }
        CGImageDestinationAddImage(destination, image, nil);

        bool success = CGImageDestinationFinalize(destination);
        CFRelease(destination);
        return success;
    }
}
