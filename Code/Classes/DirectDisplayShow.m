//
//  DirectDisplayShow.m
//  JPEGDeux 2
//
//  Created by peter on Sat Jan 26 2002.
//  This code is released under the Modified BSD license
//

//#define DONTDISPLAY

#import "DirectDisplayShow.h"
#import "Procedural.h"

#if 0

struct my_error_mgr {
  struct jpeg_error_mgr pub;	/* "public" fields */
  jmp_buf setjmp_buffer;	/* for return to caller */
};

typedef struct my_error_mgr * my_error_ptr;

/* JPEG decompressor error handler */
static void my_error_exit (j_common_ptr cinfo);

static void blitBlack(int* dst, int dstWidth, int dstHeight, int dstPixelIncrement);

static void myIZero(int* b, int len);

static struct my_error_mgr jerr;

@implementation DirectDisplayShow

- (id)init {
    [super init];
    jpeg_create_decompress(&myCInfo);
    /* We set up the normal JPEG error routines, then override error_exit. */
    myCInfo.err = jpeg_std_error(&jerr.pub);
    jerr.pub.error_exit = my_error_exit;
    return self;
}

- (void)setupSimpleNextImageHeight:(int)height width:(int)width bytesPerPixel:(int)bytesPerPixel {
    int i;
    mySimpleNextImage.bytesPerPixel=bytesPerPixel;
    mySimpleNextImage.heightCapacity=height;
    mySimpleNextImage.widthCapacity=width;
    mySimpleNextImage.data=malloc(mySimpleNextImage.heightCapacity * sizeof *mySimpleNextImage.data);
    if (! mySimpleNextImage.data) fatalError(@"Out of memory!");
    for (i=0; i<mySimpleNextImage.heightCapacity; i++) {
        mySimpleNextImage.data[i]=malloc(bytesPerPixel*mySimpleNextImage.widthCapacity);
        if (! mySimpleNextImage.data[i]) fatalError(@"Out of memory!");
    }
}

- (void)teardownSimpleNextImage {
    int i;
    for (i=0; i<mySimpleNextImage.heightCapacity; i++) {
        free(mySimpleNextImage.data[i]);
    }
    free(mySimpleNextImage.data);
}


- (void)dealloc {
    jpeg_destroy_decompress(&myCInfo);
    if (CGDisplayIsCaptured(myDisplayID)) {
        CGDisplayRelease(myDisplayID);
    }
    [self teardownSimpleNextImage];
    [super dealloc];
}

- (void)beginShow:(NSArray*)files {
    CGDisplayErr err;
    CGDisplayCount count=1;
    NSDictionary* dict;
    
    err=CGGetActiveDisplayList(1, &myDisplayID, &count);
    if (err != CGDisplayNoErr) {
        fprintf(stderr, "CG Display error %d", (int)err);
        exit(EXIT_FAILURE);
    }
    if (CGDisplayIsCaptured(myDisplayID)) {
        fprintf(stderr, "Main display is already captured!");
        exit(EXIT_FAILURE);
    }
#ifndef DONTDISPLAY
    err=CGDisplayCapture(myDisplayID);
#endif
    if (err != CGDisplayNoErr) {
        fprintf(stderr, "CG Display error %d", (int)err);
        exit(EXIT_FAILURE);
    }
    dict=(NSDictionary*)CGDisplayCurrentMode(myDisplayID);
    myScreenWidth=[[dict objectForKey:(NSString*)kCGDisplayWidth] intValue];
    myScreenHeight=[[dict objectForKey:(NSString*)kCGDisplayHeight] intValue];
    myBytesPerPixel=[[dict objectForKey:(NSString*)kCGDisplayBitsPerPixel] intValue]/CHAR_BIT;
    myDisplayBits=myBytesPerPixel*CHAR_BIT;
    NSAssert1(myDisplayBits==16 || myDisplayBits==32, @"Strange display bits %d", myDisplayBits);
    [self setupSimpleNextImageHeight:myScreenHeight width:myScreenWidth bytesPerPixel:myBytesPerPixel];
    [super beginShow:files];
}

- (void)blitImage {
    int* base=CGDisplayBaseAddress(myDisplayID);
    int increment=(int*)CGDisplayAddressForPosition(myDisplayID, 0, 1)-base;
    const int srcHeight=mySimpleNextImage.height;
    const int srcWidth=mySimpleNextImage.width;
    switch (myScaling) {
        case ScaleProportionally: {
            int dstWidth, dstHeight, startingX, startingY;
            if (srcHeight*myScreenWidth > srcWidth*myScreenHeight) { //image is too tall
                dstHeight=myScreenHeight;
                dstWidth=(srcWidth*myScreenHeight)/srcHeight;
                startingX=(myScreenWidth-dstWidth)/2;
                startingY=0;
                if (myBlackLeft < (myScreenWidth-dstWidth)/2) {
                    if (myDisplayBits==32) {
                        blitBlack(base+myBlackLeft, (myScreenWidth-dstWidth)/2-myBlackLeft, myScreenHeight, increment);
                        blitBlack(base+(myScreenWidth+dstWidth)/2-myBlackLeft, (myScreenWidth-dstWidth+1)/2, myScreenHeight, increment);
                    }
                    else {
                        blitBlack(base+myBlackLeft/2, ((myScreenWidth-dstWidth)/2-myBlackLeft)/2, myScreenHeight, increment);
                        blitBlack(base+((myScreenWidth+dstWidth)/2-myBlackLeft)/2, (myScreenWidth-dstWidth+1)/4, myScreenHeight, increment);
                    }
                }
                myBlackLeft=(myScreenWidth-dstWidth)/2;
                myBlackTop=0;
            }
            else { //image is too wide
                dstWidth=myScreenWidth;
                dstHeight=(srcHeight*myScreenWidth)/srcWidth;
                startingX=0;
                startingY=(myScreenHeight-dstHeight)/2;
                if (myBlackTop < (myScreenHeight-dstHeight)/2) {
                    if (myDisplayBits==32) {
                        blitBlack(base+myBlackTop*increment, myScreenWidth, (myScreenHeight-dstHeight)/2-myBlackTop, increment);
                        blitBlack(base+increment*((myScreenHeight+dstHeight)/2-myBlackTop), myScreenWidth, (myScreenHeight-dstHeight+1)/2-myBlackTop, increment);
                    }
                    else {
                        blitBlack(base+myBlackTop*increment/2, myScreenWidth/2, (myScreenHeight-dstHeight)/2-myBlackTop, increment);
                        blitBlack(base+increment*((myScreenHeight+dstHeight)/2-myBlackTop)/2, myScreenWidth/2, (myScreenHeight-dstHeight+1)/2-myBlackTop, increment);
                    }
                }
                myBlackLeft=0;
                myBlackTop=(myScreenHeight-dstHeight)/2;
            }

            if (myDisplayBits==32) scaleCopyFast((int**)mySimpleNextImage.data, srcWidth, srcHeight, CGDisplayAddressForPosition(myDisplayID, startingX, startingY), dstWidth, dstHeight, increment);
            else scaleCopyFast16((unsigned short**)mySimpleNextImage.data, srcWidth, srcHeight, CGDisplayAddressForPosition(myDisplayID, startingX, startingY), dstWidth, dstHeight, increment);
            break;
        }
        
        case NSScaleToFit: {
            if (myDisplayBits==32) scaleCopyFast((int**)mySimpleNextImage.data, srcWidth, srcHeight, base, myScreenWidth, myScreenHeight, myScreenWidth);
            else scaleCopyFast16((unsigned short**)mySimpleNextImage.data, srcWidth, srcHeight, (unsigned short*)base, myScreenWidth, myScreenHeight, myScreenWidth/2);
            break;
        }
        
        case ScaleNone: {
            float xSpace=(myScreenWidth - srcWidth)/2.0;
            float ySpace=(myScreenHeight - srcHeight)/2.0;
            int imgWidth, imgHeight;
            float imageStartingX, imageStartingY;
            if (xSpace < 0 && ySpace >= 0) { //space on bottom and top, not sides
                blitBlack(base, myScreenWidth, ySpace, increment);
                blitBlack(base+increment*(myScreenHeight-(int)ySpace), myScreenWidth, ySpace, increment);
                imgWidth=myScreenWidth;
                imgHeight=srcHeight;
            }
            else if (xSpace >= 0 && ySpace < 0) { //space on sides, not bottom and top
                blitBlack(base, xSpace, myScreenHeight, increment);
                blitBlack(base+increment-(int)xSpace, xSpace, myScreenHeight, increment);
                imgWidth=srcWidth;
                imgHeight=myScreenHeight;
            }
            else if (xSpace > 0 && ySpace > 0) { //image is too small all around
                blitBlack(base, myScreenWidth, ySpace+1, increment);
                
                NSRectFill(NSMakeRect(0, 0, myScreenWidth, ySpace+1)); //bottom, we add 1 because of ugly round off otherwise
                NSRectFill(NSMakeRect(0, myScreenHeight-ySpace, myScreenWidth, ySpace)); //top
                NSRectFill(NSMakeRect(0, ySpace, xSpace+1, .5f+myScreenHeight-2.0f*ySpace)); //left
                NSRectFill(NSMakeRect(myScreenWidth-xSpace, ySpace, xSpace, .5f+myScreenHeight-2.0f*ySpace)); //right
                imgWidth=srcWidth;
                imgHeight=srcHeight;
            }
           //if (myDisplayBits==32) scaleCopyFast((int**)mySimpleNextImage.data, imgWidth, imgHeight, CGDisplayAddressForPosition(myDisplayID, xSpace, ySpace), imgWidth, imgHeight, increment);
            
            return;
        }
        default:;
    }
    //NSLog(@"Blitted!");
}

//returns NO if we're all done, YES if we're still going
//records the time that the image is actually displayed in timeOfDisplay
- (BOOL)advanceImage:(CFTimeInterval*)timeOfDisplay {
    if (! mySimpleNextImage.isValid) {
        NSLog(@"Image is not valid");
        return NO;
    }
    //if (myFileNameDisplay==path) [self setImageName:[myChosenFiles objectAtIndex:myCurrentImageIndex]];
    //else if (myFileNameDisplay==name) [self setImageName:[[myChosenFiles objectAtIndex:myCurrentImageIndex] lastPathComponent]];
    [self blitImage];
    *timeOfDisplay=CFAbsoluteTimeGetCurrent();
    if (++myCurrentImageIndex >= [myChosenFiles count]) return NO;
    [self loadNextImage];
    return YES;
}


//returns 0 if there was no error, nonzero otherwise
- (BOOL)decompressJPEGFromFile:(NSString*)path {
    const char* cPath=[path fileSystemRepresentation];
    FILE* infile;
    int i=0;
    if (! cPath) return 1;
    infile=fopen(cPath, "rb");
    if (! infile) return 1;
    

    /* Establish the setjmp return context for my_error_exit to use. */
    if (setjmp(jerr.setjmp_buffer)) {
        /* If we get here, the JPEG code has signaled an error.
        * We need to clean up the JPEG object, close the input file, and return.
        */
        fclose(infile);
        return 1;
    }
    jpeg_stdio_src(&myCInfo, infile);
    jpeg_read_header(&myCInfo, TRUE);
    
    if (myDisplayBits==16) {
        myCInfo.output_components=2;
        myCInfo.out_color_space=JCS_16ARGB;
    }
    else {
        myCInfo.output_components=4;
        myCInfo.out_color_space=JCS_ARGB;
    }
    //myCInfo.scale_num=1;
    //myCInfo.scale_denom=1;
    jpeg_calc_output_dimensions(&myCInfo);
    
    if (myScaling!=ScaleNone && (myCInfo.output_width > myScreenWidth*2 || myCInfo.output_height > myScreenHeight*2)) {
        if (myCInfo.output_width >= 8*myScreenWidth || myCInfo.output_height >= 8*myScreenHeight)
            myCInfo.scale_denom=8;
        else if (myCInfo.output_width >= 4*myScreenWidth || myCInfo.output_height >= 4*myScreenHeight)
            myCInfo.scale_denom=4;
        else myCInfo.scale_denom=2;
        jpeg_calc_output_dimensions(&myCInfo);
    }
    jpeg_start_decompress(&myCInfo);
    
    if (myCInfo.output_height > mySimpleNextImage.heightCapacity || myCInfo.output_width > mySimpleNextImage.widthCapacity) {
        [self teardownSimpleNextImage];
        [self setupSimpleNextImageHeight:myCInfo.output_height width:myCInfo.output_width bytesPerPixel:myDisplayBits/CHAR_BIT];
    }
    mySimpleNextImage.width=myCInfo.output_width;
    mySimpleNextImage.height=myCInfo.output_height;
    while (myCInfo.output_scanline < myCInfo.output_height) {
        i+=jpeg_read_scanlines(&myCInfo, (JSAMPARRAY)(mySimpleNextImage.data+myCInfo.output_scanline), myCInfo.output_height);
    };
    jpeg_finish_decompress(&myCInfo);
    fclose(infile);
    myCInfo.scale_num=myCInfo.scale_denom=1;
    return 0;
}

- (void)loadNextImage {
    BOOL success=NO;
    do {
        success=![self decompressJPEGFromFile:[myChosenFiles objectAtIndex:myCurrentImageIndex]];
    } while (! success && ++myCurrentImageIndex < [myChosenFiles count]);
    mySimpleNextImage.isValid=success;
}

+ (int)tagNumber {
    return 3;
}

@end


/*
 * Here's the routine that will replace the standard error_exit method:
 */

static void my_error_exit (j_common_ptr cinfo) {
  /* cinfo->err really points to a my_error_mgr struct, so coerce pointer */
  my_error_ptr myerr = (my_error_ptr) cinfo->err;

  /* Always display the message. */
  /* We could postpone this until after returning, if we chose. */
  (*cinfo->err->output_message) (cinfo);

  /* Return control to the setjmp point */
  longjmp(myerr->setjmp_buffer, 1);
}

#if 0

static void scaleCopyFastOld(int** src, int srcWidth, int srcHeight, int* dst, int dstWidth, int dstHeight, int dstPixelIncrement) {
    int h;
    for (h=0; h<dstHeight; h++) {
        int w;
        for (w=0; w<dstWidth; w++) {
            *(dst+h*dstPixelIncrement+w)=src[(h*srcHeight)/dstHeight][(w*srcWidth)/dstWidth];
        }
    }
}

static void scaleCopyFast16Old(unsigned short** src, int srcWidth, int srcHeight, unsigned short* dst, int dstWidth, int dstHeight, int dstPixelIncrement) {
    int h;
    dstPixelIncrement*=2; //convert from int ptr to short ptr
    for (h=0; h<dstHeight; h++) {
        int w;
        for (w=0; w<dstWidth; w++) {
            *(dst+h*dstPixelIncrement+w)=src[(h*srcHeight)/dstHeight][(w*srcWidth)/dstWidth];
        }
    }
}

#endif

static void blitBlack(int* dst, int dstWidth, int dstHeight, int dstPixelIncrement) {
    if (dstWidth==dstPixelIncrement) {
        myIZero(dst, dstWidth*dstHeight);
    }
    else {
        int h;
        for (h=0; h<dstHeight; h++) {
            myIZero(dst+h*dstPixelIncrement, dstWidth);
        }
    }
}

/*
 * r3: b
 * r4: len
 
static void myIZeroFast(int* b, int len) {
    asm volatile(
        "slwi	ctr,r4,2\n" //multiply len by the size of an int
        :
        :
    );
}
*/

static void myIZero(int* b, int len) {
    int i;
    for (i=0; i<len; i++) b[i]=0;
}

#endif

@implementation DirectDisplayShow

@end
