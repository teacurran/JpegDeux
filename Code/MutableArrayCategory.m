//
//  MutableArrayCategory.m
//  JPEGDeux
//
//  Created by Peter on Wed Sep 05 2001.

#import "MutableArrayCategory.h"

@implementation NSMutableArray (MutableArrayCategory)

- (void)mergeWithArray:(NSArray*)array {
    long i, max=[array count];
    NSRange searchRange=NSMakeRange(0, [self count]);
    for (i=0; i<max; i++) {
        id object=[array objectAtIndex:i];
        long index=[self indexOfObject:object inRange:searchRange];
        if (index==NSNotFound) [self addObject:object];
    }
}

- (void)shuffle {
    NSUInteger count = [self count];
    if (count < 1) return;
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

- (id)deepMutableCopy {
    NSMutableArray* arr=[[NSMutableArray alloc] initWithCapacity:[self count]];
    long i, max=[self count];
    for (i=0; i < max; i++) {
        id object=[self objectAtIndex:i];
        if ([object respondsToSelector:_cmd]) {
            [arr addObject:[object deepMutableCopy]];
        } else {
            [arr addObject:[object copy]];
        }
    }
    return arr;
}

- (void)reverse {
    long i=0, j=[self count];
    while (i < j) {
        [self exchangeObjectAtIndex:i++ withObjectAtIndex:--j];
    }
}

@end

//we assume here that all pointers are the same size; safe on OS X but not in general

void shuffle(void** ptr, int count) {
    int i;
    for (i=count-1; i > 0; i--) {
        int newPos=(arc4random()%i);
        void* temp=ptr[i];
        ptr[i]=ptr[newPos];
        ptr[newPos]=temp;
    }
}
