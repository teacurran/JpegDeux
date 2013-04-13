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
        myBackgroundColor=[[NSColor blackColor] retain];
        myScaling=NSScaleNone;
        myNameAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:
            [NSColor whiteColor], NSForegroundColorAttributeName,
            [NSColor blackColor], NSBackgroundColorAttributeName,
            nil];
    }
    return self;
}

-(void)dealloc {
    [myBackgroundColor release];
    [myImageName release];
    [myNameAttributes release];
    [super dealloc];
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
    [myImageName release];
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
        NSSize size=[myImageName sizeWithAttributes:myNameAttributes];
        NSPoint drawPoint=NSMakePoint(NSMaxX(rect)-size.width, 0);
        [myImageName drawAtPoint:drawPoint withAttributes:myNameAttributes];
    }
}

- (void)drawRect:(NSRect)rect {
    CGContextRef context=[[NSGraphicsContext currentContext] graphicsPort];
    NSRect drawingRect;
    NSRect fillRects[4];
    unsigned numFillRects;
    const int numRots=((int)rint(myRotation / M_PI_2)) & 3;
    NSSize imageSize=[myImage size];
    NSRect origImgRect={NSMakePoint(0,0), imageSize};
    NSRect rotImgRect={NSMakePoint(0,0), (numRots & 1) ? rotateSize(imageSize) : imageSize };
    [myBackgroundColor set];
    if (! myImage) {
        NSRectFill(rect);
        return;
    }
    CGContextTranslateCTM(context, NSWidth(rect)/2, NSHeight(rect)/2);
    switch ((myHFlipped << 1) + myVFlipped) {
        case 1: CGContextScaleCTM(context, 1, -1); break;
        case 2: CGContextScaleCTM(context, -1, 1); break;
        case 3: CGContextScaleCTM(context, -1, -1); break;
    }
    if (numRots) CGContextRotateCTM(context, myRotation);
    CGContextTranslateCTM(context, -NSWidth(rect)/2, -NSHeight(rect)/2);
    switch (myScaling) {
        case ScaleDownToFit:
            if (!(NSHeight(rotImgRect) < NSHeight(rect) || NSWidth(rotImgRect) < NSWidth(rect))) goto LabelScaleNone;
            //note the fall through
        case NSScaleToFit:
            drawingRect=scaleToFit(rect, imageSize, fillRects, &numFillRects, numRots);
            break;

            LabelScaleNone:
        case NSScaleNone:
            drawingRect=scaleNone(rect, imageSize, fillRects, &numFillRects, numRots);
            break;
        case ScaleDownProportionally:
            if (NSHeight(rotImgRect) < NSHeight(rect) && NSWidth(rotImgRect) < NSWidth(rect)) goto LabelScaleNone;
            //note the fall through
        case NSScaleProportionally:
            drawingRect=scaleProportional(rect, imageSize, fillRects, &numFillRects, numRots);
            break;
        default: ; //this ought to shut gcc up
    }
    switch (numFillRects) {
        case 1: NSRectFill(fillRects[0]); break;
        default: NSRectFillList(fillRects, numFillRects);
        case 0: ;
    }
    [myImage drawInRect:drawingRect fromRect:origImgRect operation:NSCompositeCopy fraction:1.0];
    if (myImageName) [self drawImageName:rect];
}

//my custom NSImageView since the standard one doesn't seem to always scale the image properly
- (void)drawRectOld:(NSRect)rect {
    CGContextRef context=[[NSGraphicsContext currentContext] graphicsPort];
    NSRect drawingRect;
    const int numRots=((int)rint(myRotation / M_PI_2)) & 3;
    NSSize imageSize=[myImage size];
    NSRect origImgRect={NSMakePoint(0,0), imageSize};
    NSRect rotImgRect={NSMakePoint(0,0), (numRots & 1) ? rotateSize(imageSize) : imageSize };
    [myBackgroundColor set];
    if (! myImage) {
        NSRectFill(rect);
        return;
    }
    CGContextTranslateCTM(context, NSWidth(rect)/2, NSHeight(rect)/2);
    switch ((myHFlipped << 1) + myVFlipped) {
        case 1: CGContextScaleCTM(context, 1, -1); break;
        case 2: CGContextScaleCTM(context, -1, 1); break;
        case 3: CGContextScaleCTM(context, -1, -1); break;
    }
    if (numRots) {
        CGContextRotateCTM(context, myRotation);
    }
    CGContextTranslateCTM(context, -NSWidth(rect)/2, -NSHeight(rect)/2);
    switch (myScaling) {

        case ScaleDownToFit:
            if (!(NSHeight(rotImgRect) < NSHeight(rect) || NSWidth(rotImgRect) < NSWidth(rect))) goto LabelScaleNone;
            //note the fall through
        case NSScaleToFit:
            drawingRect=rect;
            //if (numRots & 1) drawingRect.size=rotateSize(drawingRect.size);
            break;

            LabelScaleNone:
        case NSScaleNone: {
//            NSRect rotRect={ NSMakePoint(0, 0), (numRots & 1) ? rotateSize(rect.size) : rect.size};
            if (numRots & 1) rotateSize(rect.size);
            float xSpace=(NSWidth(rect) - NSWidth(rotImgRect))/2.0;
            float ySpace=(NSHeight(rect) - NSHeight(rotImgRect))/2.0;
            /*if (numRots & 1) {
                xSpace = (NSWidth(rotRect) - NSWidth(rotImgRect))/2.;
            ySpace = (NSHeight(rotRect) - NSHeight(rotImgRect))/2.;
            }
            else {
                xSpace=(NSWidth(rect) - NSWidth(rotImgRect))/2.0;
                ySpace=(NSHeight(rect) - NSHeight(rotImgRect))/2.0;
            }*/
            NSLog(@"XSpace: %f YSpace: %f NumRots: %d", xSpace, ySpace, numRots);

            if (xSpace < 0 && ySpace >= 0) { //space on bottom and top, not sides
                                             //NSRectFill(NSMakeRect(0, 0, NSWidth(rect), ySpace));
                                             //NSRectFill(NSMakeRect(0, NSHeight(rect)-ySpace, NSWidth(rect), ySpace));
            }
            else if (xSpace >= 0 && ySpace < 0) { //space on sides, not bottom and top
                                                  //NSRectFill(NSMakeRect(0, 0, xSpace, NSHeight(rect)));
                                                  //NSRectFill(NSMakeRect(NSWidth(rect)-xSpace, 0, xSpace, NSHeight(rect)));
            }
            else if (xSpace > 0 && ySpace > 0) { //image is too small all around
                NSRectFill(NSMakeRect(NSHeight(origImgRect) - NSHeight(rotImgRect), 0, NSWidth(rect), ySpace+1)); //bottom, we add 1 because of ugly round off otherwise
                                                                                                                  //NSRectFill(NSMakeRect(0, NSHeight(rect)-ySpace, NSWidth(rect), ySpace)); //top
                                                                                                                  //NSRectFill(NSMakeRect(0, ySpace, xSpace+1, .5f+NSHeight(rect)-2.0f*ySpace)); //left
                                                                                                                  //NSRectFill(NSMakeRect(NSWidth(rect)-xSpace, ySpace, xSpace, .5f+NSHeight(rect)-2.0f*ySpace)); //right
            }


            /*
             * Here we short-circuit by using compositeToPoint instead of drawInRect:
             * I'm not sure which is faster, but this one is sure easier to program
             * Plus there seems to be a severe bug (which I think is due to Apple) in the version above!
             */
            //[myImage compositeToPoint:NSMakePoint(xSpace, ySpace) operation:NSCompositeCopy];
            //if (myImageName) [self drawImageName:rect];
            //return;
            drawingRect=rotImgRect;
            drawingRect.origin.x = (NSWidth(rect) - NSWidth(rotImgRect))/2;
            drawingRect.origin.y = (NSHeight(rect) - NSHeight(rotImgRect))/2;
            break;
        }
        case ScaleDownProportionally:
            if (NSHeight(rotImgRect) < NSHeight(rect) && NSWidth(rotImgRect) < NSWidth(rect)) goto LabelScaleNone;
            //note the fall through
        case NSScaleProportionally:
            if (NSHeight(rotImgRect)*NSWidth(rect) > NSHeight(rect)*NSWidth(rotImgRect)) {
                //image is tall
                float scalingFactor=NSHeight(rect)/NSHeight(rotImgRect);
                drawingRect=NSInsetRect(rect, (NSWidth(rect)-NSWidth(rotImgRect)*scalingFactor)/2.0, 0);
                NSRectFill(NSMakeRect(0, 0, NSMinX(drawingRect), NSHeight(rect)));
                NSRectFill(NSMakeRect(NSMaxX(drawingRect), 0, NSMaxX(rect)-NSMaxX(drawingRect), NSHeight(rect)));
            }
            else {
                //image is wide
                float scalingFactor=NSWidth(rect)/NSWidth(rotImgRect);
                drawingRect=NSInsetRect(rect, 0, (NSHeight(rect)-NSHeight(rotImgRect)*scalingFactor)/2.0);
                NSRectFill(NSMakeRect(0, NSMaxY(drawingRect), NSWidth(rect), NSMaxY(rect)-NSMaxY(drawingRect)));
                NSRectFill(NSMakeRect(0, 0, NSWidth(rect), NSMinY(drawingRect)));
            }
            break;
        default: ; //this ought to shut gcc up
    }
    if (numRots & 1) {
        drawingRect.size.height *= NSWidth(rect) / NSHeight(rect);
        drawingRect.size.width *= NSHeight(rect) / NSWidth(rect);
        drawingRect.origin.x = (NSWidth(rect) - NSWidth(drawingRect))/2.;
        drawingRect.origin.y = (NSHeight(rect) - NSHeight(drawingRect))/2.;
    }
    [myImage drawInRect:drawingRect fromRect:origImgRect operation:NSCompositeCopy fraction:1.0];
    if (myImageName) [self drawImageName:rect];
}


- (void)setColor:(NSColor*)color {
    [myBackgroundColor autorelease];
    myBackgroundColor=[color retain];
    [myNameAttributes release];
    myNameAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:
        [NSColor whiteColor], NSForegroundColorAttributeName,
        myBackgroundColor, NSBackgroundColorAttributeName,
        nil];
}

- (NSColor*)getColor {
    return myBackgroundColor;
}

- (void)setImage:(NSImage*)image {
    [myImage release];
    myImage=[image retain];
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
