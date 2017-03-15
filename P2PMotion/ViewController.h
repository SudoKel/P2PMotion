//
//  ViewController.h
//  P2PMotion
//
//  Created by Kelwin Joanes on 2017-03-14.
//  Copyright © 2017 Kelwin Joanes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <GameKit/GKPublicProtocols.h>

#define motionDataUpdateInterval 15.0
#define serviceType @"Motion-data"

@interface ViewController : UIViewController <MCSessionDelegate, MCBrowserViewControllerDelegate>
// Public methods
- (void)startMonitoringMotion;
- (void)stopMonitoringMotion;
@end

