//
//  WindowShow.m
//  JPEGDeux
//
//  Created by Peter on Tue Sep 04 2001.
//

#import "WindowShow.h"
#import "BackgroundImageView.h"

@implementation WindowShow

- (void)dealloc {
    [myWindow release];
    [myImageView release];
    [super dealloc];
}

- (void)beginShow:(NSArray*)files {
    myWindow=[[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 800, 600)
                               styleMask:NSTitledWindowMask | NSResizableWindowMask | NSMiniaturizableWindowMask | NSClosableWindowMask
                               backing:NSBackingStoreBuffered
                               defer:NO];
    [myWindow useOptimizedDrawing:YES];
    myImageView=[[BackgroundImageView alloc] initWithFrame:NSMakeRect(0, 0, 600, 350)];
    [myImageView setFrame:[myWindow frame]];
    [myImageView setImageScaling:myScaling];
    [myWindow setContentView:myImageView];
    [myWindow setReleasedWhenClosed:NO];
    [myWindow setDelegate:self];
    
    [myWindow center];
    [myWindow setFrameUsingName:@"WindowShowFrame"];
    [myWindow setFrameAutosaveName:@"WIndowShowFrame"];
    [myWindow makeKeyAndOrderFront:self];
    [super beginShow:files];
}

- (void)setImage:(NSImage*)image {
    [myImageView setImage:image];
}

- (void)setImageName:(NSString*)name {
    [myImageView setImageName:name];
}

- (void)loadNextImage {
    [super loadNextImage];
    //cached images are already set to the proper size
    if (myNextImage && myCachedImages==nil) {
        NSSize oldSize=[myNextImage size];
        NSSize newSize=[myImageView scaledSizeForSize:oldSize];
        if (! NSEqualSizes(newSize, oldSize)) {
            [myNextImage setScalesWhenResized:YES];
            [myNextImage setSize:newSize];
            [myNextImage lockFocus];
            [myNextImage unlockFocus];
        }
    }
}

+ (int)tagNumber {
    return 0;
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

- (BOOL)windowShouldClose:(NSWindow*)window {
    NSEvent* event=[NSEvent otherEventWithType:NSApplicationDefined
                            location:NSMakePoint(0,0)
                            modifierFlags:0
                            timestamp:0 /* This is supposed to be the time since system startup; how do we get that?? */
                            windowNumber:[window windowNumber]
                            context:[NSGraphicsContext currentContext]
                            subtype:StopSlideshowEventType
                            data1:0
                            data2:0];
    [[NSApplication sharedApplication] postEvent:event atStart:YES];
    return YES;
}

- (NSSize)displaySizeForSize:(NSSize)size {
    return [myImageView scaledSizeForSize:size];
}

- (void)setBackgroundColor:(NSColor*)color {
    [myImageView setColor:color];
    [myWindow setBackgroundColor:color];
}

- (unsigned)estimatedSizeOfCachedImages {
    unsigned bytesPerPixel=(NSBitsPerPixelFromDepth([[NSScreen mainScreen] depth]) + 7) / 8;
    NSSize windowSize=[myImageView bounds].size;
    return bytesPerPixel*windowSize.width*windowSize.height*[myChosenFiles count];
}

@end
