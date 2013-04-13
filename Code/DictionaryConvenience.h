//
//  DictionaryConvenience.h
//  JPEGDeux 2
//
//  Created by peter on Mon Jul 08 2002.
//  This code is released under the Modified BSD license
//

#import <Cocoa/Cocoa.h>


@interface NSMutableDictionary (DictionaryConvenience)

- (void)setBool:(BOOL)v forKey:(id)key;
- (void)setInt:(int)v forKey:(id)key;
- (void)setFloat:(float)v forKey:(id)key;

@end

@interface NSDictionary (DictionaryConvenience)

- (BOOL)boolForKey:(id)key;
- (int)intForKey:(id)key;
- (float)floatForKey:(id)key;

@end