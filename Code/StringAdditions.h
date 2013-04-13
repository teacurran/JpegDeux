//
//  StringAdditions.h
//  JPEGDeux
//
//  Created by Peter on Wed Sep 07 2001.

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@interface NSString (StringAdditions)

//returns a path to the file pointed at by self if self is an alias, self otherwise
//yes, we do follow chains of aliases
//returns nil if self cannot be resolved.  Does not attempt to mount volumes.
//if isDir is not nil, returns whether or not the resolved file is a directory
- (NSString*)resolveAliasesIsDir:(BOOL*)pIsDir;

// fills in spec with the FSSpec for the given path
// returns YES on success
- (BOOL)makeFSSpec:(FSSpec*)spec;

//case sensitive
- (NSString*)commonSuffixWithString:(NSString*)s;

@end
