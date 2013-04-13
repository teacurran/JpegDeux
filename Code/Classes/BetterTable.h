//
//  BetterTable.m
//  JPEGDeux
//
//  Created by Peter on Wed Sep 05 2001.

#import <Cocoa/Cocoa.h>

@protocol BetterTableDelegate
- (void)deleteRowsFromOutline:(NSOutlineView*)outline;
@end

@interface BetterTable : NSOutlineView

- (void)keyDown:(NSEvent*)event;

@end
