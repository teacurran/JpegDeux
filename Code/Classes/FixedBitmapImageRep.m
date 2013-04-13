//
//  FixedBitmapImageRep.m
//  JPEGDeux
//
//  Created by Peter on Thu Jan 24 2002.

#import "FixedBitmapImageRep.h"


@implementation FixedBitmapImageRep

- (NSSize)size {
    _size.width=_pixelsWide;
    _size.height=_pixelsHigh;
    return _size;
}

@end
