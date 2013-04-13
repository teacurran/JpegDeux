//
//  WindowShow.h
//  JPEGDeux
//
//  Created by Peter on Tue Sep 04 2001.
//

@class BackgroundImageView;

#import <Cocoa/Cocoa.h>
#import "SlideShow.h"

@interface WindowShow : SlideShow {
    IBOutlet NSWindow* myWindow;
    IBOutlet BackgroundImageView* myImageView;
}

- (void)beginShow:(NSArray*)files;
- (void)setImage:(NSImage*)image;

@end
