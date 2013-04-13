//
//  FixedBitmapImageRep.h
//  JPEGDeux
//
//  Created by peter on Thu Jan 24 2002.
//  This code is released under the Modified BSD license
//

#import <Cocoa/Cocoa.h>

//We kludge - (NSSize)size to prevent images from displaying smaller than they actually are
//Seems to work...for now

@interface FixedBitmapImageRep : NSBitmapImageRep

@end
