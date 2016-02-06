//
//  ScreenShow.m
//  JPEGDeux
//
//  Created by Peter on Wed Sep 05 2001.
//

#import "ScreenShow.h"
#import "BackgroundImageView.h"
#import <Carbon/Carbon.h>
#import "BackgroundImageView.h"
#import "TransitionScreenShow.h"

@implementation ScreenShow

- (id)initWithParams:(NSDictionary*)params {
    if ([[params objectForKey:@"Transition"] intValue] && [self class]==[ScreenShow class]) {
        [self dealloc];
        return [[TransitionScreenShow alloc] initWithParams:params];
    }
    return [super initWithParams:params];
}

- (void)dealloc {
    [NSMenu setMenuBarVisible:YES];

    [myCoveringWindow orderOut:self];
    [myContext release];
    [myCoveringWindow release];
    [myImageView release];
    [super dealloc];
}

- (void)beginShow:(NSArray*)files {
    myCoveringWindow=[[NSWindow alloc] initWithContentRect:[[NSScreen mainScreen] frame]
                       styleMask:NSBorderlessWindowMask
                       backing:NSBackingStoreBuffered
                       defer:NO];
    [myCoveringWindow useOptimizedDrawing:YES];
    myImageView=[[BackgroundImageView alloc] initWithFrame:[myCoveringWindow frame]];
    //myImageView=[[TransitionImageView alloc] initWithFrame:[myCoveringWindow frame]];
    [myImageView setColor:[NSColor blackColor]];
    [myImageView setImageScaling:myScaling];
    [myCoveringWindow setContentView:myImageView];

    [NSMenu setMenuBarVisible:NO];
    
    [myCoveringWindow makeKeyAndOrderFront:self];
    myContext=[[NSGraphicsContext graphicsContextWithWindow:myCoveringWindow] retain];
    [super beginShow:files];
}

- (void)loadNextImage {
    [super loadNextImage];
    //cached images are already set to the proper size
    if (myNextImage && myCachedImages==nil) {
        NSSize oldSize=[myNextImage size];
        NSSize newSize=[myImageView scaledSizeForSize:oldSize];
        if (! NSEqualSizes(newSize, oldSize)) {
            [myNextImage setSize:newSize];
            [myNextImage lockFocus];
            [myNextImage unlockFocus];
        }
    }
}

- (void)setImage:(NSImage*)image {
    [myImageView setRotation:myRotation];
    //myRotation=0;
    [myImageView setImage:image];
}

- (void)setImageName:(NSString*)name {
    [myImageView setImageName:name];
}

- (void)flipHorizontal {
    [myImageView flipHorizontal];
}

- (void)flipVertical {
    [myImageView flipVertical];
}

- (void)redisplay {
    [myImageView display];
}

- (void)rotate:(int)v {
    [super rotate:v];
    [myImageView setRotation:myRotation];
}

+ (int)tagNumber {
    return 1;
}

- (NSSize)displaySizeForSize:(NSSize)size {
    return [myImageView scaledSizeForSize:size];
}

- (void)setBackgroundColor:(NSColor*)color {
    [myCoveringWindow setBackgroundColor:color];
    [myImageView setColor:color];
}

- (long)estimatedSizeOfCachedImages {
    long bytesPerPixel=(NSBitsPerPixelFromDepth([[NSScreen mainScreen] depth]) + 7) / 8;
    NSSize screenSize=[[NSScreen mainScreen] frame].size;
    return bytesPerPixel*screenSize.width*screenSize.height*[myChosenFiles count];
}

@end
