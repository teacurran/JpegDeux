//
//  main.m
//  JPEGTrois
//
//  Created by Terrence Curran on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/NSDebug.h>

#define MAKE_CODE(a,b,c,d) ( ((unsigned long)a << 24 ) + \
((unsigned long)b << 16 ) + \
((unsigned long)c << 8 ) + \
(unsigned long)d )

const unsigned long gCreatorCode = MAKE_CODE('J', 'p', 'g', 'D');
const unsigned long gSSTypeCode = MAKE_CODE('J', 'p', 'g', 'D');

int main(int argc, char *argv[])
{

    return NSApplicationMain(argc, (const char **)argv);
}

