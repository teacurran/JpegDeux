//
//  MyWindowController.m
//  JPEGDeux 2
//
//  Created by peter on Sun Jul 21 2002.
//  This code is released under the Modified BSD license
//

#import "MyWindowController.h"


@implementation MyWindowController

- (void)cancel:(id)param {
    //[[NSApplication sharedApplication] abortModal]; //doesn't work??
    [NSException raise:NSAbortModalException format:@"FooBar"];
}

@end
