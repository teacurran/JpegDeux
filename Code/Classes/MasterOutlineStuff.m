//
//  MasterOutlineStuff.m
//  JPEGDeux 2
//
//  Created by peter on Tue Jul 09 2002.
//  This code is released under the Modified BSD license
//

#import "MasterOutlineStuff.h"
#import "Master.h"
#import "FileHierarchySupport.h"
#import "BackgroundImageView.h"

@implementation Master (MasterOutlineStuff)

- (BOOL)outlineView:(NSOutlineView*)view writeItems:(NSArray*)items toPasteboard:(NSPasteboard*)board {
    NSEnumerator* enumer=[items objectEnumerator];
    id object;
    NSMutableArray* hier, * names;
    [board declareTypes:@[HierarchyPBoardType, NSFilenamesPboardType]
                  owner:nil];
    hier=[NSMutableArray arrayWithCapacity:[view numberOfSelectedRows]];
    names=[NSMutableArray arrayWithCapacity:[view numberOfSelectedRows]];
    while ((object=[enumer nextObject])) {
        [hier addObject:object];
        [names addObject:[object filename]];
    }
    [board setPropertyList:names forType:NSFilenamesPboardType];
    [board setPropertyList:hier forType:HierarchyPBoardType];
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView*)view validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)index {
    if (item==NULL || [item isFolder]) return NSDragOperationMove | NSDragOperationLink;
    else return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView*)view acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index {
    NSPasteboard* board=[info draggingPasteboard];
    NSString* type;
    type= [board availableTypeFromArray:@[HierarchyPBoardType,
                NSFilenamesPboardType]];
    if ([type isEqualToString:NSFilenamesPboardType]) {
        NSArray* files=[board propertyListForType:NSFilenamesPboardType];
        long i, max;
        NSMutableArray* contents;
        if (item && ! [item isFolder]) {
            return NO;
        }
        [self saveUndoableState];
        if (item==NULL) contents=myFileHierarchyArray;
        else contents=[item contents];
        max=[files count];
        if (index < 0) index=0;
        for (i=0; i<max; i++) {
            NSString* path= files[i];
            id hierarchy;
            if (myShouldRecursivelyScanSubdirectories) hierarchy=[FileHierarchy hierarchyWithPath:path];
            else hierarchy=[FileHierarchy folderContentsWithPath:path];
            if (hierarchy) [contents insertObject:hierarchy atIndex:index++];
        }
        [myFilesTable reloadData];
        return YES;
    }
    else if ([type isEqualToString:HierarchyPBoardType]) {
        NSArray* arr=[board propertyListForType:HierarchyPBoardType];
        if (item && ! [item isFolder]) {
            return NO;
        }
        else {
            NSMutableArray* contents;
            NSUInteger i, max=[arr count];
            NSArray* oldContents;
            if (item==NULL) contents=myFileHierarchyArray;
            else contents=[item contents];
            oldContents=[NSArray arrayWithArray:contents];
            [self saveUndoableState];
            for (i=0; i<max; i++) {
                id addingObject= arr[i];
                [self removeHierarchy:addingObject];
            }
            //make sure that the array didn't just shift out from under us!
            if ([contents count] < [oldContents count]) {
                max=[contents count];
                for (i=0; i<max; i++) {
                    if (![contents[i] isEqual:oldContents[i]]) break;
                }
                //i should now contain the index of the place where the object was taken from
                //note that it might be past the end of the array
                if (i < index) index--;
            }
            if (index < 0 ) index=0;
            [contents replaceObjectsInRange:NSMakeRange(index, 0)
                       withObjectsFromArray:arr];
            [myFilesTable reloadData];
        }
        return YES;
    }
    else return NO;
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item {
    return [item isFolder];
}

- (NSUInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item==nil) return [myFileHierarchyArray count];
    if ([item isFolder]) return [[item contents] count];
    else return 0;
}

- (id)outlineView:(NSOutlineView*)outlineView child:(int)index ofItem:(id)item {
    if (item==nil) return myFileHierarchyArray[index];
    else {
        NSArray* arr=[item contents];
        return arr[index];
    }
}

- (id)outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn*)column byItem:(id)item {
    if ([[column identifier] isEqualToString:@"filename"]) return [[item filename] lastPathComponent];
    else {
        const unichar check=0x2713;
        return [NSString stringWithCharacters:&check length:1];
    }
}

- (BOOL)removeHierarchy:(id)item {
    NSInteger i, max=[myFileHierarchyArray count];
    for (i=0; i<max; i++) {
        id hierarchy= myFileHierarchyArray[i];
        if ([hierarchy isEqual:item]) {
            [myFileHierarchyArray removeObjectAtIndex:i];
            return YES;
        } else if ([hierarchy removeHierarchy:item]) return YES;
    }
    return NO;
}

- (void)deleteRowsFromOutline:(NSOutlineView*)view {
    NSIndexSet *indexes=[view selectedRowIndexes];
    [self saveUndoableState];

	NSUInteger row = [indexes firstIndex];
	while (row != NSNotFound) {
        id item=[view itemAtRow:row];
        [self removeHierarchy:item];

		//increment
		row = [indexes indexGreaterThanIndex: row];
	}
    
    [view deselectAll:self];
    [view reloadData];
}

- (void)outlineViewSelectionDidChange:(NSNotification*)notification {
    if ([myDrawer state]==NSDrawerOpenState) {
        BOOL shouldDisplayImage;
        id hierarchy=nil;
        NSImage* image=nil;
        NSInteger row=[myFilesTable selectedRow];
        if (row==-1) shouldDisplayImage=NO;
        else {
            hierarchy=[myFilesTable itemAtRow:row];
            if (hierarchy!=nil && ![hierarchy isFolder])
                image=[[NSImage alloc] initWithContentsOfFile:hierarchy];
        }
        [self redoPreviewImageName];
        [myPreview setImage:image];
    }
}

- (void)redoPreviewImageName {
    NSString* name=nil;
    NSInteger row;
    if (myFileNameDisplay != none) {
        row=[myFilesTable selectedRow];
        if (row != -1) {
            id hierarchy=[myFilesTable itemAtRow:row];
            if (hierarchy!=nil && ![hierarchy isFolder]) {
                if (myFileNameDisplay==path) name=hierarchy;
                else name=[hierarchy lastPathComponent];
            }
        }
    }
    [myPreview setImageName:name];
    [myPreview setNeedsDisplay:YES];
}

- (void)drawerDidOpen:(NSNotification*)note {
    [self outlineViewSelectionDidChange:note];
}

@end
