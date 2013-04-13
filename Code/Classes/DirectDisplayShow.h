//
//  DirectDisplayShow.h
//  JPEGDeux 2
//
//  Created by peter on Sat Jan 26 2002.
//  This code is released under the Modified BSD license
//

#import <Cocoa/Cocoa.h>
#import "SlideShow.h"
#if 0
#import "jpeglib.h"


//DirectDisplayShow works when linked against ijg code, but it has no real advantages

void scaleCopyFast(int** src, int srcWidth, int srcHeight, int* dst, int dstWidth, int dstHeight, int dstPixelIncrement);
void scaleCopyFast16(unsigned short** src, int srcWidth, int srcHeight, unsigned short* dst, int dstWidth, int dstHeight, int dstPixelIncrement);

@interface DirectDisplayShow : SlideShow {
    CGDirectDisplayID myDisplayID;
    struct jpeg_decompress_struct myCInfo;
    int myScreenHeight, myScreenWidth;
    int myBytesPerPixel;
    int myBlackLeft, myBlackTop;
    int myDisplayBits;
    struct SimpleNextImage {
        int height;
        int width;
        int heightCapacity;
        int widthCapacity;
        int bytesPerPixel;
        void** data;
        BOOL isValid;
    } mySimpleNextImage;
}

@end

#endif

@interface DirectDisplayShow : SlideShow {
    
}

@end