//
//  SlideShow.m
//  JPEGDeux
//
//  Created by Peter on Tue Sep 04 2001.
//

#import "SlideShow.h"
#import "MutableArrayCategory.h"
#import "Procedural.h"
#import "MyWindowController.h"
#import "CommentFinder.h"
#import "WindowMovingTextField.h"
#include <errno.h>

@implementation SlideShow

- (void)dealloc {
    [myCommentField release];
    [myCommentWindow release];
    [myChosenFiles release];
    [myNextImage release];
    [myCachedImages release];
    [myCachedImageComments release];
    [myFileComments release];
    [super dealloc];
}

- (id)initWithParams:(NSDictionary*)params {
    return [self init];
}

- (void)beginShow:(NSArray*)files {
    const unsigned int styleMask=NSBorderlessWindowMask;//NSTitledWindowMask | NSMiniaturizableWindowMask;
    myChosenFiles=[files mutableCopy];
    if (myCommentStyle==windowComment) {
        myCommentWindow=[[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 6, 6)
                                                    styleMask:styleMask
                                                      backing:NSBackingStoreBuffered
                                                        defer:NO];
        [myCommentWindow setLevel:NSFloatingWindowLevel];
        myCommentField=[[WindowMovingTextField alloc] initWithFrame:NSMakeRect(0, 0, 6, 6)];
        [myCommentField setEditable:NO];
        [myCommentField setSelectable:NO];
        [myCommentWindow setContentView:myCommentField];
        [myCommentWindow setMovableByWindowBackground:YES];
        [myCommentWindow setFrameUsingName:@"CommentWindow"];
        [myCommentWindow setFrameAutosaveName:@"CommentWindow"];
    }
}

- (void)toggleCommentWindow {
    myDontShowComment=!myDontShowComment;
    if (myDontShowComment) [myCommentWindow orderOut:self];
    else [myCommentWindow orderFront:self];
}

- (void)updateWindowComments {
    if (! myFileComments) [myCommentWindow orderOut:self];
    else {
//        NSSize size;
        [myCommentField setStringValue:myFileComments];
        [myCommentField sizeToFit];
        
        //size=[comment sizeWithAttributes:[NSDictionary dictionary]];
        //size.width+=30.0f;
        //size.height+=15.0f;
        [myCommentWindow setContentSize:[myCommentField bounds].size];
        if (!myDontShowComment) [myCommentWindow orderFront:self];
        //[myCommentField display];
    }
}

- (void)setImage:(NSImage*)image {
    NSLog(@"Error: superclass's setImage: called!");
}

- (NSSize)displaySizeForSize:(NSSize)size {
    NSLog(@"Error: superclass's displaySizeForSize: called!");
    return size;
}

- (void)setImageName:(NSString*)name {
    //we don't emit an error here because we don't require that subclasses implement me
}

- (void)setFileNameDisplayType:(FileNameDisplay)displayType {
    myFileNameDisplay=displayType;
}

//returns NO if we're all done, YES if we're still going
//records the time that the image is actually displayed in timeOfDisplay
- (BOOL)advanceImage:(CFTimeInterval*)timeOfDisplay {
    if (myNextImage==nil) {
        return NO;
    }
    if (myFileNameDisplay==path) [self setImageName:[myChosenFiles objectAtIndex:myCurrentImageIndex]];
    else if (myFileNameDisplay==name) [self setImageName:[[myChosenFiles objectAtIndex:myCurrentImageIndex] lastPathComponent]];
    [self setImage:myNextImage];
    if (myCommentStyle==windowComment) [self updateWindowComments];
    *timeOfDisplay=CFAbsoluteTimeGetCurrent();
    if (++myCurrentImageIndex >= [myChosenFiles count]) return NO;
    [myNextImage release];
    [self loadNextImage];
    return YES;
}

- (void)loadNextImage {
    [myFileComments release];
    myFileComments=nil;
    if (myCachedImages==nil) {
        const NSSize zeroSize={0,0};
        do {
            NSString* path=[myChosenFiles objectAtIndex:myCurrentImageIndex];
            if ([path hasPrefix:@"http://"]) {
                NSURL* url=[NSURL URLWithString:path];
                if (url) {
					myNextImage=[[NSImage alloc] initWithContentsOfURL:url];
					/*if (url) {
						NSURLHandle* handle=[[[[NSURLHandle URLHandleClassForURL:url] alloc] initWithURL:url cached:YES] autorelease];
						NSData* data=[handle resourceData];
						myNextImage=[[NSImage alloc] initWithData:data];
					}*/
				} else {
					myNextImage=nil;
				}
                //NSLog(@"\nPath:\t%@\nURL:\t%@\nImage:\t%@", path, url, myNextImage);
            } else {
				myNextImage=[[NSImage alloc] initWithContentsOfFile:path];
			}
            if (myNextImage==nil) {
                [myChosenFiles removeObjectAtIndex:myCurrentImageIndex--];
                continue;
            }
            if (NSEqualSizes([myNextImage size], zeroSize)) {
                [myNextImage release];
                [myChosenFiles removeObjectAtIndex:myCurrentImageIndex--];
                continue;
            }
            if (myCommentStyle) {
                myFileComments=[commentsForJPEGFile(path) componentsJoinedByString:@"\n"];
                if (! [myFileComments length]) myFileComments=nil;
                [myFileComments retain];
            }
            //[myNextImage setDataRetained:YES];
            return;
        } while (++myCurrentImageIndex < [myChosenFiles count]);
        myNextImage=nil;
    }
    else {
        myNextImage=[myCachedImages objectAtIndex:myCurrentImageIndex];
        if (myCommentStyle) {
            myFileComments=[myCachedImageComments objectAtIndex:myCurrentImageIndex];
            if (myFileComments==(id)[NSNull null]) myFileComments=nil;
            [myFileComments retain];
        }
        [myNextImage retain];
    }
}

- (NSString*)currentPath {
    return [myChosenFiles objectAtIndex:myCurrentImageIndex-1];
}

- (void)rewind:(int)count {
    if (count==-1) myCurrentImageIndex=0;
    else myCurrentImageIndex=max(myCurrentImageIndex-count, 0);
    [myNextImage release];
    [self loadNextImage];
}

- (void)redisplay {
    //what should we do here?  Hopefully this won't get called
}

- (void)flipHorizontal {

}

- (void)flipVertical {

}

- (void)reshuffle {
    unsigned seed;
    if (myCachedImages) {
        seed=random();
        srandom(seed);
    }
    [myChosenFiles shuffle];
    if (myCachedImages) {
        id old=myCachedImages;
        srandom(seed);
        myCachedImages=[[myCachedImages shuffledArray] retain];
        [old release];
    }
    if (myCachedImageComments) {
        id old=myCachedImageComments;
        srandom(seed);
        myCachedImageComments=[[myCachedImageComments shuffledArray] retain];
        [old release];
    }
    [myNextImage release];
    [self loadNextImage];
}

+ (int)tagNumber {
    NSLog(@"SlideShow's tag number called");
    return 0;
}

- (void)setCommentStyle:(CommentStyle_t)style {
    myCommentStyle=style;
}

- (void)setImageScaling:(BetterImageScaling)scaling {
    myScaling=scaling;
}

- (BetterImageScaling)imageScaling {
    return myScaling;
}

- (void)rotate:(int)v {
    myRotation = (myRotation + v*M_PI_2);
    if (myRotation >= 2*M_PI) myRotation-=2*M_PI;
}


- (void)cacheImageAtProperSize:(NSImage*)image {
    NSSize oldSize=[image size];
    NSSize newSize=[self displaySizeForSize:oldSize];
    [image setScalesWhenResized:YES];
    [image setSize:newSize];
    [image lockFocus];
    [image unlockFocus];
}

- (void)preload {
    NSApplication* app=[NSApplication sharedApplication];
    NSMutableArray* arr=[NSMutableArray array];
    NSMutableArray* comments;
    unsigned i, max=[myChosenFiles count];
    unsigned estimatedBytes;
    float estimatedMB;
    const NSSize zeroSize={0,0};
    int result;
    NSWindowController* controller;
    NSProgressIndicator* progress=nil;
    NSWindow* progressWindow;
    NSModalSession session;
    estimatedBytes=[self estimatedSizeOfCachedImages];
    estimatedMB=estimatedBytes/(float)(1<<20);
    if (estimatedMB >= WARNING_LEVEL) {
        result=NSRunAlertPanel(@"Huge Precacheing!",
                               @"JPEGDeux estimates that precacheing your %u image%s "
                               @"might take up to %.1f megabytes of RAM. "
                               @"Are you sure you wish to continue?",
                               @"Cancel", @"Continue", nil,
                               max, max==1 ? "" : "s", estimatedMB);
        if (result==NSAlertDefaultReturn)
            [NSException raise:CancelShowException format:@"Stop precacheing"];
    }
    controller=[[MyWindowController alloc] initWithWindowNibName:@"Preload"];
    progressWindow=[controller window];
    {
        NSArray* subviews=[[progressWindow contentView] subviews];
        unsigned i, max=[subviews count];
        for (i=0; i<max; i++) {
            if ([[subviews objectAtIndex:i] isKindOfClass:[NSProgressIndicator class]]) {
                progress=[subviews objectAtIndex:i];
                break;
            }
        }
    }
    NSAssert(progress!=nil, @"Couldn't find progress indicator in Preload window");
    [progress setMinValue:0];
    [progress setMaxValue:max];
    [progressWindow useOptimizedDrawing:YES];
    [progressWindow center];
    [progressWindow makeKeyAndOrderFront:self];
    NS_DURING
    session=[app beginModalSessionForWindow:progressWindow];
    if (myCommentStyle) comments=[NSMutableArray array];
    for (i=0; i<max; i++) {
        NSImage* image=nil;
        NSString* path=[myChosenFiles objectAtIndex:i];
        [app runModalSession:session];
        if ([path hasPrefix:@"http://"]) {
            NSURL* url=[NSURL URLWithString:path];
            if (url) image=[[NSImage alloc] initWithContentsOfURL:url];
        }
        else image=[[NSImage alloc] initWithContentsOfFile:path];
        if (! image || NSEqualSizes([image size], zeroSize)) {
            [myChosenFiles removeObjectAtIndex:i--];
            max--;
            [progress setMaxValue:max];
        }
        else {
            if (myCommentStyle) {
                NSArray* commentStrings=commentsForJPEGFile(path);
                NSString* commentString=[commentStrings componentsJoinedByString:@"\n"];
                if ([commentString length]) [comments addObject:commentString];
                else [comments addObject:[NSNull null]];
            }
            [self cacheImageAtProperSize:image];
            [arr addObject:image];
            [progress incrementBy:1.0];
        }
        [image release];
    }
    if (![arr count]) ;//handle no files here
    myCachedImages=[[NSArray alloc] initWithArray:arr];
    if (myCommentStyle) myCachedImageComments=[[NSArray alloc] initWithArray:comments];
    [app endModalSession:session];
    NS_HANDLER
        if (! [[localException name] isEqualToString:NSAbortModalException]) [localException raise];
        else {
            [progressWindow orderOut:self];
            [controller release];
            [NSException raise:CancelShowException format:@"Stop precacheing"];
        }
    NS_ENDHANDLER
    [progressWindow orderOut:self];
    [controller release];
}

- (void)setQuality:(int)quality {

}

- (void)setBackgroundColor:(NSColor*)color {

}

- (unsigned)estimatedSizeOfCachedImages {
    return 0;
}

@end
