//
//  AppController.m
//  RFAnimatedSlider
//
//  Created by Rick Fillion on 23/07/09.
//  All code is provided under the New BSD license.
//

#import "AppController.h"


@implementation AppController

@synthesize value;

- (id)init
{
    if (self = [super init])
    {
        self.value = [NSNumber numberWithInt:0];
    }
    return self;
}

- (IBAction)setToMax:(id)sender
{
    self.value = [NSNumber numberWithInt:10];
}

- (IBAction)setToMin:(id)sender
{
    self.value = [NSNumber numberWithInt:0];
}

@end
