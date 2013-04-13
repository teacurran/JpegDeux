//
//  ImageWindowController.h
//  JPEGDeux 2
//
//  Created by Peter Ammon on Sat Nov 23 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BackgroundImageView;

@interface ImageWindowController : NSWindowController {
    NSString* myFilePath;
    NSImage* myImage;
    IBOutlet BackgroundImageView* myImageView;
}

+ (ImageWindowController*)controllerForPath:(NSString*)path;

@end
