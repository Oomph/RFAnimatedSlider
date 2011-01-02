//
//  AppController.h
//  RFAnimatedSlider
//
//  Created by Rick Fillion on 23/07/09.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
    NSNumber *value;
}

@property (nonatomic, retain) NSNumber *value;

- (IBAction)setToMax:(id)sender;
- (IBAction)setToMin:(id)sender;

@end


