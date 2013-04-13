#import <Cocoa/Cocoa.h>
#import "FixedBitmapImageRep.h"
#import <Foundation/NSDebug.h>

#define MAKE_CODE(a,b,c,d) ( ((unsigned long)a << 24 ) + \
                             ((unsigned long)b << 16 ) + \
                             ((unsigned long)c << 8 ) + \
                             (unsigned long)d )

const unsigned long gCreatorCode = MAKE_CODE('J', 'p', 'g', 'D');
const unsigned long gSSTypeCode = MAKE_CODE('J', 'p', 'g', 'D');

int main(int argc, const char *argv[])
{
//    NSZombieEnabled=YES;
    srandom(time(NULL));
    [FixedBitmapImageRep poseAsClass:[NSBitmapImageRep class]];
    return NSApplicationMain(argc, argv);
}
