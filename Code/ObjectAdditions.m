//
//  ObjectAdditions.h
//  Charla
//
//  Created by Peter Ammon on Fri 8/31/01.
//  This code is released under the Modified BSD license
//

#import "ObjectAdditions.h"

typedef int(*intFuncNone)(id, SEL);
typedef int(*intFuncOne)(id, SEL, id);
typedef int(*intFuncTwo)(id, SEL, id, id);


@implementation NSObject (ObjectAdditions)

- (int)intPerformSelector:(SEL)selector {
    intFuncNone func=(intFuncNone)[self methodForSelector:selector];
    return func(self, selector);
}


- (int)intPerformSelector:(SEL)selector withObject:(id)anObject {
    intFuncOne func=(intFuncOne)[self methodForSelector:selector];
    return func(self, selector, anObject);
}

- (int)intPerformSelector:(SEL)selector withObject:(id)anObject withObject:(id)moObject {
    intFuncTwo func=(intFuncTwo)[self methodForSelector:selector];
    return func(self, selector, anObject, moObject);
}

+ (BOOL)inheritsFromClass:(Class)c {
    do {
        if (self == c) return YES;
    } while (self=[self superclass]);
    return NO;
}

@end

