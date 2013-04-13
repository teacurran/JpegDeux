//
//  DefaultTransitionChooser.h
//  JPEGDeux 2
//
//  Created by Peter Ammon on Mon Nov 25 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DefaultTransitionChooser : NSObject {
    IBOutlet NSView* myView;
}

+ (Class)classForShowTypeByTag:(int)tag;
+ (NSString*)nibName;
+ (id)loadView;
- (NSView*)view;
- (NSDictionary*)valueDictionary;

@end
