//
//  ScreenShow.h
//  JPEGDeux
//
//  Created by Peter on Wed Sep 05 2001.
//

@class BackgroundImageView;

#import <Cocoa/Cocoa.h>
#import "SlideShow.h"

@interface ScreenShow : SlideShow {
    NSWindow* myCoveringWindow;
    BackgroundImageView* myImageView;
    NSGraphicsContext* myContext;
}

@end
