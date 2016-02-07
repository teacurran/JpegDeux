//
//  BackgroundImageView.m
//  JPEGDeux
//
//  Created by Peter on Wed Sep 05 2001.

#import "BackgroundImageView.h"
#import "Procedural.h"
#import "Scaling.h"

@implementation BackgroundImageView

- (id)initWithFrame:(NSRect)frame {
    if (self=[super initWithFrame:frame]) {
        myBackgroundColor=[NSColor blackColor];
        myScaling=NSScaleNone;
        myNameAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:
            [NSColor whiteColor], NSForegroundColorAttributeName,
            [NSColor blackColor], NSBackgroundColorAttributeName,
            nil];
		
		imageView = [[NSImageView alloc] initWithFrame:frame];
		[self addSubview:imageView];
		
    }
    return self;
}

- (void)setRotation:(float)r {
    myRotation=r;
}

- (void)flipHorizontal {
    myHFlipped=!myHFlipped;
}

- (void)flipVertical {
    myVFlipped=!myVFlipped;
}

- (void)setImageName:(NSString*)name {
    myImageName=[name copy];
	
}

- (NSSize)scaledSizeForSize:(NSSize)size {
    NSSize mySize=[self bounds].size;
    int numRots=(int)rint(myRotation / M_PI_2);
    if (numRots & 1) mySize=rotateSize(size);
    switch (myScaling) {
        case ScaleDownToFit:
            if (size.height < mySize.height && size.width < mySize.width) return size;
            //note fall through
        case NSScaleToFit: return mySize;

        case NSScaleNone: return size;

        case ScaleDownProportionally:
            if (size.height < mySize.height && size.width < mySize.width) return size;
            //note fall through
        case NSScaleProportionally:
            if (size.height*mySize.width > size.width * mySize.height) {
                //image is too tall
                size.width*=mySize.height/size.height;
                size.height=mySize.height;
            }
            else {
                //image is too wide
                size.height*=mySize.width/size.width;
                size.width=mySize.width;
            }
            //note fall through
        default: //this should shut gcc up
            return size;
    }
}


- (void)drawImageName:(NSRect)rect {
    if (myImageName) {
        NSSize size=[myImageName sizeWithAttributes:NULL];
		
		NSRect imageLabelRect = NSMakeRect(0, 0, NSMaxX(rect), size.height);
		
		if (myImageLabel) {
			[myImageLabel removeFromSuperview];
		}
		
		myImageLabel = [[NSTextField alloc] initWithFrame:imageLabelRect];
		[myImageLabel setStringValue:myImageName];
		[myImageLabel setBezeled:NO];
		[myImageLabel setDrawsBackground:NO];
		[myImageLabel setEditable:NO];
		[myImageLabel setSelectable:NO];
		[myImageLabel setTextColor:[NSColor whiteColor]];
		
		[self addSubview:myImageLabel];

    }
}

- (void)setColor:(NSColor*)color {
    myBackgroundColor=color;
    myNameAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:
        [NSColor whiteColor], NSForegroundColorAttributeName,
        myBackgroundColor, NSBackgroundColorAttributeName,
        nil];
}

- (NSColor*)getColor {
    return myBackgroundColor;
}

- (void)drawRect:(NSRect)rect {
	[super drawRect:rect];
	
	if (myImageName) {
		[self drawImageName:rect];
	}
}

- (void)setImage:(NSImage*)image {

    myImage=image;
	
	[imageView setImage:myImage];
	
    [self display];
}

- (NSImage*)image {
    return myImage;
}

- (void)setImageScaling:(BetterImageScaling)scaling {
    myScaling=scaling;
}

- (BetterImageScaling)imageScaling {
    return myScaling;
}

@end
