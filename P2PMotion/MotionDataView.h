//
//  MotionDataView.h
//  P2PMotion
//
//  Created by Kelwin Socorro Savio Joanes on 2017-03-14.
//  Copyright © 2017 Kelwin Joanes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MotionDataView : UIView
// Public methods
- (void)updateMotionDataViewWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z pitch:(double)pitch roll:(double)roll yaw:(double)yaw;

// Properties
@property (nonatomic, strong) UIView *viewAccX;
@property (nonatomic, strong) UIView *viewAccY;
@property (nonatomic, strong) UIView *viewAccZ;
@property (nonatomic, strong) UIView *viewPitch;
@property (nonatomic, strong) UIView *viewRoll;
@property (nonatomic, strong) UIView *viewYaw;
@end
