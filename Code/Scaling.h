#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

NSSize rotateSize(NSSize size);
NSRect scaleToFit(NSRect viewRect, NSSize imageSize, NSRect* fillRects, unsigned* numFillRects, int numRots);
NSRect scaleNone(NSRect viewRect, NSSize imageSize, NSRect* fillRects, unsigned* numFillRects, int numRots);
NSRect scaleProportional(NSRect viewRect, NSSize imageSize, NSRect* fillRects, unsigned* numFillRects, int numRots);
Rect nsRectToRect(NSRect rect);