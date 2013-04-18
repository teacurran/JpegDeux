//
//  FileHierarchySupport.m
//  JPEGDeux 2
//
//  Created by peter on Tue Jul 09 2002.
//  This code is released under the Modified BSD license
//

#import "FileHierarchySupport.h"
#import "StringAdditions.h"
#import "DataAlias.h"

static void flattenHierarchy(id hierarchy, NSMutableArray* array) {
    if (! [hierarchy isFolder]) [array addObject:hierarchy];
    else {
        NSArray* contents = [hierarchy contents];
        unsigned i, max=[contents count];
        for (i=0; i<max; i++) {
            flattenHierarchy([contents objectAtIndex:i], array);
        }
    }
}

@implementation FileHierarchy

//could possibly rewrite using subpathsAtPath?
+ (id)hierarchyWithPath:(NSString*)path {
    id result=nil;
    NSFileManager* filer=[NSFileManager defaultManager];
    BOOL isDir;
    path=[path resolveAliasesIsDir:&isDir];
    if (path != nil) {
        if (isDir) {
			
			NSError *error = nil;
			NSArray* dirContents = [filer contentsOfDirectoryAtPath:path error:&error];
			
            unsigned i, max=[dirContents count];
            NSMutableArray* hierarchyContents=[NSMutableArray arrayWithCapacity:max];
            result=[NSMutableArray arrayWithCapacity:2];
            [result setFilename:path];
            for (i=0; i<max; i++) {
                NSString* dirPath=[dirContents objectAtIndex:i];
                dirPath=[path stringByAppendingPathComponent:dirPath];
                id innerHierarchy=[self hierarchyWithPath:dirPath];
                if (innerHierarchy) {
					[hierarchyContents addObject:innerHierarchy];
				}
            }
            [result setContents:hierarchyContents];
        }
        else {
            result=[path resolveAliasesIsDir:nil];
            if ([[result lastPathComponent] characterAtIndex:0]=='.') result=nil;
        } 
    }
    return result;
}

+ (id)folderContentsWithPath:(NSString*)path {
    id result=nil;
    NSFileManager* filer=[NSFileManager defaultManager];
    BOOL isDir;
    path=[path resolveAliasesIsDir:&isDir];
    if (path != nil) {
        if (isDir) {
            NSArray* dirContents=[filer directoryContentsAtPath:path];
            unsigned i, max=[dirContents count];
            NSMutableArray* hierarchyContents=[NSMutableArray arrayWithCapacity:max];
            result=[NSMutableArray arrayWithCapacity:2];
            [result setFilename:path];
            for (i=0; i<max; i++) {
                BOOL innerIsDir;
                NSString* dirPath=[dirContents objectAtIndex:i];
                dirPath=[path stringByAppendingPathComponent:dirPath];
                dirPath=[dirPath resolveAliasesIsDir:&innerIsDir];
                if (! innerIsDir && [[dirPath lastPathComponent] characterAtIndex:0]!='.')
                    [hierarchyContents addObject:dirPath];
            }
            [result setContents:hierarchyContents];
        }
        else {
            result=path;
            if ([[result lastPathComponent] characterAtIndex:0]=='.') result=nil;
        }
    }
    return result;
}

+ (NSMutableArray*)flattenHierarchy:(id)hierarchy {
    NSMutableArray* arr=[NSMutableArray array];
    flattenHierarchy(hierarchy, arr);
    return arr;
}

@end

@implementation NSArray (FileHierarchySupport)

- (NSString*)filename {
    return [self objectAtIndex:0];
}

- (NSMutableArray*)contents {
    return [self objectAtIndex:1];
}

- (BOOL)isFolder {
    return YES;
}

- (id)alias {
    NSArray* oldContents=[self contents];
    unsigned i, max=[oldContents count];
    NSData* path;
    NSMutableArray* contents=[NSMutableArray arrayWithCapacity:max];
    path=[[self filename] alias];
    for (i=0; i<max; i++) {
        [contents addObject:[[oldContents objectAtIndex:i] alias]];
    }
    return [NSMutableArray arrayWithObjects:path, contents, nil];
}

- (id)unalias {
    NSArray* oldContents=[self contents];
    unsigned i, max=[oldContents count];
    NSString* path;
    NSMutableArray* contents=[NSMutableArray arrayWithCapacity:max];
    path=[[self objectAtIndex:0] unalias];
    for (i=0; i<max; i++) {
        [contents addObject:[[oldContents objectAtIndex:i] unalias]];
    }
    return [NSMutableArray arrayWithObjects:path, contents, nil];
}

- (BOOL)isAliased {
    return [[self objectAtIndex:0] isAliased];
}

@end

@implementation NSMutableArray (FileHierarchySupport)

- (void)setFilename:(NSString*)name {
    if ([self count] > 0) [self replaceObjectAtIndex:0 withObject:name];
    else [self addObject:name];
}

- (void)setContents:(NSArray*)contents {
    if ([self count] == 0) NSLog(@"Bad setContents call, before filename");
    else if ([self count] == 1) [self addObject:[NSMutableArray arrayWithArray:contents]];
    else [self replaceObjectAtIndex:1 withObject:[NSMutableArray arrayWithArray:contents]];
}

- (BOOL)removeHierarchy:(id)item {
    NSMutableArray* contents=[self contents];
    unsigned i, max=[contents count];
    for (i=0; i<max; i++) {
        id hierarchy=[contents objectAtIndex:i];
        if ([hierarchy isEqual:item]) {
            [[[contents objectAtIndex:i] retain] autorelease];
            [contents removeObjectAtIndex:i];
            return YES;
        }
        else if ([hierarchy removeHierarchy:item]) return YES;
    }
    return NO;
}

@end

@implementation NSString (FileHierarchySupport)

- (NSString*)filename {
    return self;
}

- (BOOL)isFolder {
    return NO;
}

- (BOOL)removeHierarchy:(id)item {
    return NO;
}

- (id)alias {
    if ([self hasPrefix:@"http://"]) return self;
    else return [NSData aliasForPath:self];
}

- (BOOL)isAliased {
    return NO;
}

@end

@implementation NSData (FlieHierarchySupport)

- (id)unalias {
    return [self pathForAlias];
}

- (BOOL)isAliased {
    return YES;
}

@end