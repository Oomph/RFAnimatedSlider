//
//  RFAnimatedSlider.h
//  RFAnimatedSlider
//
//  Created by Rick Fillion on 19/03/09.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>


@interface RFAnimatedSlider : NSSlider {
    CALayer *knobLayer;
    BOOL settingValue;
    NSRect lastKnobRect;
}

- (void)refreshKnobImage;
- (void)drawKnob:(NSRect)knobRect;

@end
