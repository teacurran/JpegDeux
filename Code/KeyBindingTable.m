//
//  KeyBindingTable.m
//  JPEGDeux 2
//
//  Created by peter on Mon Jul 01 2002.
//  This code is released under the Modified BSD license
//

#import "KeyBindingTable.h"
#import "PrefsManager.h"

@implementation KeyBindingTable

- (void)keyDown:(NSEvent*)event {
    id delegate;
    NSString* chars=[event characters];
    unichar theChar=[chars characterAtIndex:0];
    if ((theChar==NSDeleteCharacter || theChar==NSBackspaceCharacter) && [delegate=[self delegate] respondsToSelector:@selector(deleteRowsFromView:)]) [delegate deleteRowsFromView:self];
    else [super keyDown:event];
}

@end
