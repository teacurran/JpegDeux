//
//  FileHierarchySupport.h
//  JPEGDeux 2
//
//  Created by peter on Tue Jul 09 2002.
//  This code is released under the Modified BSD license
//

#import <Cocoa/Cocoa.h>

@interface FileHierarchy : NSObject

//hierarchyWithPath is deep (recursive)
+ (id)hierarchyWithPath:(NSString*)path recursive:(BOOL)recursive;

//this one is shallow (self and contents)
+ (id)folderContentsWithPath:(NSString*)path;

+ (NSMutableArray*)flattenHierarchy:(id)hierarchy;

@end

@interface NSArray (FileHierarchySupport)

- (NSString*)filename;
- (NSMutableArray*)contents;
- (BOOL)isFolder;

- (id)alias;
- (id)unalias;
- (BOOL)isAliased;

@end

@interface NSMutableArray (FileHierarchySupport)

- (void)setFilename:(NSString*)name;
- (void)setContents:(NSArray*)contents;
- (BOOL)removeHierarchy:(id)item;

@end

@interface NSString (FileHierarchySupport)

- (NSString*)filename;
- (BOOL)isFolder;
- (BOOL)removeHierarchy:(id)item;
- (id)alias;
- (BOOL)isAliased;

@end

@interface NSData (FlieHierarchySupport)

- (id)unalias;
- (BOOL)isAliased;

@end
