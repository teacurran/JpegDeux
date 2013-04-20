//
//  ScreenShowTransitionChooser.m
//  JPEGDeux 2
//
//  Created by Peter Ammon on Tue Nov 26 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import "ScreenShowTransitionChooser.h"


@implementation ScreenShowTransitionChooser

- (void)awakeFromNib {
    [myTransitionType selectItemAtIndex:0];
    [myTransitionSpeed setFloatValue:20.0];
	[myTransitionDuration setDoubleValue:1.0];
}

+ (NSString*)nibName {
    return @"ScreenShowTransitionView";
}

- (NSDictionary*)valueDictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:[[myTransitionType selectedItem] tag]], @"Transition",
        [NSNumber numberWithFloat:[myTransitionSpeed floatValue]], @"NumSteps",
		[NSNumber numberWithFloat:[myTransitionDuration floatValue]], @"Duration",
        nil];
}

- (void)setValuesFromDictionary:(NSDictionary*)dict {
    if ([dict objectForKey:@"Transition"]) {
		[myTransitionType selectItemAtIndex:[myTransitionType indexOfItemWithTag:[[dict objectForKey:@"Transition"] intValue]]];
	}
    if ([dict objectForKey:@"NumSteps"]) {
		[myTransitionSpeed setFloatValue:[[dict objectForKey:@"NumSteps"] floatValue]];
	}
    if ([dict objectForKey:@"Duration"]) {
		[myTransitionDuration setFloatValue:[[dict objectForKey:@"Duration"] doubleValue]];
	}
}

@end
