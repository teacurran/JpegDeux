//
//  MutableArrayCategory.m
//  JPEGDeux
//
//  Created by Peter on Wed Sep 05 2001.

#import <Cocoa/Cocoa.h>

void shuffle(void** ptr, int count);

@interface NSMutableArray (MutableArrayCategory)

//appends array to self except when the object is already in the array as determined by isEqual:
- (void)mergeWithArray:(NSArray*)array;

//randomizes the array
- (void)shuffle;

- (id)deepMutableCopy;

- (void)reverse;

@end
