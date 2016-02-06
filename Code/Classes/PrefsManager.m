#import "PrefsManager.h"

static NSString* const KeyBindingsKey = @"KeyBindings";

enum {
    EscapeKey = 0x1B
};

static NSString* charToString(unichar c) {
    return [NSString stringWithCharacters:&c length:1];
}

#define SEL2STR(x) NSStringFromSelector(@selector(x))

//an ugly hack.  Above is better, but it's not a constant expression :(
//#define PASTE(a,b) a##b
//#define SEL2STR(x) PASTE(@,#x)

NSString* displayers[]={
    @"Skip to next picture",
    @"Skip to previous picture",
    @"End show",
    @"Toggle auto-advance",
    @"Increase show speed",
    @"Decrease show speed",
    @"Move to trash",
    @"Move to folder...",
    @"Copy to folder...",
    @"Rotate 90\xC2\xB0",
    @"Rotate 90\xC2\xB0 CW",
    @"Flip horizontal",
    @"Flip vertical",
    @"Toggle comment window"
};

NSString* selectors[sizeof displayers / sizeof *displayers];


static NSString* displayStringForKey(unichar key) {
    //assume function keys are contiguous
    if (key >= NSF1FunctionKey && key <= NSF35FunctionKey) {
        return [NSString stringWithFormat:@"F%d", key-NSF1FunctionKey+1];
    }
    switch (key) {
        case ' ': return @"Space";
        case '\r': return @"Return";
        case 0x7F: return @"Delete";
        case 0x03: return @"Enter";
        case EscapeKey: return @"Esc";
        case NSRightArrowFunctionKey: return charToString(0x2192);
        case NSLeftArrowFunctionKey: return charToString(0x2190);
        case NSUpArrowFunctionKey: return charToString(0x2191);
        case NSDownArrowFunctionKey: return charToString(0x2193);
        case NSInsertFunctionKey: return @"Ins";
        case NSDeleteFunctionKey: return @"Del";
        case NSHomeFunctionKey: return @"Home";
        case NSEndFunctionKey: return @"End";
        case NSPageUpFunctionKey: return @"PgUp";
        case NSPageDownFunctionKey: return @"PgDn";
        case NSPrintScreenFunctionKey: return @"PrScn";
        case NSScrollLockFunctionKey: return @"ScrLk";
        case NSPauseFunctionKey: return @"Pause";
        case NSSysReqFunctionKey: return @"SysRq";
        case NSBreakFunctionKey: return @"Break";
        case NSResetFunctionKey: return @"Reset";
        case NSStopFunctionKey: return @"Stop";
        case NSMenuFunctionKey: return @"Menu";
        case NSUserFunctionKey: return @"User";
        case NSSystemFunctionKey: return @"Sys";
        case NSPrintFunctionKey: return @"Print";
        case NSClearLineFunctionKey: return @"ClrLn";
        case NSClearDisplayFunctionKey: return @"ClrDs";
        case NSInsertLineFunctionKey: return @"InsLn";
        case NSDeleteLineFunctionKey: return @"DelLn";
        case NSInsertCharFunctionKey: return @"InsCh";
        case NSDeleteCharFunctionKey: return @"DelCh";
        case NSPrevFunctionKey: return @"Prev";
        case NSNextFunctionKey: return @"Next";
        case NSSelectFunctionKey: return @"Sel";
        case NSExecuteFunctionKey: return @"Exec";
        case NSUndoFunctionKey: return @"Undo";
        case NSRedoFunctionKey: return @"Redo";
        case NSFindFunctionKey: return @"Find";
        case NSHelpFunctionKey: return @"Help";
        case NSModeSwitchFunctionKey: return @"MdSwc";
        default: return charToString(key);
    }
}

@implementation PrefsManager

- (void)loadPrefs {
    NSUserDefaults* prefs=[NSUserDefaults standardUserDefaults];
    NSData* defs;
    [myKeyBindings release];
    myKeyBindings=nil;
    defs=[prefs objectForKey:KeyBindingsKey];
    if (defs==nil) [self revertToDefaults:self];
    else {
        NSArray* uncoded=[NSUnarchiver unarchiveObjectWithData:defs];
        myKeyBindings=[[NSMutableArray alloc] initWithArray:uncoded];
    }
}

- (void)savePrefs {
    NSData* defs;
    NSUserDefaults* prefs=[NSUserDefaults standardUserDefaults];
    if (! myKeyBindings) [self revertToDefaults:self];
    defs=[NSArchiver archivedDataWithRootObject:myKeyBindings];
    [prefs setObject:defs forKey:KeyBindingsKey];
    [prefs synchronize];
}


- (void)awakeFromNib {
    if (! mySelectorDisplayStrings) {
        unsigned i;
        NSPopUpButtonCell* button;
        i=0;
        selectors[i++]=SEL2STR(kbNextPic:);
        selectors[i++]=SEL2STR(kbPrevPic:);
        selectors[i++]=SEL2STR(kbEndShow:);
        selectors[i++]=SEL2STR(kbToggleAdvance:);
        selectors[i++]=SEL2STR(kbIncreaseSpeed:);
        selectors[i++]=SEL2STR(kbDecreaseSpeed:);
        selectors[i++]=SEL2STR(kbMoveToTrash:);
        selectors[i++]=SEL2STR(kbMoveToFolder:);
        selectors[i++]=SEL2STR(kbCopyToFolder:);
        selectors[i++]=SEL2STR(kbRotateCCW:);
        selectors[i++]=SEL2STR(kbRotateCW:);
        selectors[i++]=SEL2STR(kbFlipH:);
        selectors[i++]=SEL2STR(kbFlipV:);
        selectors[i++]=SEL2STR(kbToggleComments:);
        mySelectorDisplayStrings=[[NSDictionary alloc] initWithObjects:displayers
                                                               forKeys:selectors
                                                                 count:sizeof selectors/sizeof *selectors];
        button=[[[NSPopUpButtonCell alloc] initTextCell:displayers[0] pullsDown:NO] autorelease];
        for (i=1; i < sizeof displayers / sizeof *displayers; i++) {
            [button addItemWithTitle:displayers[i]];
        }
        [button setControlSize:NSSmallControlSize];
        [button setFont:[NSFont systemFontOfSize:11]];
        [[myTable tableColumnWithIdentifier:@"action"] setDataCell:button];
        [myTable setTarget:self];
        [myTable setDoubleAction:@selector(changeKeyBinding:)];
        [myFieldInstructions setStringValue:@""];
        [self loadPrefs];
    }
}

- (NSString*)displayStringForSelector:(SEL)selector {
    return [mySelectorDisplayStrings objectForKey:NSStringFromSelector(selector)];
}


- (IBAction)cancel:(id)sender {
    [myWindow orderOut:self];
}

- (BOOL)validatePrefs {
    NSArray* sorted=[myKeyBindings sortedArrayUsingSelector:@selector(comparer:)];
    long i, max=[sorted count];
    unichar lastKey=0;
    for (i=0; i<max; i++) {
        KeyBinding* kb=[sorted objectAtIndex:i];
        if (kb->key==lastKey) break;
        lastKey=kb->key;
    }
    if (i < max) {
        NSInteger result=NSRunAlertPanel(@"Duplicate actions",
                                   @"Multiple actions have been assigned to the same key! "
                                   @"Only one action will take effect.  Are you sure you wish to continue?",
                                   @"Continue", @"Cancel", nil);
        return result==NSAlertDefaultReturn;
    }
    else return YES;
}

- (IBAction)OK:(id)sender {
    if ([self validatePrefs]) {
        [self savePrefs];
        [myWindow orderOut:self];
    }
}

- (IBAction)revertToDefaults:(id)sender {
    [myKeyBindings release];
    myKeyBindings=[[NSMutableArray alloc] initWithObjects:
        [KeyBinding bindingWithKey:NSRightArrowFunctionKey action:@selector(kbNextPic:)],
        [KeyBinding bindingWithKey:NSLeftArrowFunctionKey action:@selector(kbPrevPic:)],
        [KeyBinding bindingWithKey:EscapeKey action:@selector(kbEndShow:)],
        [KeyBinding bindingWithKey:' ' action:@selector(kbToggleAdvance:)],
        [KeyBinding bindingWithKey:'+' action:@selector(kbIncreaseSpeed:)],
        [KeyBinding bindingWithKey:'-' action:@selector(kbDecreaseSpeed:)],
        [KeyBinding bindingWithKey:'d' action:@selector(kbMoveToTrash:)],
        [KeyBinding bindingWithKey:'r' action:@selector(kbRotateCCW:)],
        [KeyBinding bindingWithKey:'e' action:@selector(kbRotateCW:)],
        [KeyBinding bindingWithKey:'h' action:@selector(kbFlipH:)],
        [KeyBinding bindingWithKey:'v' action:@selector(kbFlipV:)],
        NULL];
    [myTable reloadData];
}

- (IBAction)editPrefs:(id)sender {
    [self loadPrefs];
    [myWindow makeKeyAndOrderFront:self];
}

- (NSUInteger)numberOfRowsInTableView:(NSTableView*)view {
    return [myKeyBindings count];
}

- (id)tableView:(NSTableView*)view objectValueForTableColumn:(NSTableColumn*)col row:(int)row {
    KeyBinding* kb=[myKeyBindings objectAtIndex:row];
    if ([[col identifier] isEqualToString:@"action"]) {
        int i;
        NSString* sel=NSStringFromSelector(kb->action);
        for (i=0; i < sizeof selectors / sizeof *selectors; i++) {
            if ([sel isEqualToString:selectors[i]]) return [NSNumber numberWithInt:i];
        }
        return NULL;
    }
    else return displayStringForKey(kb->key);
}

- (void)tableView:(NSTableView*)view setObjectValue:(id)value forTableColumn:(NSTableColumn*)column row:(int)row {
    KeyBinding* kb=[myKeyBindings objectAtIndex:row];
    if ([[column identifier] isEqualToString:@"action"]) {
        SEL newSel=NSSelectorFromString(selectors[[value intValue]]);
        if (newSel == @selector(kbMoveToFolder:) || newSel == @selector(kbCopyToFolder:)) {
            NSOpenPanel* panel=[NSOpenPanel openPanel];
            NSInteger result;
            
            [panel setCanChooseFiles:NO];
            [panel setCanChooseDirectories:YES];
            [panel setResolvesAliases:YES];
            result=[panel runModal];
            if (result==NSCancelButton) return;
			NSURL *pathUrl = [[panel URLs] objectAtIndex:0];
            NSString *path=[pathUrl absoluteString];
            kb->param=[path retain];
        }
        kb->action=newSel;
    }
}

- (void)setKeyBinding:(NSString*)chars {
    NSInteger row=[myTable selectedRow];
    KeyBinding* kb=[myKeyBindings objectAtIndex:row];
    kb->key=[chars characterAtIndex:0];
    [myTable reloadData];
}

- (void)changeKeyBinding:(id)sender {
    NSApplication* app = [NSApplication sharedApplication];
    NSEvent* event;
    [NSCursor hide];
    [myFieldInstructions setStringValue:@"Hit any key to change the binding for this action"];
    event=[app nextEventMatchingMask: NSKeyDownMask
                           untilDate:[NSDate distantFuture]
                              inMode:NSEventTrackingRunLoopMode
                             dequeue:YES];
    [NSCursor unhide];
    [myFieldInstructions setStringValue:@""];
    [self setKeyBinding:[event charactersIgnoringModifiers]];
}

- (void)deleteRowsFromView:(NSTableView*)view {
    if ([view numberOfSelectedRows]) {
        NSInteger row=[view selectedRow];
        [myKeyBindings removeObjectAtIndex:row];
        [view reloadData];
    }
    else NSBeep();
}

- (IBAction)addKeyBinding:(id)sender {
    [myKeyBindings addObject:[KeyBinding bindingWithKey:'0' action:NSSelectorFromString(selectors[0])]];
    [myTable reloadData];
}

- (SEL)selectorForKey:(unichar)key withParam:(id*)param {
    NSInteger i, max=[myKeyBindings count];
    for (i=0; i<max; i++) {
        KeyBinding* kb=[myKeyBindings objectAtIndex:i];
        if (kb->key == key) {
            if (param) *param=kb->param;
            return kb->action;
        }
    }
    return NULL;
}

@end

@implementation KeyBinding

- (void)dealloc {
    [param release];
    [super dealloc];
}

+ (KeyBinding*)bindingWithKey:(unichar)nkey action:(SEL)naction {
    KeyBinding* kb=[[[self alloc] init] autorelease];
    kb->action=naction;
    kb->key=nkey;
    return kb;
}

- (id)initWithCoder:(NSCoder*)coder {
    int version;
    [coder decodeValueOfObjCType:@encode(int) at:&version];
    [coder decodeValueOfObjCType:@encode(SEL) at:&action];
    [coder decodeValueOfObjCType:@encode(unichar) at:&key];
    param=[[coder decodeObject] retain];
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    int version=200;
    [coder encodeValueOfObjCType:@encode(int) at:&version];
    [coder encodeValueOfObjCType:@encode(SEL) at:&action];
    [coder encodeValueOfObjCType:@encode(unichar) at:&key];
    if (! param) param=[NSNull null];
    [coder encodeObject:param];
}

- (NSComparisonResult)comparer:(KeyBinding*)keyBinding {
    if (key < keyBinding->key) return NSOrderedAscending;
    else if (key==keyBinding->key) return NSOrderedSame;
    else return NSOrderedDescending;
}

@end
