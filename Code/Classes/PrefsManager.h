/* PrefsManager */

#import <Cocoa/Cocoa.h>

//this might be cleaner with selectors instead of "KeyAction"s
@interface KeyBinding : NSObject {
    @public
    SEL action;
    unichar key;
    id param;
}

+ (KeyBinding*)bindingWithKey:(unichar)key action:(SEL)action;

@end

@interface PrefsManager : NSObject
{
    IBOutlet NSTableView* myTable;
    IBOutlet NSWindow* myWindow;
    IBOutlet NSTextField* myFieldInstructions;
    NSMutableArray* myKeyBindings;

    NSDictionary* mySelectorDisplayStrings;
}
- (IBAction)cancel:(id)sender;
- (IBAction)OK:(id)sender;
- (IBAction)revertToDefaults:(id)sender;
- (IBAction)addKeyBinding:(id)sender;
- (void)deleteRowsFromView:(NSTableView*)view;

- (SEL)selectorForKey:(unichar)key withParam:(id*)param;

@end
