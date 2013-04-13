//
//  DataAlias.h
//  JPEGDeux 2
//
//  Created by Peter Ammon on Sat Nov 23 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//alias wrapper for Cocoa
//done with categories for simple integration with plists

@interface NSData (DataAlias)

+ (NSData*)aliasForPath:(NSString*)path;
- (NSString*)pathForAlias;

@end
