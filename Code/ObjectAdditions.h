//
//  ObjectAdditions.h
//  Charla
//
//  Created by Peter Ammon on Fri 8/31/01.
//  This code is released under the Modified BSD license
//

#import <Foundation/Foundation.h>

@interface NSObject (ObjectAdditions)

/* A triplet of functions that imitate performSelector: for selectors returning int */

- (int)intPerformSelector:(SEL)selector;
- (int)intPerformSelector:(SEL)selector withObject:(id)anObject;
- (int)intPerformSelector:(SEL)selector withObject:(id)anObject withObject:(id)moObject;

@end