//
//  WindowQTShow.m
//  JPEGDeux 2
//
//  Created by peter on Sun Jun 30 2002.
//  This code is released under the Modified BSD license
//

#import "WindowQTShow.h"


@implementation WindowQTShow

- (void)beginShow:(NSArray*)files {
    myWindow=[[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 800, 600)
                                         styleMask:NSTitledWindowMask | NSResizableWindowMask | NSMiniaturizableWindowMask | NSClosableWindowMask
                                           backing:NSBackingStoreBuffered
                                             defer:NO];
    [myWindow useOptimizedDrawing:YES];
    [myWindow setReleasedWhenClosed:NO];
    [myWindow setDelegate:self];

    [myWindow center];
    [myWindow setFrameUsingName:@"WindowShowFrame"];
    [myWindow setFrameAutosaveName:@"WindowShowFrame"];
    [myWindow makeKeyAndOrderFront:self];
    [super beginShow:files];
}

@end
