#import "Scaling.h"

Rect nsRectToRect(NSRect rect) {
    Rect newRect={NSMaxY(rect), NSMaxX(rect), NSMinY(rect), NSMinX(rect) };
    return newRect;
}

NSSize rotateSize(NSSize size) {
    float temp;
    temp=size.width;
    size.width=size.height;
    size.height=temp;
    return size;
}

NSRect scaleToFit(NSRect viewRect, NSSize imageSize, NSRect* fillRects, unsigned* numFillRects, int numRots) {
    NSRect drawingRect=viewRect;
    *numFillRects=0;
    if (numRots & 1) {
        drawingRect.size.height *= NSWidth(viewRect) / NSHeight(viewRect);
        drawingRect.size.width *= NSHeight(viewRect) / NSWidth(viewRect);
        drawingRect.origin.x = (NSWidth(viewRect) - NSWidth(drawingRect))/2.;
        drawingRect.origin.y = (NSHeight(viewRect) - NSHeight(drawingRect))/2.;
    }
    return drawingRect;
}

NSRect scaleNone(NSRect viewRect, NSSize imageSize, NSRect* fillRects, unsigned* numFillRects, int numRots) {
    NSRect drawingRect={ { 0, 0 }, imageSize };
    float hSpace, vSpace;
    if (numRots & 1) {
        hSpace=(NSHeight(viewRect) - NSWidth(drawingRect))/2;
        vSpace=(NSWidth(viewRect) - NSHeight(drawingRect))/2;
        if (vSpace > 0 && hSpace > 0) {
            fillRects[0]=NSMakeRect(0, (NSHeight(viewRect) - NSWidth(viewRect))/2, NSWidth(viewRect), vSpace+1);
            fillRects[1]=NSMakeRect(0, (NSHeight(viewRect) - NSWidth(viewRect))/2 + vSpace + imageSize.height, NSWidth(viewRect), vSpace+1);
            fillRects[2]=NSMakeRect((NSWidth(viewRect) - NSHeight(viewRect))/2, (NSHeight(viewRect) - NSWidth(viewRect))/2 + vSpace,
                                    hSpace+1, imageSize.height);
            fillRects[3]=NSMakeRect((NSWidth(viewRect) - NSHeight(viewRect))/2 + hSpace + imageSize.width,
                                    (NSHeight(viewRect) - NSWidth(viewRect))/2 + vSpace, hSpace+1, imageSize.height);
            *numFillRects=4;
        }
        else if (vSpace > 0) {
            fillRects[0]=NSMakeRect(0, (NSHeight(viewRect) - NSWidth(viewRect))/2, NSWidth(viewRect), vSpace+1);
            fillRects[1]=NSMakeRect(0, (NSHeight(viewRect) - NSWidth(viewRect))/2 + vSpace + imageSize.height, NSWidth(viewRect), vSpace+1);
            *numFillRects=2;
        }
        else if (hSpace > 0) {
            fillRects[0]=NSMakeRect((NSWidth(viewRect) - NSHeight(viewRect))/2, (NSHeight(viewRect) - NSWidth(viewRect))/2, hSpace+1, NSWidth(viewRect));
            fillRects[1]=NSMakeRect((NSWidth(viewRect) - NSHeight(viewRect))/2 + hSpace + imageSize.width, (NSHeight(viewRect) - NSWidth(viewRect))/2,
                                    hSpace+1, NSWidth(viewRect));
            *numFillRects=2;
        }
        else *numFillRects=0;
    }
    else {
        vSpace=(NSHeight(viewRect) - NSHeight(drawingRect))/2;
        hSpace=(NSWidth(viewRect) - NSWidth(drawingRect))/2;
        if (vSpace > 0 && hSpace > 0) {
            fillRects[0]=NSMakeRect(0, 0, NSWidth(viewRect), vSpace+1);
            fillRects[1]=NSMakeRect(0, vSpace + imageSize.height, NSWidth(viewRect), vSpace+1);
            fillRects[2]=NSMakeRect(0, vSpace, hSpace+1, imageSize.height);
            fillRects[3]=NSMakeRect(hSpace+imageSize.width, vSpace, hSpace+1, imageSize.height);
            *numFillRects=4;
        }
        else if (vSpace > 0) {
            fillRects[0]=NSMakeRect(0, 0, NSWidth(viewRect), vSpace+1);
            fillRects[1]=NSMakeRect(0, vSpace + imageSize.height, NSWidth(viewRect), vSpace+1);
            *numFillRects=2;
        }
        else if (hSpace > 0) {
            fillRects[0]=NSMakeRect(0, 0, hSpace+1, NSHeight(viewRect));
            fillRects[1]=NSMakeRect(hSpace + imageSize.width, 0, hSpace+1, NSHeight(viewRect));
            *numFillRects=2;
        }
        else *numFillRects=0;
    }
    drawingRect.origin.x = (NSWidth(viewRect) - NSWidth(drawingRect))/2;
    drawingRect.origin.y = (NSHeight(viewRect) - NSHeight(drawingRect))/2.;
    return drawingRect;
}

NSRect scaleProportional(NSRect viewRect, NSSize imageSize, NSRect* fillRects, unsigned* numFillRects, int numRots) {
    NSRect drawingRect={ { 0, 0 }, imageSize };

    if (numRots & 1) {
        *numFillRects=2;
        if (imageSize.height*NSHeight(viewRect) < NSWidth(viewRect)*imageSize.width) {
            //image is tall
            float scalingFactor;
            scalingFactor=NSHeight(viewRect)/imageSize.width;
            drawingRect=NSInsetRect(viewRect, (NSWidth(viewRect)-imageSize.height*scalingFactor)/2.0, 0);
            scalingFactor=drawingRect.size.width;
            drawingRect.size.width=drawingRect.size.height;
            drawingRect.size.height=scalingFactor;
            drawingRect.origin.x=(NSWidth(viewRect)-NSHeight(viewRect))/2;
            drawingRect.origin.y=(NSHeight(viewRect)-NSHeight(drawingRect))/2;
            fillRects[0]=drawingRect;
            fillRects[0].origin.y=(NSHeight(viewRect)-NSWidth(viewRect))/2;
            fillRects[0].size.height=NSMinY(drawingRect)-fillRects[0].origin.y;
            fillRects[1]=fillRects[0];
            fillRects[1].origin.y=NSMaxY(drawingRect);
        }
        else {
            //image is wide
            float scalingFactor;
            scalingFactor=NSWidth(viewRect)/imageSize.height;
            drawingRect=NSInsetRect(viewRect, 0, (NSHeight(viewRect)-imageSize.width*scalingFactor)/2.0);
            scalingFactor=drawingRect.size.width;
            drawingRect.size.width=drawingRect.size.height;
            drawingRect.size.height=scalingFactor;
            drawingRect.origin.x=(NSWidth(viewRect)-NSWidth(drawingRect))/2;
            drawingRect.origin.y=(NSHeight(viewRect)-NSHeight(drawingRect))/2;
            fillRects[0]=drawingRect;
            fillRects[0].origin.x=(NSWidth(viewRect)-NSHeight(viewRect))/2;
            fillRects[0].size.width=NSMinX(drawingRect)-fillRects[0].origin.x;
            fillRects[1]=fillRects[0];
            fillRects[1].origin.x=NSMaxX(drawingRect);
        }
    }
    else {
        *numFillRects=2;
        if (imageSize.height*NSWidth(viewRect) > NSHeight(viewRect)*imageSize.width) {
            //image is tall
            float scalingFactor=NSHeight(viewRect)/imageSize.height;
            drawingRect=NSInsetRect(viewRect, (NSWidth(viewRect)-imageSize.width*scalingFactor)/2.0, 0);
            fillRects[0]=NSMakeRect(0, 0, NSMinX(drawingRect), NSHeight(viewRect));
            fillRects[1]=NSMakeRect(NSMaxX(drawingRect), 0, NSMaxX(viewRect)-NSMaxX(drawingRect), NSHeight(viewRect));
        }
        else {
            //image is wide
            float scalingFactor=NSWidth(viewRect)/imageSize.width;
            drawingRect=NSInsetRect(viewRect, 0, (NSHeight(viewRect)-imageSize.height*scalingFactor)/2.0);
            fillRects[0]=NSMakeRect(0, NSMaxY(drawingRect), NSWidth(viewRect), NSMaxY(viewRect)-NSMaxY(drawingRect));
            fillRects[1]=NSMakeRect(0, 0, NSWidth(viewRect), NSMinY(drawingRect));
        }
    }
    return drawingRect;
}