//
//  Master.m
//  JPEGDeux
//
//  Created by Peter on Tue Sep 04 2001.
//

#import "Master.h"
#import "SlideShow.h"
#import "WindowShow.h"
#import "ScreenShow.h"
#import "DockShow.h"
//#import "FSQTShow.h"
#import "MutableArrayCategory.h"
#import "StringAdditions.h"
#import "ObjectAdditions.h"
#import "DictionaryConvenience.h"
#import "FileHierarchySupport.h"
#import "BackgroundImageView.h"
#import "MasterOutlineStuff.h"
#import "sorting.h"
#import "ImageWindowController.h"
#import "DefaultTransitionChooser.h"

NSString* const CancelShowException=@"CancelShow";

const static int numShowTypes=5;

const short StopSlideshowEventType=15;

static NSData* archive(NSColor* c) {
    if (! c) c = [NSColor blackColor];
    return [NSArchiver archivedDataWithRootObject:c];
}

static NSColor* unarchive(NSData* data) {
    if (! data) return [NSColor blackColor];
    else return [NSUnarchiver unarchiveObjectWithData:data];
}

#define MINQUALITY 1
#define MAXQUALITY 5

static Master* sharedMaster;
static NSApplication* application;

static NSMutableArray* aliasIfNecessary(NSArray* array) {
    NSUserDefaults* prefs=[NSUserDefaults standardUserDefaults];
    if (! [prefs boolForKey:@"DontAliasDictionaries"]) {
        NSUInteger i, max=[array count];
        NSMutableArray* a=[NSMutableArray arrayWithCapacity:max];
        for (i=0; i<max; i++) {
            [a addObject:[array[i] alias]];
        }
        return a;
    }
    else return [NSMutableArray arrayWithArray:array];
}

static NSMutableArray* unaliasIfNecessary(NSArray* array) {
    if ([array count] && [array isAliased]) {
        NSUInteger i, max=[array count];
        NSMutableArray* a=[NSMutableArray arrayWithCapacity:max];
        for (i=0; i<max; i++) {
            [a addObject:[array[i] unalias]];
        }
        return a;
    }
    else return [NSMutableArray arrayWithArray:array];
}


@implementation Master

+ (Master*)master {
    return sharedMaster;
}

- (void)loadTransitionChooser {
    Class class;
    class=[DefaultTransitionChooser classForShowTypeByTag:[myDisplayModeClass tagNumber]];
    myTransitionChooser=[class loadView];
    [myTransitionDrawer setContentView:[myTransitionChooser view]];
}

- (id)init {
    if (self=[super init]) {
        sharedMaster=self;
        application=[NSApplication sharedApplication];
        myDisplayModeClass=[WindowShow class];
        [[NSApplication sharedApplication] setDelegate:self];
        myFileHierarchyArray=[[NSMutableArray alloc] init];
        myUndoer=[[NSUndoManager alloc] init];
        [self loadTransitionChooser];
    }
    return self;
}

- (void)showWindow {
    [myWindow makeKeyAndOrderFront:self];
}

- (void)synchronizeWindowWithValues {
    [self showWindow];
    [myDisplayModeMatrix selectCellWithTag:[myDisplayModeClass tagNumber]];
    [myShouldLoopButton setIntValue:myShouldLoop];
    [myShouldRandomizeButton setIntValue:myShouldRandomize];
    [myTimeIntervalField setFloatValue:(float) myTimeInterval];
	[myBackgroundColorWell setColor:myBackgroundColor];
    [myShouldAutoAdvanceButton setIntValue:myShouldAutoAdvance];
    [myScalingMatrix selectCellWithTag:myScaling];
    [myShouldOnlyScaleDownButton setIntValue:myShouldOnlyScaleDown];
    [myDisplayFileNameMatrix selectCellWithTag:myFileNameDisplay];
    [myQualitySlider setFloatValue:myQuality];
    [myShouldPrecacheButton setIntValue:myShouldPrecache];
    [myShouldRecursivelyScanSubdirectoriesButton setIntValue:myShouldRecursivelyScanSubdirectories];
    [myFilesTable reloadData];
    [myPreview setImageScaling:myScaling];
    [myDisplayCommentButton setIntValue:myCommentDisplay];
    [myPreview setNeedsDisplay:YES];
}

- (NSDictionary*)getSavingDictionary {
    //returns an NSDictionary suitable for saving as a property list
    NSMutableDictionary* dict=[NSMutableDictionary dictionaryWithCapacity:11];
    [dict setBool:myShouldLoop forKey:@"ShouldLoop"];
    [dict setBool:myShouldRandomize forKey:@"ShouldRandom"];
    [dict setFloat:(float) myTimeInterval forKey:@"TimeInterval"];
    [dict setInt:[myDisplayModeClass tagNumber] forKey:@"DisplayMode"];
    [dict setBool:myShouldAutoAdvance forKey:@"ShouldAutoAdvance"];
    [dict setInt:myScaling forKey:@"ScalingMode"];
    [dict setBool:myShouldOnlyScaleDown forKey:@"ShouldOnlyScaleDown"];
    [dict setInt:myFileNameDisplay forKey:@"FileNameDisplayType"];
    [dict setBool:myShouldRecursivelyScanSubdirectories forKey:@"ShouldRecursivelyScanSubdirectories"];
    [dict setBool:myShouldPrecache forKey:@"PreloadImages"];
    [dict setInt:myQuality forKey:@"ImageQuality"];
    // [dict setObject:aliasIfNecessary(myFileHierarchyArray) forKey:@"ChosenFiles"];
    dict[@"BackgroundColor"] = archive(myBackgroundColor);
    [dict setInt:myCommentDisplay forKey:@"CommentDisplay"];
    dict[@"TransitionValues"] = [myTransitionChooser valueDictionary];
    return dict;
}

- (void)loadFromDictionary:(NSDictionary*)dict {
    int tag;
    NSArray* oldFiles;
    const id classes[]={[WindowShow class], [ScreenShow class], [DockShow class]};
    myShouldLoop=[dict boolForKey:@"ShouldLoop"];
    myShouldRandomize=[dict boolForKey:@"ShouldRandom"];
    myTimeInterval=[dict floatForKey:@"TimeInterval"];
    tag=[dict intForKey:@"DisplayMode"];
    myDisplayModeClass=classes[tag%numShowTypes];
    myShouldAutoAdvance=[dict boolForKey:@"ShouldAutoAdvance"];
    myScaling=[dict intForKey:@"ScalingMode"];
    myShouldOnlyScaleDown=[dict boolForKey:@"ShouldOnlyScaleDown"];
    myFileNameDisplay=[dict intForKey:@"FileNameDisplayType"];
    myShouldRecursivelyScanSubdirectories=[dict boolForKey:@"ShouldRecursivelyScanSubdirectories"];
    myShouldPrecache=[dict boolForKey:@"PreloadImages"];
    myQuality=[dict intForKey:@"ImageQuality"];
    myCommentDisplay=[dict intForKey:@"CommentDisplay"];
    if (myQuality < MINQUALITY || myQuality > MAXQUALITY) myQuality=MINQUALITY;
    oldFiles=[dict objectForKey:@"ChosenFiles"];
    myBackgroundColor=unarchive([dict objectForKey:@"BackgroundColor"]);
//    if (! oldFiles) myFileHierarchyArray=[[NSMutableArray alloc] init];
//    else myFileHierarchyArray=[[NSMutableArray alloc] initWithArray:unaliasIfNecessary(oldFiles)];
    myFileHierarchyArray=[[NSMutableArray alloc] init];
    [self loadTransitionChooser];
    [self synchronizeWindowWithValues];
}

- (void)awakeFromNib {
    NSUserDefaults* prefs=[NSUserDefaults standardUserDefaults];
    NSDictionary* prefsDict=[prefs objectForKey:@"LastSlideshow"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noteSavePreferences:)
                                                 name:NSApplicationWillTerminateNotification
                                               object:nil];
    if (prefsDict) [self loadFromDictionary:prefsDict];
    if ([prefs boolForKey:@"PreviewDrawerIsOpen"])
        [myDrawer performSelector:@selector(open:) withObject:nil afterDelay:0];

    [myFilesTable setTarget:self];
    [myFilesTable setDoubleAction:@selector(displayImageInWindow:)];
}

- (IBAction)selectFiles:(id)sender {
    NSUserDefaults* defaults=[NSUserDefaults standardUserDefaults];
    NSString* startingDirectory=[defaults stringForKey:@"DefaultImageDirectory"];
   
	// todo: look into using startingFile with the new beginSheetModalForWindow method
	//NSString* startingFile=[defaults stringForKey:@"DefaultImageFile"];
    NSOpenPanel* panel=[NSOpenPanel openPanel];
    [self showWindow];
    if (! startingDirectory) startingDirectory=NSHomeDirectory();
    [panel setAllowsMultipleSelection:YES];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
	
	[panel setDirectoryURL:[[NSURL alloc] initWithString:startingDirectory]];
	[panel setAllowedFileTypes:[NSImage imageFileTypes]];
	[panel beginSheetModalForWindow:[myFilesTable window] completionHandler:^(NSInteger returnCode)
	{
		[self openPanelDidEnd:panel returnCode:returnCode contextInfo:NULL];
	}];
	
	/* Use -beginSheetModalForWindow:completionHandler: instead.
	 Set the -directoryURL property instead of passing in a 'path'.
	 Set the -allowedFileTypes property instead of passing in the 'fileTypes'.
	 */
	//    [panel beginSheetForDirectory:startingDirectory
	//                             file:startingFile
	//                            types:[NSImage imageFileTypes]
	//                   modalForWindow:[myFilesTable window]
	//                    modalDelegate:self
	//                   didEndSelector:@selector(openPanelDidEnd: returnCode: contextInfo:)
	//                      contextInfo:nil];
}

- (void)openPanelDidEnd:(NSOpenPanel*)panel returnCode:(NSUInteger)returnCode contextInfo:(void*)contextInfo {
    NSUserDefaults* defaults=[NSUserDefaults standardUserDefaults];
    if (returnCode == NSOKButton) {
        NSArray* filesToOpen = [panel URLs];
        if ([filesToOpen count] > 0) {
            [defaults setObject:[[[filesToOpen objectAtIndex:0] absoluteString] stringByDeletingLastPathComponent] forKey:@"DefaultImageDirectory"];
            [defaults setObject:[[[filesToOpen objectAtIndex:0] absoluteString] lastPathComponent] forKey:@"DefaultImageFile"];
            [defaults synchronize];
        }
        [self processAndAddPaths:filesToOpen];
        //[myFilesTable collapseItem:nil collapseChildren:YES];
    }
}

- (void)processAndAddURLs:(NSArray*)urls {
    NSUInteger i, max=[urls count];
    [self saveUndoableState];
    for (i=0; i<max; i++) {
        [myFileHierarchyArray addObject:[urls objectAtIndex:i]];
    }
    [myFilesTable reloadData];
}

- (void)processAndAddPaths:(NSArray*)urls {
    //[myChosenFiles mergeWithArray:[self prepareFilesAndDirectories:files]];
    [self saveUndoableState];
	for (NSURL *url in urls) {
        id fileHierarchy=[FileHierarchy hierarchyWithPath:[url path]];
        [myFileHierarchyArray addObject:fileHierarchy];
    }
    [myFilesTable reloadData];
}

- (void)processAndAddFiles:(NSArray*)files {
    //[myChosenFiles mergeWithArray:[self prepareFilesAndDirectories:files]];
    long i, max=[files count];
    [self saveUndoableState];
    for (i=0; i<max; i++) {
        id fileHierarchy=[FileHierarchy hierarchyWithPath:[files objectAtIndex:i]];
        [myFileHierarchyArray addObject:fileHierarchy];
    }
    [myFilesTable reloadData];
}

- (IBAction)setDisplayMode:(id)sender {
    const id classes[]={[WindowShow class], [ScreenShow class], [DockShow class]};
    myDisplayModeClass=classes[[[sender selectedCell] tag]%numShowTypes]; // for paranoia
    [self loadTransitionChooser];
}

- (IBAction)setLoop:(id)sender {
    myShouldLoop=[sender intValue];
}

- (IBAction)setRandomOrder:(id)sender {
    myShouldRandomize=[sender intValue];
}

- (IBAction)setAutoAdvance:(id)sender {
    myShouldAutoAdvance=[sender intValue];
}

- (IBAction)setInterval:(id)sender {
    myTimeInterval=[sender doubleValue];
}

- (IBAction)setImageScaling:(id)sender {
    myScaling=[[sender selectedCell] tag]%3; //paranoia
    [myPreview setImageScaling:myScaling];
    [myPreview setNeedsDisplay:YES];
}

- (IBAction)setShouldOnlyScaleDown:(id)sender {
    myShouldOnlyScaleDown=[sender intValue];
}

- (IBAction)setShouldRecursivelyScanSubdirectories:(id)sender {
    myShouldRecursivelyScanSubdirectories=[sender intValue];
}

- (IBAction)setFileNameDisplayType:(id)sender {
    myFileNameDisplay=[[sender selectedCell] tag]%3; //paranoia
    [self redoPreviewImageName];
}

- (IBAction)setBackgroundColor:(id)sender {
    myBackgroundColor=[sender color];
    [myPreview setColor:myBackgroundColor];
    //[myPreview setNeedsDisplay:YES];
}

- (IBAction)setQualitySlider:(id)sender {
    myQuality=[sender intValue];
}

- (IBAction)setShouldPrecache:(id)sender {
    myShouldPrecache=[sender intValue];
}

- (IBAction)setCommentDisplay:(id)sender {
    myCommentDisplay=[sender intValue];
}

- (void)openSlideshow:(NSString*)path {
	NSURL *url = [[NSURL alloc] initWithString:path];
	[self openSlideshowWithUrl:url];
}

- (void)openSlideshowWithUrl:(NSURL*)url {
    NSDictionary* dict=[NSDictionary dictionaryWithContentsOfURL:url];
    if (! dict) NSBeep();
    else {
        [self loadFromDictionary:dict];
        myCurrentSavingPath=[[url absoluteString] copy];
        [[NSDocumentController sharedDocumentController]

         // todo: this was the old code, I don't know how it worked but arc didn't like it - tcurran- 2016-02-07
         //noteNewRecentDocumentURL:[NSURL fileURLWithPath:path]];
         noteNewRecentDocumentURL:[NSURL fileURLWithPath:myCurrentSavingPath]];
    }
}

- (IBAction)openDocument:(id)sender {
    NSOpenPanel* panel=[NSOpenPanel openPanel];
    NSUserDefaults* prefs=[NSUserDefaults standardUserDefaults];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setResolvesAliases:YES];
    [panel setAllowsMultipleSelection:NO];
	
	NSURL *directory = [[NSURL alloc] initWithString:[prefs objectForKey:@"DefaultSlideshowDirectory"]];
	[panel setDirectoryURL: directory];
    NSUInteger result=[panel runModal];
			
    if (result==NSOKButton) [self openSlideshowWithUrl:[[panel URLs] objectAtIndex:0]];
}

- (IBAction)saveDocument:(id)sender {
    NS_DURING
        if (! myCurrentSavingPath) [self saveDocumentAs:sender];
        else {
            NSFileManager* filer=[NSFileManager defaultManager];
            if (! [[self getSavingDictionary] writeToFile:myCurrentSavingPath atomically:YES])
                [NSException raise:@"SaveException"
                            format:@"JPEGDeux couldn't write to the path %@", myCurrentSavingPath];
            else {
                NSNumber* newCreator;
                NSDictionary* attribs;
                newCreator=[NSNumber numberWithUnsignedLong:gCreatorCode];
                attribs=[NSDictionary dictionaryWithObjectsAndKeys:
                    newCreator, NSFileHFSCreatorCode,
                    newCreator, NSFileHFSTypeCode,
                    nil];
				
				NSError *error = nil;
				[filer setAttributes:attribs ofItemAtPath:myCurrentSavingPath error:&error];
				if (error) {
                    [NSException raise:@"SaveException"
                                format:@"JPEGDeux couldn't change the type/creator code of the saved file"];
				}
            }
            [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:myCurrentSavingPath]];
        }
    NS_HANDLER
        // NSRunAlertPanel(@"Error saving file", [localException reason], @"Crud", nil, nil);

        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Error saving file";
        alert.informativeText = [localException reason];
        [alert runModal];    
    NS_ENDHANDLER
}

- (IBAction)saveDocumentAs:(id)sender {
    NSSavePanel* panel=[NSSavePanel savePanel];
    NSInteger result=[panel runModal];
    if (result==NSFileHandlingPanelOKButton) {
        myCurrentSavingPath=[[[panel URL] absoluteString] copy];
        [self saveDocument:sender];
    }
}

- (IBAction)begin:(id)sender {
    NSMutableArray* arr=[[NSMutableArray alloc] init];
    long i, max=[myFileHierarchyArray count];
    for (i=0; i<max; i++) [arr addObjectsFromArray:[FileHierarchy flattenHierarchy:[myFileHierarchyArray objectAtIndex:i]]];
    myChosenFiles=arr;
    if ([myChosenFiles count]==0) {
        NSBeep();
        return;
    }
    myTimeInterval=[myTimeIntervalField doubleValue]; //the IBAction seems unreliable
	myBackgroundColor = [myBackgroundColorWell color];

    [self savePreferenceSettings];
    myCurrentShow=[[myDisplayModeClass alloc] initWithParams:[myTransitionChooser valueDictionary]];
    NS_DURING
	
    if (myShouldOnlyScaleDown && myScaling==NSScaleProportionally) [myCurrentShow setImageScaling:ScaleDownProportionally];
    else if (myShouldOnlyScaleDown && myScaling==NSScaleToFit) [myCurrentShow setImageScaling:ScaleDownToFit];
    else [myCurrentShow setImageScaling:myScaling];
    [myCurrentShow setCommentStyle:myCommentDisplay];
    [myCurrentShow setFileNameDisplayType:myFileNameDisplay];
    [myCurrentShow beginShow:myChosenFiles];
    [myCurrentShow setQuality:myQuality];
    [myCurrentShow setBackgroundColor:myBackgroundColor];
    if (myShouldPrecache) {
		[(id)myCurrentShow preload];
	}
    NS_HANDLER
        myCurrentShow=nil;
        myChosenFiles=nil;
        return;
    NS_ENDHANDLER
    [self displayImageLoop];
    myCurrentShow=nil;
    myChosenFiles=nil;
}

- (void)noteSavePreferences:(NSNotification*)note {
    [self savePreferenceSettings];
}

- (void)savePreferenceSettings {
    NSUserDefaults* prefs=[NSUserDefaults standardUserDefaults];
    NSDictionary* dict=[self getSavingDictionary];
    [prefs setObject:dict forKey:@"LastSlideshow"];
    [prefs setBool:([myDrawer state]==NSDrawerOpenState || [myDrawer state]==NSDrawerOpeningState)
            forKey:@"PreviewDrawerIsOpen"];
    [prefs synchronize];
}

- (void)displayImageLoop {
    NSDate* date;
    const BOOL drawerIsOpen=([myDrawer state]==NSDrawerOpenState || [myDrawer state]==NSDrawerOpeningState);
    [myWindow orderOut:self];
    date=[NSDate date];
	
    @try {
        do {
            NSEvent* event=nil;
            BOOL shouldContinue=YES;
            [myCurrentShow rewind:-1];
            if (myShouldRandomize) {
				[myCurrentShow reshuffle];
			}

            while (shouldContinue) {
                NSDate* finishDate;
                CFAbsoluteTime timeOfDisplay;
                EventAction action;
                shouldContinue=[myCurrentShow advanceImage:&timeOfDisplay];

				action=eNothing;
                if (myShouldAutoAdvance) {
					finishDate=[NSDate dateWithTimeIntervalSinceReferenceDate: myTimeInterval + timeOfDisplay];
				} else {
					finishDate=[NSDate distantFuture];
				}
				
                do {
                    event=[application nextEventMatchingMask: NSAnyEventMask
                                                   untilDate:finishDate
                                                      inMode:NSDefaultRunLoopMode
                                                     dequeue:YES];
                } while (event && !(action=[self handleEvent:event]));
				
                switch (action) {
                    case eStop:
						myShouldLoop=NO;
						shouldContinue=NO;
						break;
                    case ePrev:
                        shouldContinue=YES;
                        break;
                    case eReeval:
                        //pool=[[NSAutoreleasePool alloc] init];
                        //goto reeval;
						break;
                    default: ;//this ought to shut gcc up
                }
            }
        } while (myShouldLoop);
	}
	@catch (NSException *exception) {
		// TODO: handle an exception
		//if (! [[localException name] isEqualToString:CancelShowException]) [localException raise];
	}
	
        //NSLog(@"%f", [[NSDate date] timeIntervalSinceDate:date]); //used for timing shows

        if (drawerIsOpen) [myDrawer close];
        [myWindow makeKeyAndOrderFront:self];
        if (drawerIsOpen) [myDrawer open];
}

- (EventAction)handleEvent:(NSEvent*)event {
    NSEventType type=[event type];
    //NSLog([event description]);
    if (type==NSKeyDown) {
        unichar theChar=[[event characters] characterAtIndex:0];
        id param=NULL;
        SEL sel=[myPrefsManager selectorForKey:theChar withParam:&param];
        if (theChar=='.' && ([event modifierFlags] & NSCommandKeyMask)) return eStop;
        if (sel) return [self intPerformSelector:sel withObject:param];
    }
    else if (type==NSApplicationDefined) {
        if ([event subtype]==StopSlideshowEventType)
            return eStop;
    }
    [application sendEvent:event];
    return eNothing;
}


- (BOOL)application:(NSApplication*)theApplication openFile:(NSString*)filename {
    NSFileManager* filer=[NSFileManager defaultManager];


	// TODO: this method has been replaced, figure out if we need to do something special to handle
	// the traverseLink attribute of the old method
	// NSDictionary* attribs=[filer fileAttributesAtPath:filename traverseLink:YES];
	NSError *error = nil;
	NSDictionary* attribs = [filer attributesOfItemAtPath:filename error:&error];
	
    if ([[attribs objectForKey:NSFileHFSTypeCode] unsignedIntValue] == gSSTypeCode ||
        [[filename pathExtension] caseInsensitiveCompare:@"plist"] == NSOrderedSame ||
        isPropertyList(filename)) {
        [self openSlideshow:filename];
    }
    else [self processAndAddFiles:[NSArray arrayWithObject:filename]];
    return YES;
}

- (void)recursiveSort:(NSInteger (*)(id, id, void*))func onArray:(NSMutableArray*)array {
    NSMutableDictionary* context=[NSMutableDictionary dictionary];
    [array sortUsingFunction:func context:(__bridge void * _Nullable)(context)];
    NSUInteger max=[array count];
    for (NSUInteger i=0; i < max; i++) {
        id object=[array objectAtIndex:i];
        if ([object isFolder]) {
            [self recursiveSort:func onArray:[object contents]];
        }
    }
}

- (void)recursiveSortSelected:(NSInteger (*)(id, id, void*))func onArray:(NSMutableArray*)array {
	
	NSIndexSet *indexes=[myFilesTable selectedRowIndexes];
    NSUInteger i, max;
    BOOL needToDig=NO;
    NSMutableDictionary* context=[NSMutableDictionary dictionary];
    NSMutableArray* newContents=[NSMutableArray array];
    NSMutableArray* modifiedIndices=[NSMutableArray array];

	NSUInteger row = [indexes firstIndex];
	while (row != NSNotFound) {
        id object=[myFilesTable itemAtRow:row];
        NSUInteger arrayIndex=[array indexOfObjectIdenticalTo:object];
        if (arrayIndex != NSNotFound) {
            [modifiedIndices addObject:[NSNumber numberWithUnsignedInteger:arrayIndex]];
            [newContents addObject:object];
        } else {
			needToDig=YES;
		}

		//increment
		row = [indexes indexGreaterThanIndex: row];
	}
    [newContents sortUsingFunction:func context:(__bridge void * _Nullable)(context)];
    max=[modifiedIndices count];
    for (i=0; i < max; i++) {
        unsigned index=[[modifiedIndices objectAtIndex:i] unsignedIntValue];
        [array replaceObjectAtIndex:index withObject:[newContents objectAtIndex:i]];
    }
    if (needToDig) {
        max=[array count];
        for (i=0; i<max; i++) {
            id object=[array objectAtIndex:i];
            if ([object isFolder]) [self recursiveSortSelected:func onArray:[object contents]];
        }
    }
}

- (void)saveUndoableState {
    NSMutableArray* arr=[myFileHierarchyArray deepMutableCopy];
    [myUndoer registerUndoWithTarget:self selector:@selector(undoState:) object:arr];
}

- (void)undoState:(id)object {
    [self saveUndoableState];
    [myFilesTable reloadData];
}

- (BOOL)validateMenuItem:(id)menuItem {
    SEL action=[menuItem action];
    if (action==@selector(closeWindow:)) {
        return [myWindow isVisible];
    }
    else if (action==@selector(undo:)) {
        return [myUndoer canUndo];
    }
    else if (action==@selector(redo:)) {
        return [myUndoer canRedo];
    }
    else return YES;//[super validateMenuItem:menuItem];
}

- (IBAction)undo:(id)sender {
    [myUndoer undo];
}

- (IBAction)redo:(id)sender {
    [myUndoer redo];
}

- (void)sort:(NSInteger (*)(id, id, void*))func {
    [self saveUndoableState];
    [self recursiveSort:func onArray:myFileHierarchyArray];
    [myFilesTable reloadData];
}

- (void)sortSelected:(NSInteger (*)(id, id, void*))func {
    [self saveUndoableState];
    [self recursiveSortSelected:func onArray:myFileHierarchyArray];
    [myFilesTable reloadData];
}

- (IBAction)sortName:(id)sender {
    [self sort:sortName];
}

- (IBAction)sortNumber:(id)sender {
    [self sort:sortNumber];
}

- (IBAction)sortModified:(id)sender {
    [self sort:(NSInteger (*)(id, id, void *)) sortModified];
}

- (IBAction)sortCreated:(id)sender {
    [self sort:(NSInteger (*)(id, id, void *)) sortCreated];
}

- (IBAction)sortKind:(id)sender {
    [self sort:(NSInteger (*)(id, id, void *)) sortKind];
}

- (IBAction)sortSelectedName:(id)sender {
    [self sortSelected:sortName];
}

- (IBAction)sortSelectedNumber:(id)sender {
    [self sortSelected:sortName];
}

- (IBAction)sortSelectedModified:(id)sender {
    [self sortSelected:(NSInteger (*)(id, id, void *)) sortModified];
}

- (IBAction)sortSelectedCreated:(id)sender {
    [self sortSelected:(NSInteger (*)(id, id, void *)) sortCreated];
}

- (IBAction)sortSelectedKind:(id)sender {
    [self sortSelected:(NSInteger (*)(id, id, void *)) sortKind];
}

- (IBAction)removeAllImages:(id)sender {
    [self showWindow];
    [self saveUndoableState];
    [myFileHierarchyArray removeAllObjects];
    [myFilesTable reloadData];
}

- (IBAction)flattenImageHierarchy:(id)sender {
    NSMutableArray* arr=[[NSMutableArray alloc] init];
    NSUInteger i, max=[myFileHierarchyArray count];
    [self showWindow];
    for (i=0; i<max; i++)
        [arr addObjectsFromArray:[FileHierarchy flattenHierarchy:[myFileHierarchyArray objectAtIndex:i]]];
    [self saveUndoableState];
    myFileHierarchyArray=arr;
    [myFilesTable reloadData];
}

- (void)recursiveReverseAll:(NSMutableArray*)array {
    NSUInteger i, max;
    [array reverse];
    max=[array count];
    for (i=0; i < max; i++) {
        id object=[array objectAtIndex:i];
        if ([object isFolder]) {
            [self recursiveReverseAll:[object contents]];
        }
    }
}

- (void)recursiveReverseSelected:(NSMutableArray*)array {
	NSIndexSet *indexes=[myFilesTable selectedRowIndexes];
    NSUInteger i, max;
    BOOL needToDig=NO;
    NSMutableArray* newContents=[NSMutableArray array];
    NSMutableArray* modifiedIndices=[NSMutableArray array];

	NSUInteger row = [indexes firstIndex];
	while (row != NSNotFound) {
        id object=[myFilesTable itemAtRow:row];

        NSUInteger arrayIndex=[array indexOfObjectIdenticalTo:object];
        if (arrayIndex != NSNotFound) {
            [modifiedIndices addObject:[NSNumber numberWithUnsignedInteger:arrayIndex]];
            [newContents insertObject:object atIndex:0];
        } else {
			needToDig=YES;
		}
		
		//increment
		row = [indexes indexGreaterThanIndex: row];
    }
    max=[modifiedIndices count];
    for (i=0; i < max; i++) {
        unsigned index=[[modifiedIndices objectAtIndex:i] unsignedIntValue];
        [array replaceObjectAtIndex:index withObject:[newContents objectAtIndex:i]];
    }
    if (needToDig) {
        max=[array count];
        for (i=0; i<max; i++) {
            id object=[array objectAtIndex:i];
            if ([object isFolder]) [self recursiveReverseSelected:[object contents]];
        }
    }
}

- (IBAction)reverseAllImages:(id)sender {
    [self showWindow];
    [self saveUndoableState];
    [self recursiveReverseAll:myFileHierarchyArray];
    [myFilesTable reloadData];
}

- (IBAction)reverseSelectedImages:(id)sender {
    [self showWindow];
    [self saveUndoableState];
    [self recursiveReverseSelected:myFileHierarchyArray];
    [myFilesTable reloadData];
}

- (IBAction)displayImageInWindow:(id)sender {
    NSUInteger row=[myFilesTable selectedRow];
    if (row > -1) {
        id hierarchy=[myFilesTable itemAtRow:row];
        if (hierarchy!=nil && ![hierarchy isFolder]) {
            [ImageWindowController controllerForPath:hierarchy];
        }
    }
}

- (IBAction)closeWindow:(id)sender {
    [myWindow orderOut:self];
}

@end
