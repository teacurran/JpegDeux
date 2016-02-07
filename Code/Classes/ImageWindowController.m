//
//  ImageWindowController.m
//  JPEGDeux 2
//
//  Created by Peter Ammon on Sat Nov 23 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import "ImageWindowController.h"
#import "BackgroundImageView.h"

static NSMutableDictionary* sPathsToControllers;

@implementation ImageWindowController

- (id)initForPath:(NSString*)path {
    NSWindow* window;
    NSRect imageRect={{0}};
    NSRect frameRect={{0}};
    NSSize imageViewSize={0};
    self=[super initWithWindowNibName:@"ImageWindow"];
    if (!self || ! path) {
        self=nil;
    }
    else {
        myFilePath=[path copy];
        if ([myFilePath hasPrefix:@"http://"]) {
            NSURL* url=[NSURL URLWithString:myFilePath];
            if (url) myImage=[[NSImage alloc] initWithContentsOfURL:url];
        }
        else myImage=[[NSImage alloc] initByReferencingFile:myFilePath];
        if (! [myImage isValid]) {
            self=nil;
        } else {
            imageRect.size=[myImage size];
        }
    }
    if (self) {
        window=[self window];
        [myImageView setImageScaling:ScaleProportionally];
        [myImageView setImage:myImage];
        imageViewSize=[myImageView bounds].size;
        [window setContentSize:imageViewSize];
        frameRect=[NSWindow frameRectForContentRect:[myImageView frame] styleMask:[window styleMask]];
        [window setAspectRatio:frameRect.size];
        [window setTitle:[myFilePath lastPathComponent]];
        [window makeKeyAndOrderFront:self];
    }
    return self;
}

+ (ImageWindowController*)controllerForPath:(NSString*)path {
    ImageWindowController* c;
    c=[sPathsToControllers objectForKey:path];
    if (! c) {
        c=[[self alloc] initForPath:path];
        if (c) {
            if (! sPathsToControllers) sPathsToControllers=[[NSMutableDictionary alloc] init];
            [sPathsToControllers setObject:c forKey:path];
        }
    }
    return c;
}

- (IBAction)closeWindow:(id)sender {
    [sPathsToControllers removeObjectForKey:myFilePath];
}

- (BOOL)windowShouldClose:(id)sender {
    [sPathsToControllers removeObjectForKey:myFilePath];;
    return YES;
}

@end
