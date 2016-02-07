//
//  MasterEventAction.m
//  JPEGDeux 2
//
//  Created by peter on Sat Jul 20 2002.
//  This code is released under the Modified BSD license
//

#import "Master.h"
#import "MasterEventAction.h"
#import "SlideShow.h"

//thanks to Tomas Zahradnicky, Jr. who wrote invalTrashContents
static OSErr invalTrashContents(void);


@implementation Master (MasterEventAction)

- (EventAction)kbNextPic:(id)param {
    return eNext;
}

- (EventAction)kbPrevPic:(id)param {
    [myCurrentShow rewind:2];
    return ePrev;
}

- (EventAction)kbEndShow:(id)param {
    return eStop;
}

- (EventAction)kbToggleAdvance:(id)param {
    myShouldAutoAdvance=!myShouldAutoAdvance;
    return eReeval;
}

- (EventAction)kbIncreaseSpeed:(id)param {
    myTimeInterval*=.75;
    return eReeval;
}

- (EventAction)kbDecreaseSpeed:(id)param {
    if (myTimeInterval == 0) myTimeInterval=.1;
    else myTimeInterval*=1.3333333333333333;
    return eReeval;
}

- (EventAction)kbMoveToTrash:(id)param {
    NSString* path=[myCurrentShow currentPath];
    if (! [path length]) NSBeep();
    else {
        NSInteger unused;
        NSWorkspace* space=[NSWorkspace sharedWorkspace];
        if (! [space performFileOperation:NSWorkspaceRecycleOperation
                                   source:[[path stringByDeletingLastPathComponent] stringByAppendingString:@"/"]
                              destination:@""
                                    files:[NSArray arrayWithObject:[path lastPathComponent]]
                                      tag:&unused]) {
            NSBeep();
        }
        else [[NSSound soundNamed:@"trash"] play];
        invalTrashContents();
    }
    return eNext;
}

- (EventAction)kbMoveToFolder:(id)param {
    NSString* path=[myCurrentShow currentPath];
    if (! [path length]) NSBeep();
    else {
        NSInteger unused;
        NSWorkspace* space=[NSWorkspace sharedWorkspace];
        if (! [space performFileOperation:NSWorkspaceMoveOperation
                                   source:[path stringByDeletingLastPathComponent]
                              destination:param
                                    files:[NSArray arrayWithObject:[path lastPathComponent]]
                                      tag:&unused]) {
            NSBeep();
        }
    }
    return eNext;
}

- (EventAction)kbCopyToFolder:(id)param {
    NSString* path=[myCurrentShow currentPath];
    if (! [path length]) NSBeep();
    else {
        NSInteger unused;
        NSWorkspace* space=[NSWorkspace sharedWorkspace];
        if (! [space performFileOperation:NSWorkspaceCopyOperation
                                   source:[path stringByDeletingLastPathComponent]
                              destination:param
                                    files:[NSArray arrayWithObject:[path lastPathComponent]]
                                      tag:&unused]) {
            NSBeep();
        }
    }
    return eNext;
}

- (EventAction)kbRotateCW:(id)param {
    [myCurrentShow rotate:3];
    [myCurrentShow redisplay];
    return eReeval;
}

- (EventAction)kbRotateCCW:(id)param {
    [myCurrentShow rotate:1];
    [myCurrentShow redisplay];
    return eReeval;
}

- (EventAction)kbFlipH:(id)param {
    //[myCurrentShow rewind:1];
    [myCurrentShow flipHorizontal];
    [myCurrentShow redisplay];
    return eReeval;
}

- (EventAction)kbFlipV:(id)param {
    //[myCurrentShow rewind:1];
    [myCurrentShow flipVertical];
    [myCurrentShow redisplay];
    return eReeval;
}

- (EventAction)kbToggleComments:(id)param {
    [myCurrentShow toggleCommentWindow];
    return eReeval;
}

@end


//thanks to Tomas Zahradnicky, Jr. who wrote invalTrashContents
OSErr invalTrashContents(void) {
    //  trash is located in ~/.Trash and this folder does not
    //  exist if it is empty. If you call invalTrashContents
    //  on trash with 0 files trash folder is attempted to be
    //  deleted. If it exists, trash folder is invalidated
    //  and finder views are updated.

    OSStatus			err = 0;
    FSRef			trashRef;
    Boolean			isDirectory;
    NSString			*trashpath	= @"~/.Trash";
    NSString			*completepath;

    completepath = [trashpath stringByExpandingTildeInPath];

    err = FSPathMakeRef((const unsigned char*)[completepath UTF8String], &trashRef, &isDirectory);

    if(err!=noErr || !isDirectory)
    {
        //  trash does not exist. don't do anything
        return err;
    }

    err =FNNotify(&trashRef,kFNDirectoryModifiedMessage,kNilOptions);

    return err;
}