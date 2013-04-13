//
//  DockShow.m
//  JPEGDeux
//
//  Created by Peter on Wed Sep 05 2001.


#import "DockShow.h"

static NSApplication* application;
static NSImage* originalImage;

@implementation DockShow

- (id)init {
    if (self=[super init]) {
        application=[NSApplication sharedApplication];
        if (!originalImage) originalImage=[[application applicationIconImage] retain];
    }
    return self;
}

- (void)dealloc {
    [application setApplicationIconImage:originalImage];
    [super dealloc];
}

- (void)setImage:(NSImage*)image {
    [application setApplicationIconImage:image];
}

+ (int)tagNumber {
    return 2;
}

- (NSSize)displaySizeForSize:(NSSize)size {
    return NSMakeSize(128, 128);
}

- (unsigned)estimatedSizeOfCachedImages {
    unsigned bytesPerPixel=(NSBitsPerPixelFromDepth([[NSScreen mainScreen] depth]) + 7) / 8;
    return bytesPerPixel*128*128*[myChosenFiles count];
}

@end
