//
//  ScreenShowTransitionChooser.h
//  JPEGDeux 2
//
//  Created by Peter Ammon on Tue Nov 26 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DefaultTransitionChooser.h"

@interface ScreenShowTransitionChooser : DefaultTransitionChooser {
    IBOutlet NSPopUpButton* myTransitionType;
    IBOutlet NSSlider* myTransitionSpeed;
}



@end
