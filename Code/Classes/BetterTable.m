//
//  BetterTable.m
//  JPEGDeux
//
//  Created by Peter on Wed Sep 05 2001.

#import "BetterTable.h"
#import "Master.h"


@implementation BetterTable

- (void)awakeFromNib {
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    //[[[self enclosingScrollView] contentView] setCopiesOnScroll:YES];
}

- (void)setHasBorder:(BOOL)v {
    
}

- (void)keyDown:(NSEvent*)event {
    id delegate;
    NSString* chars=[event characters];
    unichar theChar=[chars characterAtIndex:0];
    if ((theChar==NSDeleteCharacter || theChar==NSBackspaceCharacter) && [delegate=[self delegate] respondsToSelector:@selector(deleteRowsFromOutline:)]) [delegate deleteRowsFromOutline:self];
    else [super keyDown:event];
}

#if 0

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard* board=[sender draggingPasteboard];
    NSDragOperation sourceDragMask=[sender draggingSourceOperationMask];
    if ([[board types] indexOfObject:NSFilenamesPboardType] != NSNotFound) {
        if (sourceDragMask & NSDragOperationLink) {
            [self setHasBorder:YES];
            [self display];
            return NSDragOperationLink;
        }
    }
    return NSDragOperationNone;
}

//we seem to have to implement this method, though the spec says we shouldn't have to!
- (unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender {
    return NSDragOperationLink;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    [[[self enclosingScrollView] contentView] setCopiesOnScroll:YES];
    [self display];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    id source=[sender draggingSource];
    unsigned mask=[source draggingSourceOperationMask];
    return YES;
    return mask & NSDragOperationLink;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard* board=[sender draggingPasteboard];
    Master* master=[Master master];
    NSArray* array;
    if ([[board types] indexOfObject:NSFilenamesPboardType] == NSNotFound) return NO;
    array=[board propertyListForType:NSFilenamesPboardType];
    if (array==nil) return NO;
    [master processAndAddFiles:array];
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
    [self setHasBorder:NO];
}



- (NSDragOperation)draggingSourceOperationMask {
    return NSDragOperationMove;
}

#endif

@end
