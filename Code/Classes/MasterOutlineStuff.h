//
//  MasterOutlineStuff.h
//  JPEGDeux 2
//
//  Created by peter on Tue Jul 09 2002.
//  This code is released under the Modified BSD license
//

#import <Cocoa/Cocoa.h>
#import "Master.h"

@interface Master (MasterOutlineStuff)

- (BOOL)removeHierarchy:(id)item;
- (void)redoPreviewImageName;

@end
