.text
.globl _scaleCopyLinearFast
.globl _scaleCopyFast
.globl _scaleCopyFast16

/*
 3: src
 4: srcWidth
 5: srcHeight
 6: dst
 7: dstWidth
 8: dstHeight
 9: srcPixelIncrement originally, soon h loop counter
 10: dstPixelIncrement

 0: pixelIncrement, adjusted by width
 10: w loop counter
 11: (w*srcWidth)/dstWidth, then src[(h*srcHeight)/dstHeight][(w*srcWidth)/dstWidth]
 12: (h*srcHeight)/dstHeight, then src[(h*srcHeight)/dstHeight]

 non-volatile (remember to save)
 13:
 14:
 */

/*
   void scaleCopyLinearFast(int* src, int srcWidth, int srcHeight, int* dst, int dstWidth, int dstHeight, int srcPixelIncrement, int dstPixelIncrement);
*/

_scaleCopyLinearFast:
mr	r0,r10		/* puts dstPixelIncrement in r0 so we can use r9 for a loop counter */
sub	r0,r0,r7	/* subtracts dstWidth from pixelIncrement */
slwi	r0,r0,2		/* premultiplies pixelIncrement by the size of an int */
li	r2,0		/* sets r2 to 0 (this will count up to dstHeight) <--h */
slwi    r9,r9,2	/* multiplies rowbytes by the size of an int */
loutlp:  li	r10,0		/* sets r10 to 0 (this will count up to dstWidth) <--w */
mullw	r12,r2,r5	/* multiplies h by srcHeight and stores it in r12 */
divwu	r12,r12,r8	/* divides r12 by dstHeight */
//slwi	r12,r12,2	/* multiplies r12 by the size of an int */
mullw   r12,r12,r9	/* multiplies r12 by rowBytes */
linlp:   mullw	r11,r10,r4	/* multiplies w by srcWidth and stores it in r11 */
addi	r10,r10,1	/* increments w (we do this way up here for the branch prediction) */
cmpw	r10,r7		/* compares w to dstWidth */
divwu	r11,r11,r7	/* divides r11 by dstWidth */
slwi	r11,r11,2	/* multiplies r11 by the size of an int */
add	r11,r11,r12	/* Adds r12 to r11.  r12 stores the offset to this row */
lwzx	r11,r3,r11	/* loads src[h*height/myScreenHeight)*rowBytes+w*width/myScreenWidth] into r11 */
stw	r11,0(r6)	/* stores r11 into dst */
addi	r6,r6,4		/* add four to dst */
bne	linlp		/* branches back to inloop if w != dstWidth */
addi	r2,r2,1		/* increments h */
cmpw	r2,r8		/* compares h to dstHeight */
add	r6,r6,r0	/* adds pixelIncrement to dst */
bne	loutlp		/* branches back to outloop if h != dstHeight */
blr			/* and back we go */

/*
    3: src
    4: srcWidth
    5: srcHeight
    6: dst
    7: dstWidth
    8: dstHeight
    9: pixelIncrement originally, soon h loop counter
    
    0: pixelIncrement, adjusted by width
    10: w loop counter
    11: (w*srcWidth)/dstWidth, then src[(h*srcHeight)/dstHeight][(w*srcWidth)/dstWidth]
    12: (h*srcHeight)/dstHeight, then src[(h*srcHeight)/dstHeight]
    
    non-volatile (remember to save)
    13:
    14:
*/

_scaleCopyFast:
        mr	r0,r9		/* puts pixelIncrement in r0 so we can use r9 for a loop counter */
        sub	r0,r0,r7	/* subtracts dstWidth from pixelIncrement */
        slwi	r0,r0,2		/* premultiplies pixelIncrement by the size of an int */
        li	r9,0		/* sets r9 to 0 (this will count up to dstHeight) <--h */ 
outlp:  li	r10,0		/* sets r10 to 0 (this will count up to dstWidth) <--w */
        mullw	r12,r9,r5	/* multiplies h by srcHeight and stores it in r12 */
        divwu	r12,r12,r8	/* divides r12 by dstHeight */
        slwi	r12,r12,2	/* multiplies r12 by the size of an int */
        lwzx	r12,r3,r12	/* loads src[(h*srcHeight)/dstHeight] into r12 */
inlp:   mullw	r11,r10,r4	/* multiplies w by srcWidth and stores it in r11 */
        addi	r10,r10,1	/* increments w (we do this way up here for the branch prediction) */
        cmpw	r10,r7		/* compares w to dstWidth */
        divwu	r11,r11,r7	/* divides r11 by dstWidth */
        slwi	r11,r11,2	/* multiplies r11 by the size of an int */
        lwzx	r11,r12,r11	/* loads src[(h*srcHeight)/dstHeight][(w*srcWidth)/dstWidth] into r11 */
        stw	r11,0(r6)	/* stores r11 into dst */
        addi	r6,r6,4		/* add four to dst */
        bne	inlp		/* branches back to inloop if w != dstWidth */
        addi	r9,r9,1		/* increments h */
        cmpw	r9,r8		/* compares h to dstHeight */
        add	r6,r6,r0	/* adds pixelIncrement to dst */
        bne	outlp		/* branches back to outloop if h != dstHeight */
        blr			/* and back we go */

/*
    3: src
    4: srcWidth
    5: srcHeight
    6: dst
    7: dstWidth
    8: dstHeight
    9: pixelIncrement originally, soon h loop counter
    
    0: pixelIncrement, adjusted by width
    10: w loop counter
    11: (w*srcWidth)/dstWidth, then src[(h*srcHeight)/dstHeight][(w*srcWidth)/dstWidth]
    12: (h*srcHeight)/dstHeight, then src[(h*srcHeight)/dstHeight]
    
    non-volatile (remember to save)
    13:
    14:
*/

_scaleCopyFast16:
        mr	r0,r9		/* puts pixelIncrement in r0 so we can use r9 for a loop counter */
        sub	r0,r0,r7	/* subtracts dstWidth from pixelIncrement */
        slwi	r0,r0,1		/* premultiplies pixelIncrement by the size of a short */
        li	r9,0		/* sets r9 to 0 (this will count up to dstHeight) <--h */
outlp16:li	r10,0		/* sets r10 to 0 (this will count up to dstWidth) <--w */
        mullw	r12,r9,r5	/* multiplies h by srcHeight and stores it in r12 */
        divwu	r12,r12,r8	/* divides r12 by dstHeight */
        slwi	r12,r12,2	/* multiplies r12 by the size of an int */
        lwzx	r12,r3,r12	/* loads src[(h*srcHeight)/dstHeight] into r12 */
inlp16: mullw	r11,r10,r4	/* multiplies w by srcWidth and stores it in r11 */
        addi	r10,r10,1	/* increments w (we do this way up here for the branch prediction) */
        cmpw	r10,r7		/* compares w to dstWidth */
        divwu	r11,r11,r7	/* divides r11 by dstWidth */
        slwi	r11,r11,1	/* multiplies r11 by the size of a short */
        lhzx	r11,r12,r11	/* loads src[(h*srcHeight)/dstHeight][(w*srcWidth)/dstWidth] into r11 */
        sth	r11,0(r6)	/* stores r11 into dst */
        addi	r6,r6,2		/* add 2 to dst */
        bne	inlp16		/* branches back to inloop if w != dstWidth */
        addi	r9,r9,1		/* increments h */
        cmpw	r9,r8		/* compares h to dstHeight */
        add	r6,r6,r0	/* adds pixelIncrement to dst */
        bne	outlp16		/* branches back to outloop if h != dstHeight */