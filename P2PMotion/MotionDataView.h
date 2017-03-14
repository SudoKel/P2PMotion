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
- (void)updateMotionDataViewWithX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z Pitch:(double)pitch Roll:(double)roll Yaw:(double)yaw;

// Properties
@property (nonatomic, strong) UIView *viewAccX;
@property (nonatomic, strong) UIView *viewAccY;
@property (nonatomic, strong) UIView *viewAccZ;
@property (nonatomic, strong) UIView *viewPitch;
@property (nonatomic, strong) UIView *viewRoll;
@property (nonatomic, strong) UIView *viewYaw;
@end
