//
//  Master.h
//  JPEGDeux
//
//  Created by Peter on Tue Sep 04 2001.
//

#import <Cocoa/Cocoa.h>
#import "Procedural.h"
#import "PetersTypes.h"
#import "PrefsManager.h"

#define HierarchyPBoardType @"HierarchyPBoardType"

extern const unsigned long gCreatorCode;
extern const unsigned long gSSTypeCode;

@class SlideShow;
@class BackgroundImageView;
@class DefaultTransitionChooser;

typedef enum {
   eNothing=0,
   eStop,
   eNext,
   ePrev,
   eReeval //a horrible hack
} EventAction;

@interface Master : NSObject {
    id	myDisplayModeClass;
    BOOL myShouldLoop;
    BOOL myShouldRandomize;
    BOOL myShouldAutoAdvance;
    BOOL myShouldOnlyScaleDown;
    BOOL myShouldRecursivelyScanSubdirectories;
    BOOL myShouldPrecache;
    FileNameDisplay myFileNameDisplay;
    NSMutableArray* myChosenFiles;
    SlideShow* myCurrentShow;
    CFTimeInterval myTimeInterval;
    BetterImageScaling myScaling;
    NSString* myCurrentSavingPath;
    int myQuality; //1 through 5, 1 is lowest, 5 is highest
    NSMutableArray* myFileHierarchyArray;
    NSColor* myBackgroundColor;
    NSUndoManager* myUndoer;
    CommentStyle_t myCommentDisplay;
    DefaultTransitionChooser* myTransitionChooser;

    IBOutlet NSColorWell* myBackgroundColorWell;
    IBOutlet NSOutlineView* myFilesTable;
    IBOutlet NSMatrix* myDisplayModeMatrix;
    IBOutlet NSMatrix* myScalingMatrix;
    IBOutlet NSButton* myShouldOnlyScaleDownButton;
    IBOutlet NSButton* myShouldLoopButton;
    IBOutlet NSButton* myShouldRandomizeButton;
    IBOutlet NSButton* myShouldAutoAdvanceButton;
    IBOutlet NSButton* myShouldRecursivelyScanSubdirectoriesButton;
    IBOutlet NSMatrix* myDisplayFileNameMatrix;
    IBOutlet NSTextField* myTimeIntervalField;
    IBOutlet NSWindow* myWindow;
    IBOutlet PrefsManager* myPrefsManager;
    IBOutlet NSSlider* myQualitySlider;
    IBOutlet NSButton* myShouldPrecacheButton;
    IBOutlet NSDrawer* myDrawer;
    IBOutlet BackgroundImageView* myPreview;
    IBOutlet NSButton* myDisplayCommentButton;
    IBOutlet NSDrawer* myTransitionDrawer;
}

- (IBAction)selectFiles:(id)sender;
- (void)openPanelDidEnd:(NSOpenPanel*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo;
- (IBAction)setDisplayMode:(id)sender;
- (IBAction)setLoop:(id)sender;
- (IBAction)setRandomOrder:(id)sender;
- (IBAction)setAutoAdvance:(id)sender;
- (IBAction)setInterval:(id)sender;
- (IBAction)setImageScaling:(id)sender;
- (IBAction)setShouldOnlyScaleDown:(id)sender;
- (IBAction)setShouldRecursivelyScanSubdirectories:(id)sender;
- (IBAction)setFileNameDisplayType:(id)sender;
- (IBAction)setQualitySlider:(id)sender;
- (IBAction)setShouldPrecache:(id)sender;
- (IBAction)setCommentDisplay:(id)sender;
- (IBAction)begin:(id)sender;

- (IBAction)sortName:(id)sender;
- (IBAction)sortNumber:(id)sender;
- (IBAction)sortModified:(id)sender;
- (IBAction)sortCreated:(id)sender;
- (IBAction)sortKind:(id)sender;

- (IBAction)sortSelectedName:(id)sender;
- (IBAction)sortSelectedNumber:(id)sender;
- (IBAction)sortSelectedModified:(id)sender;
- (IBAction)sortSelectedCreated:(id)sender;
- (IBAction)sortSelectedKind:(id)sender;

- (void)saveUndoableState;

+ (Master*)master;

- (void)savePreferenceSettings;

- (void)processAndAddURLs:(NSArray*)urls; //as strings
- (void)processAndAddFiles:(NSArray*)files;

- (void)displayImageLoop;
- (EventAction)handleEvent:(NSEvent*)event;

- (IBAction)saveDocument:(id)sender;
- (IBAction)saveDocumentAs:(id)sender;

- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;

- (IBAction)removeAllImages:(id)sender;
- (IBAction)flattenImageHierarchy:(id)sender;

- (IBAction)reverseAllImages:(id)sender;
- (IBAction)reverseSelectedImages:(id)sender;

- (IBAction)displayImageInWindow:(id)sender;

- (IBAction)closeWindow:(id)sender;

@end
