//
//  QuicktimeShow.h
//  JPEGDeux 2
//
//  Created by peter on Sat Jun 29 2002.
//  This code is released under the Modified BSD license
//

#import <Cocoa/Cocoa.h>
//#import "QuicktimeShow.h"
#import <QuickTime/QuickTime.h>

//FullScreenQuickTimeShow
@interface FSQTShow : QuicktimeShow {
    int myScreenHeight, myScreenWidth;
    int myBytesPerPixel;
    int myDisplayBits;

    CGDirectDisplayID myDisplayID;
}

@end
