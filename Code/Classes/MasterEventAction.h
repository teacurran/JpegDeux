//
//  MasterEventAction.h
//  JPEGDeux 2
//
//  Created by peter on Sat Jul 20 2002.
//  This code is released under the Modified BSD license
//

#import <Cocoa/Cocoa.h>


@interface Master (MasterEventAction)

//For keybindings
- (EventAction)kbNextPic:(id)param;
- (EventAction)kbPrevPic:(id)param;
- (EventAction)kbEndShow:(id)param;
- (EventAction)kbToggleAdvance:(id)param;
- (EventAction)kbIncreaseSpeed:(id)param;
- (EventAction)kbDecreaseSpeed:(id)param;
- (EventAction)kbMoveToTrash:(id)param;
- (EventAction)kbMoveToFolder:(id)param;
- (EventAction)kbCopyToFolder:(id)param;
- (EventAction)kbRotateCW:(id)param;
- (EventAction)kbRotateCCW:(id)param;
- (EventAction)kbFlipH:(id)param;
- (EventAction)kbFlipV:(id)param;
- (EventAction)kbToggleComments:(id)param;


@end
