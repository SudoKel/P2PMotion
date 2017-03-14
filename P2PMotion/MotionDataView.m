//
//  MotionDataView.m
//  P2PMotion
//
//  Created by Kelwin Joanes on 2017-03-14.
//  Copyright © 2017 Kelwin Joanes. All rights reserved.
//

#import "MotionDataView.h"

@implementation MotionDataView
{
    // Global vars
    CGFloat _accX, _accY, _accZ;
    double _pitch, _roll, _yaw;
}

/** Initializer for our class */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

/** This method indicates how the bars in the MotionDataView should be drawn */
- (void)drawRect:(CGRect)rect
{
    // For acceleration data
    float multiplier = 100; // To view significant change
    NSArray *bars = [NSArray arrayWithObjects:self.viewAccX, self.viewAccY, self.viewAccZ, nil];
    CGFloat acc[] = {_accX, _accY, _accZ};
    
    // Update bars to reflect change
    for (int i = 0; i < 3 ; i++)
    {
        UIView *view = [bars objectAtIndex:i];
        CGRect frame = view.frame;
        
        if (acc[i] >= 0)    // Bar should go right
        {
            frame.size.width = acc[i] * multiplier;
            frame.origin.x = 160;
        }
        else                // Bar should go left
        {
            frame.origin.x = 160 + acc[i] * multiplier;
            frame.size.width = -1 * acc[i] * multiplier;
        }
        view.frame = frame;
    }
    
    // For rotation data
    multiplier = 50;
    bars = [NSArray arrayWithObjects:self.viewPitch, self.viewRoll, self.viewYaw, nil];
    CGFloat rot[] = {_pitch, _roll, _yaw};
    
    // Update bars to reflect change
    for (int i = 0; i < 3 ; i++)
    {
        UIView *view = [bars objectAtIndex:i];
        CGRect frame = view.frame;
        
        if (acc[i] >= 0)    // Bar should go right
        {
            frame.size.width = rot[i] * multiplier;
            frame.origin.x = 160;
        }
        else                // Bar should go left
        {
            frame.origin.x = 160 + rot[i] * multiplier;
            frame.size.width = -1 * rot[i] * multiplier;
        }
        view.frame = frame;
    }
}

/** This method updates the display with new data for acceleration and rotation */
- (void)updateMotionDataViewWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z pitch:(double)pitch roll:(double)roll yaw:(double)yaw
{
    _accX = x;
    _accY = y;
    _accZ = z;
    _pitch = pitch;
    _roll = roll;
    _yaw = yaw;
    [self setNeedsDisplay];
}
@end
