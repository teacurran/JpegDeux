//
//  MutableArrayCategory.m
//  JPEGDeux
//
//  Created by Peter on Wed Sep 05 2001.

#import "MutableArrayCategory.h"

@implementation NSArray (ArrayCategory)

- (NSArray*)shuffledArray {
    NSArray* finalArray;
    long i, count=[self count];
    id* buff=malloc(count*sizeof(id));
    if (!buff) return nil;
    [self getObjects:buff];
    for (i=count-1; i > 0; i--) {
        long newPos=(arc4random()%i);
        id temp=buff[i];
        buff[i]=buff[newPos];
        buff[newPos]=temp;
    }
    finalArray=[NSArray arrayWithObjects:buff count:count];
    free(buff);
    return finalArray;
}

@end

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
    long i, count=[self count];
    for (i=count-1; i > 0; i--) {
        long newPos=(arc4random()%i);
        id temp=[[self objectAtIndex:i] retain];
        [self replaceObjectAtIndex:i withObject:[self objectAtIndex:newPos]];
        [self replaceObjectAtIndex:newPos withObject:temp];
        [temp release];
    }
}

- (id)deepMutableCopy {
    NSMutableArray* arr=[[NSMutableArray alloc] initWithCapacity:[self count]];
    long i, max=[self count];
    for (i=0; i < max; i++) {
        id object=[self objectAtIndex:i];
        if ([object respondsToSelector:_cmd]) [arr addObject:[[object deepMutableCopy] autorelease]];
        else [arr addObject:[[object copy] autorelease]];
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
