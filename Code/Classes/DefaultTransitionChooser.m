//
//  DefaultTransitionChooser.m
//  JPEGDeux 2
//
//  Created by Peter Ammon on Mon Nov 25 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import "DefaultTransitionChooser.h"
#import "ScreenShowTransitionChooser.h"

static NSMutableDictionary* sTransitionViews;

@implementation DefaultTransitionChooser

+ (Class)classForShowTypeByTag:(int)tag {
    switch(tag) {
        case 1: return [ScreenShowTransitionChooser class];
        default: return [DefaultTransitionChooser class];
    }
}

+ (NSString*)nibName {
    return @"DefaultTransitionView";
}

+ (id)loadView {
    id result;
    if (! sTransitionViews) sTransitionViews=[[NSMutableDictionary alloc] init];
    result=[sTransitionViews objectForKey:[self nibName]];
    if (! result) {
        result=[[self alloc] init];
        if (! [NSBundle loadNibNamed:[self nibName] owner:result]) {
            NSRunAlertPanel(@"Nib error", @"JPEGDeux couldn't load %@.nib",
                            @"D'oh!", nil, nil, [self nibName]);
            result=nil;
        }
        else [sTransitionViews setObject:result forKey:[self nibName]];
        [result release];
    }
    return result;
}

- (NSDictionary*)valueDictionary {
    return [NSDictionary dictionary];
}

- (NSView*)view {
    return myView;
}

- (void)setValuesFromDictionary:(NSDictionary*)dict {
    
}

@end
