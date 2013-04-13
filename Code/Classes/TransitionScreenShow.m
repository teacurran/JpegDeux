//
//  ScreenShow.m
//  JPEGDeux
//
//  Created by Peter on Wed Sep 05 2001.
//

#import "TransitionScreenShow.h"
#import "BackgroundImageView.h"
#import <Carbon/Carbon.h>

@implementation TransitionScreenShow

- (id)initWithParams:(NSDictionary*)params {
    if (self=[super initWithParams:params]) {
        float steps;
        NSNumber* transition=[params objectForKey:@"Transition"];
        SEL selector=nil;
        if (! transition) {
            NSLog(@"Oops!  How did a transition show not get a transition?");
            return nil;
        }
        switch ([transition intValue]) {
            case 1: selector=@selector(fade:); break;
            case 2: selector=@selector(scrollFromLeft:); break;
            case 3: selector=@selector(scrollFromRight:); break;
            case 4: selector=@selector(scrollFromTop:); break;
            case 5: selector=@selector(scrollFromBottom:); break;
        }
        if (! selector || ! [self respondsToSelector:selector]) {
            NSLog(@"Oops!  %@ doesn't respond to %@", self, transition);
            return nil;
        }
        myTransition=selector;
        steps=[[params objectForKey:@"NumSteps"] floatValue];
        if (steps < 1.0) steps=1.0;
        myIncrement=1.0/steps;
    }
    return self;
}

- (void)dealloc {
    [myOtherCoveringWindow orderOut:self];
    [myOtherCoveringWindow release];
    [myOtherImageView release];
    [super dealloc];
}

- (void)beginShow:(NSArray*)files {
    myOtherCoveringWindow=[[NSWindow alloc] initWithContentRect:[[NSScreen mainScreen] frame]
                                                 styleMask:NSBorderlessWindowMask
                                                   backing:NSBackingStoreBuffered
                                                     defer:NO];
    [myOtherCoveringWindow useOptimizedDrawing:YES];
    myOtherImageView=[[BackgroundImageView alloc] initWithFrame:[myOtherCoveringWindow frame]];
    [myOtherImageView setColor:[NSColor blackColor]];
    [myOtherImageView setImageScaling:myScaling];
    [myOtherCoveringWindow setContentView:myOtherImageView];
    [myOtherCoveringWindow makeKeyAndOrderFront:self];

    [super beginShow:files];
}

- (void)loadNextImage {
    [super loadNextImage];
    [myOtherImageView setImage:myNextImage];
}

#define swap(a, b) do { id temp; temp=a; a=b; b=temp; } while (0)
- (void)scrollFromLeft:(NSImage*)image {
    const NSRect rect=[myOtherCoveringWindow frame];
    const float width=rect.size.width;
    const NSPoint point=rect.origin;
    float i;
    [myOtherImageView setRotation:myRotation];
    [myOtherCoveringWindow setFrameOrigin:NSMakePoint(point.x-width, point.y)];
    [myOtherCoveringWindow makeKeyAndOrderFront:self];
    for (i=1; i>0; i-=myIncrement) {
        NSPoint newPoint;
        newPoint.y=point.y;
        newPoint.x=point.x-i*width;
        [myOtherCoveringWindow setFrameOrigin:newPoint];
    }
    [myOtherCoveringWindow setFrameOrigin:point];
    swap(myCoveringWindow, myOtherCoveringWindow);
    swap(myImageView, myOtherImageView);
}

- (void)scrollFromRight:(NSImage*)image {
    const NSRect rect=[myOtherCoveringWindow frame];
    const float width=rect.size.width;
    const NSPoint point=rect.origin;
    float i;
    [myOtherImageView setRotation:myRotation];
    [myOtherCoveringWindow setFrameOrigin:NSMakePoint(point.x+width, point.y)];
    [myOtherCoveringWindow makeKeyAndOrderFront:self];
    for (i=1; i>0; i-=myIncrement) {
        NSPoint newPoint;
        newPoint.y=point.y;
        newPoint.x=point.x+i*width;
        [myOtherCoveringWindow setFrameOrigin:newPoint];
    }
    [myOtherCoveringWindow setFrameOrigin:point];
    swap(myCoveringWindow, myOtherCoveringWindow);
    swap(myImageView, myOtherImageView);
}

- (void)scrollFromTop:(NSImage*)image {
    const NSRect rect=[myOtherCoveringWindow frame];
    const float height=rect.size.height;
    const NSPoint point=rect.origin;
    float i;
    [myOtherImageView setRotation:myRotation];
    [myOtherCoveringWindow setFrameOrigin:NSMakePoint(point.x, point.y+height)];
    [myOtherCoveringWindow makeKeyAndOrderFront:self];
    for (i=1; i>0; i-=myIncrement) {
        NSPoint newPoint;
        newPoint.y=point.y+i*height;
        newPoint.x=point.x;
        [myOtherCoveringWindow setFrameOrigin:newPoint];
    }
    [myOtherCoveringWindow setFrameOrigin:point];
    swap(myCoveringWindow, myOtherCoveringWindow);
    swap(myImageView, myOtherImageView);
}

- (void)scrollFromBottom:(NSImage*)image {
    const NSRect rect=[myOtherCoveringWindow frame];
    const float height=rect.size.height;
    const NSPoint point=rect.origin;
    float i;
    [myOtherImageView setRotation:myRotation];
    [myOtherCoveringWindow setFrameOrigin:NSMakePoint(point.x, point.y-height)];
    [myOtherCoveringWindow makeKeyAndOrderFront:self];
    for (i=1; i>0; i-=myIncrement) {
        NSPoint newPoint;
        newPoint.y=point.y-i*height;
        newPoint.x=point.x;
        [myOtherCoveringWindow setFrameOrigin:newPoint];
    }
    [myOtherCoveringWindow setFrameOrigin:point];
    swap(myCoveringWindow, myOtherCoveringWindow);
    swap(myImageView, myOtherImageView);
}

- (void)fade:(NSImage*)image {
    float i;

    [myOtherImageView setRotation:myRotation];
    //myRotation=0;
    for (i=1; i>0; i-=myIncrement) {
        [myCoveringWindow setAlphaValue:i];
    }
    [myOtherCoveringWindow makeKeyAndOrderFront:self];
    [myCoveringWindow setAlphaValue:1];
    swap(myCoveringWindow, myOtherCoveringWindow);
    swap(myImageView, myOtherImageView);
}

- (void)setImage:(NSImage*)image {
    [self performSelector:myTransition withObject:image];
}

#undef swap

@end
