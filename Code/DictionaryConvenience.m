//
//  DictionaryConvenience.m
//  JPEGDeux 2
//
//  Created by peter on Mon Jul 08 2002.
//  This code is released under the Modified BSD license
//

#import "DictionaryConvenience.h"


@implementation NSMutableDictionary (DictionaryConvenience)

- (void)setBool:(BOOL)v forKey:(id)key {
    [self setObject:[NSNumber numberWithBool:v] forKey:key]; 
}

- (void)setInt:(int)v forKey:(id)key {
    [self setObject:[NSNumber numberWithInt:v] forKey:key]; 
}

- (void)setFloat:(float)v forKey:(id)key {
    [self setObject:[NSNumber numberWithFloat:v] forKey:key];
}

@end

@implementation NSDictionary (DictionaryConvenience)

- (BOOL)boolForKey:(id)key {
    return [[self objectForKey:key] boolValue]; 
}

- (int)intForKey:(id)key {
    return [[self objectForKey:key] intValue];
}

- (float)floatForKey:(id)key {
    return [[self objectForKey:key] floatValue];
}

@end