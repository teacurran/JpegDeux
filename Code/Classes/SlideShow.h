//
//  SlideShow.h
//  JPEGDeux
//
//  Created by Peter on Tue Sep 04 2001.
//

#import <Cocoa/Cocoa.h>
#import "PetersTypes.h"

//JPEGDeux will warn at this number of MB for precacheing
#define WARNING_LEVEL 75.

@interface SlideShow : NSObject {
    BOOL myDontShowComment;
    NSWindow* myCommentWindow;
    NSTextField* myCommentField;
    CommentStyle_t myCommentStyle;
    NSMutableArray* myChosenFiles;
    int myCurrentImageIndex;
    NSImage* myNextImage;
    NSArray* myCachedImages;
    NSArray* myCachedImageComments;
    BetterImageScaling myScaling;
    FileNameDisplay myFileNameDisplay;
    float myRotation;
    NSString* myFileComments;
}

//currently recognized params: FadeTransition => NSValue of should fade
- (id)initWithParams:(NSDictionary*)params;

- (void)beginShow:(NSArray*)files;
- (BOOL)advanceImage:(CFTimeInterval*)timeOfDisplay;
- (void)loadNextImage;
- (void)rewind:(int)count;
- (void)reshuffle;

- (void)toggleCommentWindow;

- (void)rotate:(int)v;

- (NSString*)currentPath;

- (void)setImageScaling:(BetterImageScaling)scaling;
- (BetterImageScaling)imageScaling;

- (void)setCommentStyle:(CommentStyle_t)style;

- (void)setFileNameDisplayType:(FileNameDisplay)displayType;

- (NSSize)displaySizeForSize:(NSSize)size;

+ (int)tagNumber;

//SlideShow just ignores, subclasses can override
- (void)setBackgroundColor:(NSColor*)color;
- (void)redisplay;
- (void)flipHorizontal;
- (void)flipVertical;

//subclasses can override
- (unsigned)estimatedSizeOfCachedImages;

//SlideShow just ignores, QuicktimeShow makes use
- (void)setQuality:(int)quality;

- (void)preload;


@end
