//
//  ScreenShow.h
//  JPEGDeux
//
//  Created by Peter on Wed Sep 05 2001.
//

@class BackgroundImageView;

#import <Cocoa/Cocoa.h>
#import "SlideShow.h"
#import "ScreenShow.h"
#import <QuartzCore/CAAnimation.h>

@interface TransitionScreenShow : ScreenShow {
    NSWindow* myOtherCoveringWindow;
    BackgroundImageView* myOtherImageView;
    SEL myTransition;
    float myIncrement;
	NSTimeInterval transitionSpeed;
}

//transitions
- (void)fade:(NSImage*)image;
- (void)scrollFromBottom:(NSImage*)image;
- (void)scrollFromTop:(NSImage*)image;
- (void)scrollFromRight:(NSImage*)image;
- (void)scrollFromLeft:(NSImage*)image;

@end
