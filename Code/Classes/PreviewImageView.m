//
//  PreviewImageView.m
//  JPEGDeux 2
//
//  Created by peter on Thu Jul 11 2002.
//  This code is released under the Modified BSD license
//

#import "PreviewImageView.h"

@implementation PreviewImageView

- (void)setColor:(NSColor*)color {
    [super setColor:color];
    if ([self canDraw]) {
        NSRect rect=[self bounds];
        NSRect imageRect={NSMakePoint(0, 0), [myImage size]};

        //let's try to change the color without having to rerender the image
        [self lockFocus];
        [myBackgroundColor set];
        if (! myImage) {
            NSRectFill(rect);
        }
        else {
            switch (myScaling) {
                case ScaleDownToFit:
                    if (!(NSHeight(imageRect) < NSHeight(rect) || NSWidth(imageRect) < NSWidth(rect)))
                        goto LabelScaleNone;
                    //note the fall through
                case NSScaleToFit:
                    break;

                    LabelScaleNone:
                case NSScaleNone: {
                    float xSpace=(NSWidth(rect) - NSWidth(imageRect))/2.0;
                    float ySpace=(NSHeight(rect) - NSHeight(imageRect))/2.0;
                    if (xSpace < 0 && ySpace >= 0) { //space on bottom and top, not sides
                        NSRectFill(NSMakeRect(0, 0, NSWidth(rect), ySpace));
                        NSRectFill(NSMakeRect(0, NSHeight(rect)-ySpace, NSWidth(rect), ySpace));
                    }
                    else if (xSpace >= 0 && ySpace < 0) { //space on sides, not bottom and top
                        NSRectFill(NSMakeRect(0, 0, xSpace, NSHeight(rect)));
                        NSRectFill(NSMakeRect(NSWidth(rect)-xSpace, 0, xSpace, NSHeight(rect)));
                    }
                    else if (xSpace > 0 && ySpace > 0) { //image is too small all around
                        NSRectFill(NSMakeRect(0, 0, NSWidth(rect), ySpace+1)); //bottom, we add 1 because of ugly round off otherwise
                        NSRectFill(NSMakeRect(0, NSHeight(rect)-ySpace, NSWidth(rect), ySpace)); //top
                        NSRectFill(NSMakeRect(0, ySpace, xSpace+1, .5f+NSHeight(rect)-2.0f*ySpace)); //left
                        NSRectFill(NSMakeRect(NSWidth(rect)-xSpace, ySpace, xSpace, .5f+NSHeight(rect)-2.0f*ySpace)); //right
                    }
                    break;
                }
                case ScaleDownProportionally:
                    if (NSHeight(imageRect) < NSHeight(rect) && NSWidth(imageRect) < NSWidth(rect)) goto LabelScaleNone;
                    //note the fall through
                case NSScaleProportionally:
                    if (NSHeight(imageRect)*NSWidth(rect) > NSHeight(rect)*NSWidth(imageRect)) {
                        //image is tall
                        float scalingFactor=NSHeight(rect)/NSHeight(imageRect);
                        NSRect drawingRect=NSInsetRect(rect, (NSWidth(rect)-NSWidth(imageRect)*scalingFactor)/2.0, 0);
                        NSRectFill(NSMakeRect(0, 0, NSMinX(drawingRect), NSHeight(rect)));
                        NSRectFill(NSMakeRect(NSMaxX(drawingRect), 0, NSMaxX(rect)-NSMaxX(drawingRect), NSHeight(rect)));
                    }
                    else {
                        //image is wide
                        NSRect drawingRect;
                        float scalingFactor=NSWidth(rect)/NSWidth(imageRect);
                        drawingRect=NSInsetRect(rect, 0, (NSHeight(rect)-NSHeight(imageRect)*scalingFactor)/2.0);
                        NSRectFill(NSMakeRect(0, NSMaxY(drawingRect), NSWidth(rect), NSMaxY(rect)-NSMaxY(drawingRect)));
                        NSRectFill(NSMakeRect(0, 0, NSWidth(rect), NSMinY(drawingRect)));
                    }
                    break;
                default: ; //this ought to shut gcc up
            }
        }
        [self unlockFocus];
        [[self window] flushWindow];
    }
}

@end
