#import "sorting.h"
#import "FileHierarchySupport.h"
#include <ctype.h>
#import <Carbon/Carbon.h>

static NSDate* dateForJan1904() {		// utility to return a singleton reference NSDate
    static NSDate* Jan1904 = nil;
    if (!Jan1904) {
        Jan1904 = [[NSDate dateWithString:@"1904-01-01 00:00:00 +0000"] retain];
    }
    return Jan1904;
}

static NSDate* convertUTCtoNSDate(UTCDateTime input) {
    NSDate* result = nil;
    union {
        UTCDateTime local;
        UInt64 shifted;
    } time;
    time.local = input;
    if (time.shifted) {
        result = [[[NSDate alloc] initWithTimeInterval:time.shifted/65536
                                             sinceDate:dateForJan1904()] autorelease];
    }
    return result;
}

static NSDate* loadModDate(NSString* path) {
    Boolean isDir;
    OSErr err;
    FSRef ref;
    NSDate* result=nil;
    FSCatalogInfo info;
    err=FSPathMakeRef((UInt8 *)[path fileSystemRepresentation], &ref, &isDir);
    if (err==noErr) {
        err=FSGetCatalogInfo(&ref, kFSCatInfoContentMod, &info, NULL, NULL, NULL);
        if (err==noErr) {
            result=convertUTCtoNSDate(info.contentModDate);
        }
    }
    return result;
}

static NSDate* loadCreateDate(NSString* path) {
    Boolean isDir;
    OSErr err;
    FSRef ref;
    NSDate* result=nil;
    FSCatalogInfo info;
    err=FSPathMakeRef((UInt8 *)[path fileSystemRepresentation], &ref, &isDir);
    if (err==noErr) {
        err=FSGetCatalogInfo(&ref, kFSCatInfoCreateDate, &info, NULL, NULL, NULL);
        if (err==noErr) {
            result=convertUTCtoNSDate(info.createDate);
        }
    }
    return result;
}

static id loadValue(NSString* path, NSMutableDictionary* dict, NSString* key) {
    id value;
    NSFileManager* manager=[NSFileManager defaultManager];
    
    NSDictionary* attribs=[manager attributesOfItemAtPath:path error:nil];

    value=[attribs objectForKey:key];
    if (! value) {
        if ([key isEqualToString:@"NSFileModificationDate"]) value=loadModDate(path);
        else if ([key isEqualToString:@"NSFileCreationDate"]) value=loadCreateDate(path);
    }
    if (value) [dict setObject:value forKey:path];
    return value;
}

int sortName(id firstPath, id secondPath, void* param) {
    NSString* first=[[firstPath filename] lastPathComponent];
    NSString* second=[[secondPath filename] lastPathComponent];
    return [first caseInsensitiveCompare:second];
}

int sortNumber(id firstPath, id secondPath, void* param) {
    NSCharacterSet* set=nil;
    BOOL fIsBad=NO, sIsBad=NO;
    NSString* first=[[firstPath filename] lastPathComponent];
    NSString* second=[[secondPath filename] lastPathComponent];
    int f=[first intValue];
    int s=[second intValue];
    if (f==0) {
        NSRange range;
        set=[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
        range=[first rangeOfCharacterFromSet:set];
        if (range.location==NSNotFound || ! isdigit([first characterAtIndex:range.location]))
            fIsBad=YES;
    }
    if (s==0) {
        if (! set) set=[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
        NSRange range;
        range=[second rangeOfCharacterFromSet:set];
        if (range.location==NSNotFound || ! isdigit([second characterAtIndex:range.location]))
            sIsBad=YES;
    }
    if (fIsBad && sIsBad) return [first compare:second];
    else if (fIsBad) return NSOrderedDescending;
    else if (sIsBad) return NSOrderedAscending;
    else if (f > s) return NSOrderedDescending;
    else if (s > f) return NSOrderedAscending;
    else return NSOrderedSame;
}

int sortModified(NSString* firstPath, NSString* secondPath, NSMutableDictionary* dict) {
    NSDate* f, * s;
    NSString* first=[firstPath filename];
    NSString* second=[secondPath filename];
    f=[dict objectForKey:first];
    s=[dict objectForKey:second];
    if (! f) f=loadValue(first, dict, @"NSFileModificationDate");
    if (! s) s=loadValue(second, dict, @"NSFileModificationDate");
    return [f compare:s];
}

int sortCreated(NSString* firstPath, NSString* secondPath, NSMutableDictionary* dict) {
    NSDate* f, * s;
    NSString* first=[firstPath filename];
    NSString* second=[secondPath filename];
    f=[dict objectForKey:first];
    s=[dict objectForKey:second];
    if (! f) f=loadValue(first, dict, @"NSFileCreationDate");
    if (! s) s=loadValue(second, dict, @"NSFileCreationDate");
    return [f compare:s];
}

int sortKind(NSString* first, NSString* second, NSMutableDictionary* param) {
    return NSOrderedSame;
}