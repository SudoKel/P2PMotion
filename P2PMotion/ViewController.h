//
//  ViewController.h
//  P2PMotion
//
//  Created by Kelwin Joanes on 2017-03-14.
//  Copyright © 2017 Kelwin Joanes. All rights reserved.
//

#import <UIKit/UIKit.h>

#define motionDataUpdateInterval 15.0;

@interface ViewController : UIViewController
// Public methods
- (void)startMonitoringMotion;
- (void)stopMonitoringMotion;
@end

