//
//  RFAnimatedSlider.m
//  RFAnimatedSlider
//
//  Created by Rick Fillion on 19/03/09.
//  All code is provided under the New BSD license.
//

#import "RFAnimatedSlider.h"
#import <QuartzCore/QuartzCore.h>

@interface RFAnimatedSliderCell : NSSliderCell
{
    BOOL drawKnob;
    BOOL isTracking;
}
-(void)setDrawKnob:(BOOL)value;

@end


@implementation RFAnimatedSliderCell

- (void)drawKnob:(NSRect)knobRect
{
    if (!drawKnob)
        [(RFAnimatedSlider *)[self controlView] drawKnob: knobRect];
    else
        [super drawKnob:knobRect];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
    BOOL value = [super startTrackingAt:startPoint inView:controlView];
    if (!isTracking)
    {
        [(RFAnimatedSlider *)[self controlView] refreshKnobImage];
        isTracking = YES;
    }
    return value;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
    isTracking = NO;
    if (![self isContinuous])
        [(NSControl *)controlView sendAction:[self action] to:[self target]];

    [super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
    [(RFAnimatedSlider *)[self controlView] refreshKnobImage];
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{
    BOOL value =[super continueTracking:lastPoint at:currentPoint inView:controlView];
    if ([self isContinuous])
        [(NSControl *)controlView sendAction:[self action] to:[self target]];
    return value;
}

-(void)setDrawKnob:(BOOL)value
{
    drawKnob = value;
}

@end

@interface RFAnimatedSlider (Private)

- (void)swapCells;
- (Class) cellClass;
- (void)createKnobLayer:(NSRect)knobRect;

@end

@implementation RFAnimatedSlider (Private)

- (Class) cellClass
{
    return [RFAnimatedSliderCell class];
}

- (void)swapCells
{
    RFAnimatedSliderCell *newCell = [[[[self cellClass] alloc] initImageCell: nil] autorelease];
    NSSliderCell *oldCell = [self cell];
    
    [newCell setAltIncrementValue: [oldCell altIncrementValue]];
    [newCell setKnobThickness: [oldCell knobThickness]];
    [newCell setTitle: [oldCell title]];
    [newCell setMinValue: [oldCell minValue]];
    [newCell setMaxValue: [oldCell maxValue]];
    [newCell setAllowsTickMarkValuesOnly: [oldCell allowsTickMarkValuesOnly]];
    [newCell setNumberOfTickMarks: [oldCell numberOfTickMarks]];
    [newCell setTickMarkPosition: [oldCell tickMarkPosition]];
    
    [self setCell: newCell];
}

- (void)createKnobLayer:(NSRect)knobRect
{
    knobLayer = [[CALayer layer] retain];
    knobLayer.anchorPoint = CGPointMake(0,0);
    
    [self refreshKnobImage];
}



@end

@implementation RFAnimatedSlider



-(id)initWithFrame:(NSRect) rect
{
	if (self = [super initWithFrame: rect]){
        [self swapCells];
        [self setWantsLayer: YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillBecomeKey:) name:NSWindowDidBecomeKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillResignKey:) name:NSWindowDidResignKeyNotification object:nil];
	}
	return self;
}

-(id)initWithCoder:(NSCoder *)coder
{
	if (self = [super initWithCoder: coder]){
        [self swapCells];
        [self setWantsLayer: YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillBecomeKey:) name:NSWindowDidBecomeKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillResignKey:) name:NSWindowDidResignKeyNotification object:nil];
	}
	return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [knobLayer release];
    [super dealloc];
}

- (void)drawKnob:(NSRect)knobRect
{
    lastKnobRect = knobRect;
    if (knobLayer == nil)
        [self createKnobLayer: knobRect];


    CGRect frame = NSRectToCGRect(lastKnobRect);
    frame.origin.y = NSHeight([self frame]) - NSMaxY(lastKnobRect);
    if (!settingValue)
    {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration: 0];
        knobLayer.frame = frame;
        [NSAnimationContext endGrouping];
    }
    else
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.duration = 0.2;
        animation.fromValue=[NSValue valueWithPoint: NSMakePoint(knobLayer.position.x, knobLayer.position.y)];
        animation.toValue=[NSValue valueWithPoint: NSMakePoint(frame.origin.x, frame.origin.y)];
        [knobLayer addAnimation:animation forKey:@"movePosition"];
        knobLayer.frame = frame;
        settingValue = NO;
    }
}


#pragma mark Methods that can trigger an explicit slider animation

- (void)setDoubleValue:(double)value
{
    settingValue = YES;
    [super setDoubleValue:value];
}

- (void)setFloatValue:(float)value
{
    settingValue = YES;
    [super setFloatValue:value];
}

- (void)setIntValue:(int)value
{
    settingValue = YES;
    [super setIntValue:value];
}

- (void)setIntegerValue:(NSInteger)value
{
    settingValue = YES;
    [super setIntegerValue:value];
}

#pragma mark Methods that can change the look of the knob
- (void)setNumberOfTickMarks:(NSInteger)numberOfTickMarks
{
    [super setNumberOfTickMarks:numberOfTickMarks];
    [self refreshKnobImage];
}

- (void)windowWillBecomeKey:(id)sender
{
    [self refreshKnobImage];
}

- (void)windowWillResignKey:(id)sender
{
    [self refreshKnobImage];
}

- (void)refreshKnobImage
{
    NSImage *bigImage = [[[NSImage alloc] initWithSize: [self frame].size] autorelease];
    [bigImage lockFocus];
    [(RFAnimatedSliderCell*)[self cell] setDrawKnob:YES];
    [[self cell] drawKnob: lastKnobRect];
    [(RFAnimatedSliderCell*)[self cell] setDrawKnob:NO];
    [bigImage unlockFocus];
    
    NSImage *knobImage = [[[NSImage alloc] initWithSize:lastKnobRect.size] autorelease];
    NSRect rectAtOrigin = lastKnobRect;
    rectAtOrigin.origin.x = 0.0;
    rectAtOrigin.origin.y = 0.0;
    
    if ([knobImage respondsToSelector:@selector(lockFocusFlipped:)])
    {
        // 10.6 needs this.
        [knobImage lockFocusFlipped: YES];
    }
    else {
        [knobImage lockFocus];
    }
    [bigImage drawInRect:rectAtOrigin fromRect:lastKnobRect operation:NSCompositeSourceOver fraction: 1.0];
    [knobImage unlockFocus];
    
    NSData* cocoaData = [knobImage TIFFRepresentation]; 
	CFDataRef carbonData = (CFDataRef)cocoaData;
	CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData(carbonData, NULL);
	CGImageRef knobImageRef = CGImageSourceCreateImageAtIndex(imageSourceRef, 0, NULL);
    knobLayer.contents = (id)knobImageRef;
    CFRelease(imageSourceRef);
    CFRelease(knobImageRef);
    [[self layer] addSublayer: knobLayer];
    CGRect frame = NSRectToCGRect(lastKnobRect);
    frame.origin.y = NSHeight([self frame]) - NSMaxY(lastKnobRect);
    [knobLayer setFrame: frame];
}


@end
