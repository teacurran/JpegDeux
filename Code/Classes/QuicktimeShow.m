//
//  QuicktimeShow.m
//  JPEGDeux 2
//
//  Created by peter on Sat Jun 29 2002.
//  This code is released under the Modified BSD license
//

#import "QuicktimeShow.h"
#import "StringAdditions.h"
#import "MutableArrayCategory.h"

#define IMAX(a,b) ( (a) < (b) ? (b) : (a) )

//#define DONTDISPLAY

static inline short rectWidth(Rect rect) {
    return rect.right - rect.left;
}

static inline short rectHeight(Rect rect) {
    return rect.bottom-rect.top;
}

static inline Rect rotateRect(Rect rect) {
    Rect newRect;
    newRect.top=rect.left;
    newRect.left=rect.bottom;
    newRect.bottom=rect.right;
    newRect.right=rect.top;
    return newRect;
}

@implementation QuicktimeShow

- (id)init {
    [super init];
    myQuality=codecHighQuality;
    return self;
}

- (void)dealloc {
    if (myGWorld) DisposeGWorld(myGWorld);
    if (myImporter) CloseComponent(myImporter);
    [myImageName release];
    free(myPreloadedImporters);
    [super dealloc];
}

- (Rect)getDisplayRectForRect:(Rect)rect {
    NSLog(@"super's getDisplayRectForRect: called");
    return rect;
}

- (void)setImageName:(NSString*)name {
    [myImageName release];
    myImageName=[name retain];
}

- (void)drawImageName {
    //NSSize size=[myImageName sizeWithAttributes:nil];
    char buff[256];
    Rect rect;
    int textWidth;
    int length;
    int eraseWidth;
    [myImageName getCString:buff maxLength:255];
    length=[myImageName cStringLength];
    GetPortBounds(myGWorld, &rect);
    textWidth=TextWidth(buff, 0, length);
    if (textWidth > myOldNameWidth) eraseWidth=textWidth;
    else {
        if (myOldNameWidth > rect.right - myBlackRight) eraseWidth=textWidth;
        else eraseWidth=myOldNameWidth;
    }
    rect.left=rect.right - eraseWidth;
    rect.top=rect.bottom - myAscent - myDescent;
    MoveTo(rect.right - textWidth, rect.bottom - myDescent);
    EraseRect(&rect);
    DrawText(buff, 0, length);
    myOldNameWidth=textWidth;
}

- (void)blitImage {
    Rect rect;
    Fixed xCenter = Long2Fix(1152/2), yCenter=Long2Fix(870/2);
    FixedPoint center = {xCenter, yCenter};
    int numRots=(int)rint(myRotation / M_PI_2);
    GraphicsImportGetNaturalBounds(myImporter, &rect);
    rect = [self getDisplayRectForRect:rect];
    GraphicsImportSetDestRect(myImporter, &rect);
    if (myHFlipped || myVFlipped || numRots) {
        MatrixRecord matrix;
        GraphicsImportGetMatrix(myImporter, &matrix);
        ScaleMatrix(&matrix, Long2Fix(1-2*myHFlipped), Long2Fix(1-2*myVFlipped), xCenter, yCenter);
        if (numRots) RotateMatrix(&matrix, Long2Fix((180./M_PI)*myRotation), xCenter, yCenter);
        if (numRots & 1) {
//            Rect newRect=rect;
//            Rect newDrawingRect;
//            Fixed xScale, yScale;
            FixedPoint newCenter=center;
            TransformRect(&matrix, &rect, &newCenter);
            //newDrawingRect=[self getDisplayRectForRect:newRect];
            //xScale=FixRatio(rectWidth(newDrawingRect), rectWidth(newRect));
            //yScale=FixRatio(rectHeight(newDrawingRect), rectHeight(newRect));
            //ScaleMatrix(&matrix, xScale, yScale, xCenter, yCenter);
            //ScaleMatrix(&matrix, FixRatio(rectHeight(newRect), rectWidth(newRect)), Long2Fix(1), xCenter, yCenter);
            //NSLog(@"%@\n%@", Rect2String(rect), Rect2String(newRect));
            //RectMatrix(&matrix, &newRect, &newDrawingRect);
            //RotateMatrix(&matrix, Long2Fix((180./M_PI)*myRotation), xCenter, yCenter);
        }
        GraphicsImportSetMatrix(myImporter, &matrix);
    }
    GraphicsImportDraw(myImporter);
    if (myScaling != ScaleToFit) {
        Rect drawingRect;
        GraphicsImportGetDestRect(myImporter, &drawingRect);
        if (drawingRect.top <= myBlackTop && drawingRect.left > myBlackLeft) {
            //just blacken the sides
            Rect eraser;
            eraser.top=myBlackTop;
            eraser.bottom=myBlackBottom;
            eraser.right=drawingRect.left;
            eraser.left=myBlackLeft;
            EraseRect(&eraser);
            eraser.right=myBlackRight;
            eraser.left=drawingRect.right;
            EraseRect(&eraser);
        }
        else if (drawingRect.top > myBlackTop && drawingRect.left <= myBlackLeft) {
            //just blacken the top and bottom
            Rect eraser;
            eraser.top=myBlackTop;
            eraser.bottom=drawingRect.top;
            eraser.right=myBlackRight;
            eraser.left=myBlackLeft;
            EraseRect(&eraser);
            eraser.top=drawingRect.bottom;
            eraser.bottom=myBlackBottom;
            EraseRect(&eraser);
        }
        else if (drawingRect.top > myBlackTop && drawingRect.left > myBlackLeft) {
            //blacken all around!
            Rect eraser;
            eraser.top=myBlackTop;
            eraser.bottom=drawingRect.top;
            eraser.left=myBlackLeft;
            eraser.right=myBlackRight;
            EraseRect(&eraser);
            eraser.bottom=myBlackBottom;
            eraser.top=drawingRect.bottom;
            EraseRect(&eraser);
            eraser.right=drawingRect.left;
            eraser.top=drawingRect.top;
            eraser.bottom=drawingRect.bottom;
            EraseRect(&eraser);
            eraser.right=myBlackRight;
            eraser.left=drawingRect.right;
            EraseRect(&eraser);
        }
        myBlackTop=drawingRect.top;
        myBlackRight=drawingRect.right;
        myBlackBottom=drawingRect.bottom;
        myBlackLeft=drawingRect.left;
    }
    if (myFileNameDisplay) [self drawImageName];
    if (myLastImporter && myLastImporter != myImporter) {
        //CloseComponent(myLastImporter);
    }
    myLastImporter=myImporter;
}

- (BOOL)decompressFromFile:(NSString*)path {
    OSErr err;
    FSSpec spec;
    Rect rect;

    //chance for optimization: make these FSSpec's before hand
    if (myImporter) ;//CloseComponent(myImporter);
    myImporter=NULL;
    
    err = ! [path makeFSSpec:&spec];
    if (! err) err = GetGraphicsImporterForFile(&spec, &myImporter);
    if (! err) err = GraphicsImportSetGWorld(myImporter, myGWorld, NULL);
    if (! err) err = GraphicsImportSetQuality(myImporter, myQuality);
    if (! err) err = GraphicsImportGetNaturalBounds(myImporter, &rect);
    if (! err) rect = [self getDisplayRectForRect:rect];
    if (! err) err = GraphicsImportSetDestRect(myImporter, &rect);
    //GraphicsImportSetGraphicsMode(myImporter, ditherCopy, 0);
    return err!=noErr;
}

- (BOOL)advanceImage:(CFTimeInterval*)timeOfDisplay {
    if (myFileNameDisplay==path) [self setImageName:[myChosenFiles objectAtIndex:myCurrentImageIndex]];
    else if (myFileNameDisplay==name) [self setImageName:[[myChosenFiles objectAtIndex:myCurrentImageIndex] lastPathComponent]];
    [self blitImage];
    *timeOfDisplay=CFAbsoluteTimeGetCurrent();
    if (++myCurrentImageIndex >= [myChosenFiles count]) return NO;
    [self loadNextImage];
    return YES;
}

- (void)loadNextImage {
    BOOL success=NO;
    if (! myPreloadedImporters) {
        do {
            success=![self decompressFromFile:[myChosenFiles objectAtIndex:myCurrentImageIndex]];
        } while (! success && ++myCurrentImageIndex < [myChosenFiles count]);
    }
    else {
        do {
            myImporter=myPreloadedImporters[myCurrentImageIndex];
        } while (myImporter==nil && ++myCurrentImageIndex < [myChosenFiles count]);
    }
}

- (void)beginShow:(NSArray*)files {
    FontInfo info;
    Rect rect;
    SetGWorld(myGWorld, NULL);
    GetPortBounds(myGWorld, &rect);
    BackColor(blackColor);
    ForeColor(whiteColor);
    GetFontInfo(&info);
    myAscent=info.ascent;
    myDescent=info.descent;
    myBlackRight=rect.right;
    myBlackBottom=rect.bottom;
    [super beginShow:files];
}

- (void)reshuffle {
    unsigned seed;
    if (myPreloadedImporters) {
        seed=random();
        srandom(seed); 
    }
    [myChosenFiles shuffle];
    if (myPreloadedImporters) {
        srandom(seed);
        shuffle((void**)myPreloadedImporters, [myChosenFiles count]);
    }
    [self loadNextImage];
}

- (void)preload {
    if (myPreloadedImporters != NULL) NSLog(@"QuickTime show already preloaded");
    else {
        unsigned i, max=[myChosenFiles count];
        myPreloadedImporters=malloc(max * sizeof *myPreloadedImporters);
        if (! myPreloadedImporters) {
            NSLog(@"Out of memory!");
            exit(EXIT_FAILURE);
        }
        for (i=0; i<max; i++) {
            OSErr err;
            FSSpec spec;
            Rect rect;
            err = ! [[myChosenFiles objectAtIndex:i] makeFSSpec:&spec];
            if (! err) err = GetGraphicsImporterForFile(&spec, &myPreloadedImporters[i]);
            if (! err) err = GraphicsImportSetGWorld(myPreloadedImporters[i], myGWorld, NULL);
            if (! err) err = GraphicsImportSetQuality(myPreloadedImporters[i], myQuality);
            if (! err) err = GraphicsImportGetNaturalBounds(myPreloadedImporters[i], &rect);
            if (! err) rect = [self getDisplayRectForRect:rect];
            if (! err) err = GraphicsImportSetDestRect(myPreloadedImporters[i], &rect);
            if (err) myPreloadedImporters[i]=nil; //possible leak?
            if (err) NSLog(@"Error: %d", (int)err);
        }
    }
}

- (void)setQuality:(int)quality {
    int options[]={
        codecMinQuality,
        codecLowQuality,
        codecNormalQuality,
        codecHighQuality,
        codecMaxQuality };
    if (! (quality >= 1 && quality <= 5) ) quality=5;
    myQuality=options[quality-1];
}

- (void)redisplay {
    myCurrentImageIndex--;
    [self loadNextImage];
    [self blitImage];
    myCurrentImageIndex++;
    [self loadNextImage];
}

- (void)flipHorizontal {
    myHFlipped=!myHFlipped;
    [self redisplay];
}

- (void)flipVertical {
    myVFlipped=!myVFlipped;
    [self redisplay];
}

- (void)rotate:(int)v {
    [super rotate:v];
    [self redisplay];
}

@end