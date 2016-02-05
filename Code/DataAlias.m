//
//  DataAlias.m
//  JPEGDeux 2
//
//  Created by Peter Ammon on Sat Nov 23 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import "DataAlias.h"
#import <Carbon/Carbon.h>
#import "StringAdditions.h"

#define MAGIC_IDENTIFIER 'JpgD'

@implementation NSData (DataAlias)

+ (NSData*)aliasForPath:(NSString*)path {
    NSData* result;
    AliasHandle handle;
    if (! path) {
		return nil;
	}
	
    FSRef fsRef;
    OSStatus os_status = FSPathMakeRef((const UInt8 *)[path fileSystemRepresentation], &fsRef, NULL);

    if (os_status != noErr) {
        return nil;
    }
    

    if (FSNewAlias(NULL, &fsRef, &handle) != noErr) {
		return nil;
	}
	
    if (! handle) {
		return nil;
	}
	
    //(*handle)->userType=MAGIC_IDENTIFIER;
	SetAliasUserType(handle, MAGIC_IDENTIFIER);
    result=[NSData dataWithBytes:*handle length:GetAliasSize(handle)];
    DisposeHandle((Handle)handle);
    return result;
}

- (NSString*)pathForAlias {
    UInt8 path[512];
    Boolean wasChanged;
    FSRef target;
    FSRef ref;
    AliasPtr alias=(AliasPtr)[self bytes]; //dangerous; if the file is moved we update bytes in an NSData
    if (MAGIC_IDENTIFIER != *(OSType*)alias) return nil;
    
    if (FSResolveAlias(NULL, &alias, &target, &wasChanged) != noErr) {
        return nil;
    }
    
    if (FSRefMakePath(&ref, path, sizeof path) != noErr) {
        return nil;
    }
    return [NSString stringWithUTF8String:(const char *)path];
}

@end
