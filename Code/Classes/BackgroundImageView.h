//
//  BackgroundImageView.h
//  JPEGDeux
//
//  Created by Peter on Wed Sep 05 2001.

// A non-broken (less broken?) NSImageView with a background color

#import <Cocoa/Cocoa.h>
#import "PetersTypes.h"

@interface BackgroundImageView : NSView {
    NSColor* myBackgroundColor;
    NSImage* myImage;
    BetterImageScaling myScaling;
    NSString* myImageName;
    NSDictionary* myNameAttributes;
    float myRotation;
    BOOL myHFlipped;
    BOOL myVFlipped;
}

- (void)setImageName:(NSString*)name;

- (void)setRotation:(float)r;

- (void)setColor:(NSColor*)color;
- (NSColor*)getColor;

- (void)setImage:(NSImage*)image;
- (NSImage*)image;

- (void)setImageScaling:(BetterImageScaling)scaling;
- (BetterImageScaling)imageScaling;

- (NSSize)scaledSizeForSize:(NSSize)size;

- (void)flipHorizontal;
- (void)flipVertical;

@end
