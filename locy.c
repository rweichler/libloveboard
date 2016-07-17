#include <CoreFoundation/CoreFoundation.h>
#include "rocketbootstrap.h"

int main(int argc, char *argv[])
{
    if(argc == 1) {
        printf("you needa type the lua code too you fucking RETARD\n");
        return 1;
    }

    int len = 1;
    for(int i = 1; i < argc; i++) {
        len += strlen(argv[i]) + 1;
    }
    char cmd[len];
    cmd[0] = 0;
    for(int i = 1; i < argc; i++) {
        strcat(cmd, argv[i]);
        strcat(cmd, " ");
    }

    CFDataRef data = CFDataCreate(NULL, (const unsigned char *)cmd, strlen(cmd) + 1);
    SInt32 messageID = 0x1111; // Arbitrary
    CFTimeInterval timeout = 10.0;

    CFMessagePortRef remotePort =
        rocketbootstrap_cfmessageportcreateremote(nil,
                                  CFSTR("com.r333d.loveboard.console.server"));

    CFDataRef returnData;
    SInt32 status =
        CFMessagePortSendRequest(remotePort,
                                 messageID,
                                 data,
                                 timeout,
                                 timeout,
                                 kCFRunLoopDefaultMode,
                                 &returnData);
    
    if (status == kCFMessagePortSuccess) {
        if(returnData == NULL) {
            printf("return data is fucking NULL\n");
        } else {
            CFIndex len = CFDataGetLength(returnData);
            unsigned char yee[len];
            CFDataGetBytes(returnData, CFRangeMake(0, len), yee);
            printf("%s\n", yee);
        }
    }
}
