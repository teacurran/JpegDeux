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
        long i, max=[contents count];
        for (i=0; i<max; i++) {
            flattenHierarchy([contents objectAtIndex:i], array);
        }
    }
}

@implementation FileHierarchy

//could possibly rewrite using subpathsAtPath?
+ (id)hierarchyWithPath:(NSString*)path recursive:(BOOL)recursive {
    id result=nil;
    NSFileManager* filer=[NSFileManager defaultManager];
    BOOL isDir;
    path=[path resolveAliasesIsDir:&isDir];
    if (path != nil) {
        if (isDir) {
			NSError *error = nil;
			NSArray* dirContents = [filer contentsOfDirectoryAtPath:path error:&error];
			
            long i, max=[dirContents count];
            NSMutableArray* hierarchyContents=[NSMutableArray arrayWithCapacity:max];
            result=[NSMutableArray arrayWithCapacity:2];
            [result setFilename:path];
            for (i=0; i<max; i++) {
                NSString* fileName=[dirContents objectAtIndex:i];
                NSString* filePath=[path stringByAppendingPathComponent:fileName];
                BOOL fileIsDir;
                filePath = [filePath resolveAliasesIsDir:&fileIsDir];
                
                id innerHierarchy;
                if (fileIsDir && recursive) {
                    innerHierarchy = [self hierarchyWithPath:filePath recursive:recursive];
                    // only add the inner directory if it has files in it
                    if (innerHierarchy) {
                        NSMutableArray* innerDirectory = (NSMutableArray*)innerHierarchy;
                        if ([innerDirectory count] == 2) {
                            if ([(NSMutableArray*)innerDirectory[1] count] > 0) {
                                [hierarchyContents addObject:innerHierarchy];
                            }
                        }
                    }
                    
                } else if (!fileIsDir) {
                    innerHierarchy = [self hierarchyWithPath:filePath recursive:recursive];

                    if (innerHierarchy) {
                        [hierarchyContents addObject:innerHierarchy];
                    }
                }
            }
            
            [result setContents:hierarchyContents];
        } else {
            result=[path resolveAliasesIsDir:nil];
            CFStringRef fileExtension = (__bridge CFStringRef)[result pathExtension];
            CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);

            if (!UTTypeConformsTo(fileUTI, kUTTypeImage)) {
                result=nil;
            }
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
    long i, max=[oldContents count];
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
    long i, max=[oldContents count];
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
    long i, max=[contents count];
    for (i=0; i<max; i++) {
        id hierarchy=[contents objectAtIndex:i];
        if ([hierarchy isEqual:item]) {
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
