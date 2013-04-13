//
//  QuicktimeShow.m
//  JPEGDeux 2
//
//  Created by peter on Sat Jun 29 2002.
//  This code is released under the Modified BSD license
//

#import "FSQTShow.h"
#import "StringAdditions.h"

//#define DONTDISPLAY

@implementation FSQTShow

- (void)dealloc {
    if (CGDisplayIsCaptured(myDisplayID)) {
        CGDisplayRelease(myDisplayID);
    }
    [super dealloc];
}

- (Rect)getDisplayRectForRect:(Rect)imageRect {
    float imageWidth=imageRect.right-imageRect.left;
    float imageHeight=imageRect.bottom-imageRect.top;
    float hOffset=0, vOffset=0;
    //NSLog(@"gDRFR: %d %d %d %d", (int)imageRect.left, (int)imageRect.top, (int)imageRect.right, (int)imageRect.bottom);
    switch (myScaling) {
        case ScaleDownToFit:
            if (imageHeight < myScreenHeight && imageWidth < myScreenWidth) {
                imageRect.left+=(myScreenWidth-imageWidth)/2;
                imageRect.right+=(myScreenWidth-imageWidth)/2;
                imageRect.top+=(myScreenHeight-imageHeight)/2;
                imageRect.bottom+=(myScreenHeight-imageHeight)/2;
                return imageRect;
            }
            //note fall through
        case NSScaleToFit: {
            Rect finalRect;
            finalRect.top=0;
            finalRect.left=0;
            finalRect.right=myScreenWidth;
            finalRect.bottom=myScreenHeight;
            return finalRect;
        };

        case NSScaleNone: {
            imageRect.left+=(myScreenWidth-imageWidth)/2;
            imageRect.right+=(myScreenWidth-imageWidth)/2;
            imageRect.top+=(myScreenHeight-imageHeight)/2;
            imageRect.bottom+=(myScreenHeight-imageHeight)/2;
            return imageRect;
        }

        case ScaleDownProportionally:
            if (imageHeight < myScreenHeight && imageWidth < myScreenWidth) {
                imageRect.left+=(myScreenWidth-imageWidth)/2;
                imageRect.right+=(myScreenWidth-imageWidth)/2;
                imageRect.top+=(myScreenHeight-imageHeight)/2;
                imageRect.bottom+=(myScreenHeight-imageHeight)/2;
                return imageRect;
            }
            //note fall through
        case NSScaleProportionally:
            if (imageHeight*myScreenHeight > imageWidth * myScreenWidth) {
                //image is too tall
                imageWidth*=(float)myScreenHeight/(float)imageHeight;
                imageHeight=myScreenHeight;
                hOffset=(myScreenWidth-imageWidth)/2;
            }
            else {
                //image is too wide
                imageHeight*=(float)myScreenWidth/(float)imageWidth;
                imageWidth=myScreenWidth;
                vOffset=(myScreenHeight-imageHeight)/2;
            }
            //note fall through
        default: {
            imageRect.left=hOffset;
            imageRect.right=imageWidth+hOffset;
            imageRect.top=vOffset;
            imageRect.bottom=imageHeight+vOffset;
            return imageRect;
        }
    }
}

- (void)makeScreenWorld {
    int* base=CGDisplayBaseAddress(myDisplayID);
    int increment=(int*)CGDisplayAddressForPosition(myDisplayID, 0, 1)-base;
    QDErr err;
    Rect rect={ 0, 0, myScreenHeight, myScreenWidth };
    err=NewGWorldFromPtr(&myGWorld, k32ARGBPixelFormat, &rect, 0, 0, 0, (Ptr)base, 4*increment);
    if (err) printf("NewGWorldFromPtr err %d\n", err);
}

- (void)beginShow:(NSArray*)files {
    CGDisplayErr err;
    CGDisplayCount count=1;
    NSDictionary* dict;

    err=CGGetActiveDisplayList(1, &myDisplayID, &count);
    if (err != CGDisplayNoErr) {
        fprintf(stderr, "CG Display error %d", (int)err);
        exit(EXIT_FAILURE);
    }
    if (CGDisplayIsCaptured(myDisplayID)) {
        fprintf(stderr, "Main display is already captured!");
        exit(EXIT_FAILURE);
    }
#ifndef DONTDISPLAY
    err=CGDisplayCapture(myDisplayID);
#endif
    if (err != CGDisplayNoErr) {
        fprintf(stderr, "CG Display error %d", (int)err);
        exit(EXIT_FAILURE);
    }
    dict=(NSDictionary*)CGDisplayCurrentMode(myDisplayID);
    myScreenWidth=[[dict objectForKey:(NSString*)kCGDisplayWidth] intValue];
    myScreenHeight=[[dict objectForKey:(NSString*)kCGDisplayHeight] intValue];
    myBytesPerPixel=[[dict objectForKey:(NSString*)kCGDisplayBitsPerPixel] intValue]/CHAR_BIT;
    myDisplayBits=myBytesPerPixel*CHAR_BIT;
    NSAssert1(myDisplayBits==16 || myDisplayBits==32, @"Strange display bits %d", myDisplayBits);
    [self makeScreenWorld];
    //these are intentionally opposite
    myBlackLeft=myScreenWidth;
    myBlackTop=myScreenHeight;
    myBlackRight=0;
    myBlackBottom=0;
    [super beginShow:files];
}

+ (int)tagNumber {
    return 4;
}

@end
