#ifndef PETERSTYPES

#define PETERSTYPES

//the first of these three are compatible with NSImageScaling

typedef enum {
    ScaleProportionally = 0,   // Fit proportionally
    ScaleToFit,                // Forced fit (distort if necessary)
    ScaleNone,                 // Don't scale (clip)
    ScaleDownProportionally,   // Only scale down proportionally
    ScaleDownToFit	       // Only scale down to fit
} BetterImageScaling;

typedef enum {
    none=0,
    name,
    path
} FileNameDisplay;

typedef enum {
    noComment=0,
    windowComment,
} CommentStyle_t;

extern const short StopSlideshowEventType;

extern NSString* const CancelShowException;

#endif