//
//  QuicktimeShow.h
//  JPEGDeux 2
//
//  Created by peter on Sat Jun 29 2002.
//  This code is released under the Modified BSD license
//

#import <Cocoa/Cocoa.h>
#import "SlideShow.h"
#import <QuickTime/QuickTime.h>



@interface QuicktimeShow : SlideShow {
    GWorldPtr myGWorld;
    GraphicsImportComponent myImporter;
    GraphicsImportComponent* myPreloadedImporters;
    GraphicsImportComponent myLastImporter;

    int myBlackLeft, myBlackTop, myBlackRight, myBlackBottom;
    int myAscent, myDescent;
    int myQuality;
    int myOldNameWidth;
    int myHFlipped;
    int myVFlipped;
    NSString* myImageName;
}

- (void)preload;

- (Rect)getDisplayRectForRect:(Rect)rect;

- (void)setQuality:(int)quality;

@end
