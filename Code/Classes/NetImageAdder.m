#import "NetImageAdder.h"
#import "Master.h"
#import "StringAdditions.h"

@implementation NetImageAdder

- (NSArray*)URLs {
    NSMutableArray* result;
    NSString* prefix, * suffix;
    NSString* startNumber, * endNumber;
    NSString* first=[myFirstURLField stringValue];
    NSString* last=[myLastURLField stringValue];
    int startValue, endValue;
    BOOL padZeros;
    char padWidth[32];
    NSString* formatString;
    /* Treat URLs as three pieces: prefix, number, suffix */
    /* Strategy: find first different character, die if it's not a digit,
        backtrack until we have all the digits, check for zero padding */
    if ([first isEqualToString:last]) return [NSArray arrayWithObject:first];
    prefix=[first commonPrefixWithString:last options:0];
    if (! [prefix length]) return nil;

    long i;
    for (i=[prefix length]; i>0; i--) {
        if (! isdigit([prefix characterAtIndex:i-1])) break;
    }
    if (i <= 0) {
        return nil;
    }

    //i should be the index of the first digit character
    prefix=[prefix substringToIndex:i];
    suffix=[first commonSuffixWithString:last];
    if (! [suffix length]) return nil;
    for (i=0; i < [suffix length]; i++) {
        if (! isdigit([suffix characterAtIndex:i])) break;
    }
    //i should be index of first non-digit character
    if (i==[suffix length]) suffix=nil;
    else suffix=[suffix substringFromIndex:i];
    //if (! [suffix length]) return nil; //no suffix is ok I guess
    //find the number
    startNumber=[first substringFromIndex:[prefix length]];
    startNumber=[startNumber substringToIndex:[startNumber length]-[suffix length]];
    endNumber=[last substringFromIndex:[prefix length]];
    endNumber=[endNumber substringToIndex:[endNumber length]-[suffix length]];
    if (! [startNumber length] || ! [endNumber length]) return nil;
    padZeros=[startNumber characterAtIndex:0]=='0';
    sprintf(padWidth+1, "%lu", (unsigned long)[endNumber length]);
    padWidth[0]='0';
    formatString=[NSString stringWithFormat:@"%%@%%%sd%%@", padZeros ? padWidth : ""];
    startValue=[startNumber intValue];
    endValue=[endNumber intValue];
    result=[NSMutableArray arrayWithCapacity:endValue-startValue+1];
    //NSLog(@"Format string: %@", formatString);
    for (i=startValue; i<=endValue; i++) {
        [result addObject:[NSString stringWithFormat:formatString, prefix, i, suffix]];
    }
    return result;
}

- (IBAction)addImages:(id)sender {
    NSArray* array=[self URLs];
    if (array) {
        [myWindow orderOut:self];
        [myMaster processAndAddURLs:array];
    }
    else NSRunAlertPanel(@"Bad URLs", @"JPEGDeux couldn't interpret the supplied URLs.",
                                    @"D'oh!", nil, nil);
}

- (IBAction)cancel:(id)sender {
    [myWindow orderOut:self];
}

- (void)controlTextDidChange:(NSNotification*)note {
    NSTextView* fieldEditor=[[note userInfo] objectForKey:@"NSFieldEditor"];
    NSTextField* field=[note object];
    NSString* first, * second;
    if (field==myFirstURLField) {
        first=[fieldEditor string];
        second=[myLastURLField stringValue];
    }
    else {
        first=[myFirstURLField stringValue];
        second=[fieldEditor string];
    }
    [myAddButton setEnabled:[first length] > 0 && [second length] > 0];
}

- (IBAction)showDialog:(id)sender {
    if (! myWindow) {
        if (! [NSBundle loadNibNamed:@"InternetImages" owner:self] || !myWindow) {
            NSRunAlertPanel(@"Nib error", @"JPEGDeux couldn't open InternetImages.nib",
                            @"D'oh!", nil, nil);
            return;
        }
    }
    [myAddButton setEnabled:[[myFirstURLField stringValue] length] > 0 &&
                            [[myLastURLField stringValue] length] > 0];
    [myWindow makeKeyAndOrderFront:self];
}

@end
