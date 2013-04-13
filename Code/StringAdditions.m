//
//  StringAdditions.m
//  JPEGDeux
//
//  Created by Peter on Wed Sep 07 2001.


#import "StringAdditions.h"
#import "MoreFilesX.h"

@implementation NSString (StringAdditions)

//returns a path to the file pointed at by self if self is an alias, self otherwise
//yes, we do follow chains of aliases
//returns nil if self cannot be resolved.  Does not attempt to mount volumes.
//if isDir is not nil, returns whether or not the resolved file is a directory
- (NSString*)resolveAliasesIsDir:(BOOL*)pIsDir {
    Boolean isDir, wasAlias;
    FSRef ref;
    OSStatus result;
    result=FSPathMakeRef((UInt8 *)[self UTF8String], &ref, &isDir);
    if (result != noErr) return nil;
    if (isDir) {
        if (pIsDir) *pIsDir=YES;
        return self;
    }
    result=FSResolveAliasFileWithMountFlags(&ref, YES, &isDir, &wasAlias, kARMNoUI | kARMSearch);
    if (pIsDir) *pIsDir=isDir;
    if (result != noErr) return nil;
    if (wasAlias) {
        unsigned char pathBuff[512];
        result=FSRefMakePath(&ref, pathBuff, sizeof pathBuff);
        if (result != noErr) return nil;
        return [NSString stringWithCString:(const char *)pathBuff];
    }
    return self;
}

- (BOOL)makeFSSpec:(FSSpec*)spec {
    OSErr err;
    FSRef ref;
    err=FSPathMakeRef((UInt8 *)[self UTF8String], &ref, 0);
    if (! err) err=FSRefMakeFSSpec(&ref, spec);
    return err==noErr;
}

- (NSString*)commonSuffixWithString:(NSString*)s {
    int a=[self length]-1;
    int b=[s length]-1;
    if (a < 0 || b < 0) return @"";
    while ([self characterAtIndex:a]==[s characterAtIndex:b] && a > 0 && b > 0) {
        a--;
        b--;
    }
    if (a==[self length]-1) return @"";
    else return [self substringFromIndex:a+1];
}

@end

