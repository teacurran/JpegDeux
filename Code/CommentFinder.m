//
//  CommentFinder.m
//  JPEGDeux 2
//
//  Created by Peter Ammon on Wed Nov 20 2002.
//
//  Adapted from idj's rdjpgcom.c

#import "CommentFinder.h"
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

#define M_SOI   0xD8		/* Start Of Image (beginning of datastream) */
#define M_EOI   0xD9		/* End Of Image (end of datastream) */
#define M_SOS   0xDA		/* Start Of Scan (begins compressed data) */
#define M_COM   0xFE		/* COMment */


static NSString* const JPEG_ERROR=@"";

static unsigned read_1_byte(int file) {
    unsigned char c;
    if (read(file, &c, sizeof c) != sizeof c) return UINT_MAX;
    return c;
}

static unsigned read_2_bytes(int file) {
    unsigned char c[2];
    if (read(file, c, sizeof c) != sizeof c) return UINT_MAX;
    return ((unsigned)c[0])<<8 | (unsigned)c[1];
}

//returns true on ok
static BOOL skip_variable(int file)
/* Skip over an unknown or uninteresting variable-length marker
   Returns true on success, false for an I/O error
*/
{
    unsigned int length;

    /* Get the marker parameter length count */
    length = read_2_bytes(file);
    if (length==UINT_MAX || length < 2) return NO;
    /* Skip over the remaining bytes */
    if (lseek(file, length-2, SEEK_CUR)==-1) return NO;
    return YES;
}

static NSString* process_COM(int file) {
    unsigned length;
    /* Get the marker parameter length count */
    length = read_2_bytes(file);
    if (length==UINT_MAX || length < 2) return JPEG_ERROR;
    /* length includes itself, so must be at least 2 */
    length-=2;
    if (length > 0) {
        unsigned i;
        unsigned translateIndex=0;
        int lastch=0;
        char* indata = alloca(length);
        char* translatedString=alloca(length+1);
        if (! indata || ! translatedString) return JPEG_ERROR;
        if (read(file, indata, length) != length) return JPEG_ERROR;
        for (i=0; i<length; i++) {
            char ch=indata[i];
            /* Emit the character in a readable form.
             * munge linebreaks correctly, print unknowns as ?
            */
            if (ch=='\r') translatedString[translateIndex++]='\n';
            else if (ch=='\n') {
                if (lastch != '\r') translatedString[translateIndex++]='\n';
            }
            else if (isprint(ch)) translatedString[translateIndex++]=ch;
            else translatedString[translateIndex++]='?';
        }
		
		return [[NSString alloc] initWithBytes:translatedString length:translateIndex encoding:NSASCIIStringEncoding];
    }
    return nil;
}

static inline BOOL first_marker(const int file) {
    unsigned char c[2];
    if (read(file, c, sizeof c) != sizeof c) return NO;
    return c[0]==0xFF && c[1]==M_SOI;
}

static inline int next_marker(const int file) {
    int c;
    int discarded_bytes=-1;
    do {
        c=read_1_byte(file);
        discarded_bytes++;
    } while (c != 0xFF);
    /* Get marker code byte, swallowing any duplicate FF bytes.  Extra FFs
     * are legal as pad bytes, so don't count them in discarded_bytes.
     */
    do {
        c=read_1_byte(file);
    } while (c==0xFF);
    if (discarded_bytes != 0) {
        fprintf(stderr, "Warning: garbage data found in JPEG file\n");
    }
    return c;
}

static NSArray* scan_JPEG_header(int file) {
    NSMutableArray* result=nil;
    if (first_marker(file)) {
        int marker;
        for (;;) {
            marker=next_marker(file);
            switch(marker) {

                case M_SOS:			/* stop before hitting compressed data */
                case M_EOI:			/* in case it's a tables-only JPEG stream */
                    goto finished;
                    
                case M_COM:
                {
                    NSString* comment;
                    if (! result) result=[NSMutableArray arrayWithCapacity:1];
                    comment=process_COM(file);
                    if (comment != JPEG_ERROR) [result addObject:comment];
                }
                    break;
                    
                default:
                    if (! skip_variable(file)) goto finished;
                    break;
            }
        }
    }
finished:
        return result; 
}

NSArray* commentsForJPEGFile(NSString* path) {
    NSArray* result=nil;
    NSFileHandle* fileHandle=[NSFileHandle fileHandleForReadingAtPath:path];
    if (fileHandle) {
        int file=[fileHandle fileDescriptor];
        result=scan_JPEG_header(file);
       [fileHandle closeFile];
    }
    return result;
}
