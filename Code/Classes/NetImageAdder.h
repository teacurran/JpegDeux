/* NetImageAdder */

#import <Cocoa/Cocoa.h>

@class Master;

@interface NetImageAdder : NSObject
{
    IBOutlet NSButton *myAddButton;
    IBOutlet NSTextField *myFirstURLField;
    IBOutlet NSTextField *myLastURLField;
    IBOutlet NSWindow *myWindow;
    IBOutlet Master* myMaster;
}
- (IBAction)addImages:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)showDialog:(id)sender;
@end
