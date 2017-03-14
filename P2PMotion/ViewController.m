//
//  ViewController.m
//  P2PMotion
//
//  Created by Kelwin Joanes on 2017-03-14.
//  Copyright © 2017 Kelwin Joanes. All rights reserved.
//

#import "ViewController.h"
#import "MotionDataView.h"
#import <CoreMotion/CMMotionManager.h>

@interface ViewController ()
// Properties
@property (nonatomic, strong) CMMotionManager *motman;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) MotionDataView *motDataView;
@end

@implementation ViewController
/** Initializer for our view controller */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.motDataView = (MotionDataView *)self.view;
        
        // Bars for displaying acceleration data
        // X bar
        CGRect rect = CGRectMake(160, 80, 1, 10);
        CGRect frame = CGRectMake(155, 57, 20, 20);
        UIColor *color = [UIColor redColor];
        NSString *title = @"X";
        [self createBarWithRect:rect color:color labelFrame:frame labelTitle:title];
        
        // Y bar
        rect = CGRectMake(160, 130, 1, 10);
        frame = CGRectMake(155, 107, 20, 20);
        title = @"Y";
        [self createBarWithRect:rect color:color labelFrame:frame labelTitle:title];
        
        // Z bar
        rect = CGRectMake(160, 180, 1, 10);
        frame = CGRectMake(155, 157, 20, 20);
        title = @"Z";
        [self createBarWithRect:rect color:color labelFrame:frame labelTitle:title];
        
        // Bars for displaying acceleration data
        int rotationDataOffset = 240;
        // Pitch bar
        rect = CGRectMake(160, 80 + rotationDataOffset, 1, 10);
        frame = CGRectMake(155, 57 + rotationDataOffset, 20, 20);
        color = [UIColor redColor];
        title = @"Pitch";
        [self createBarWithRect:rect color:color labelFrame:frame labelTitle:title];
        
        // Roll bar
        rect = CGRectMake(160, 130 + rotationDataOffset, 1, 10);
        frame = CGRectMake(155, 107 + rotationDataOffset, 20, 20);
        title = @"Roll";
        [self createBarWithRect:rect color:color labelFrame:frame labelTitle:title];
        
        // Yaw bar
        rect = CGRectMake(160, 180 + rotationDataOffset, 1, 10);
        frame = CGRectMake(155, 157 + rotationDataOffset, 20, 20);
        title = @"Yaw";
        [self createBarWithRect:rect color:color labelFrame:frame labelTitle:title];
        
        self.motman = [CMMotionManager new];
        
        // Check if accelerometer and gyro available
        if (self.motman.deviceMotionActive)
            [self startMonitoringMotion];
        else
            NSLog(@"Sorry, device does not support accelerometer or gyro...");
    }
    return self;
}

/** This helper method creates a bar for visualizing motion data and adds it to the view */
- (void)createBarWithRect:(CGRect)rect color:(UIColor *)color labelFrame:(CGRect)frame labelTitle:(NSString *)title
{
    CGRect bar = rect;
    UIView *view = [[UIView alloc] initWithFrame:bar];
    view.backgroundColor = color;
    self.motDataView.viewAccX = view;
    [self.view addSubview:view];
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = title;
    [self.view addSubview:label];
}

/** This method starts the recording of motion data */
- (void)startMonitoringMotion
{
    // Set intervals for refreshing data
    self.motman.accelerometerUpdateInterval = 1.0 / motionDataUpdateInterval;
    self.motman.gyroUpdateInterval = 1.0 / motionDataUpdateInterval;
    
    // We need to display motion data
    self.motman.showsDeviceMovementDisplay = YES;
    
    // Start motion data recording
    [self.motman startAccelerometerUpdates];
    [self.motman startGyroUpdates];
    
    // Schedule our timer to constantly update motion data
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.motman.accelerometerUpdateInterval
                                                  target:self
                                                selector:@selector(pollMotion:)
                                                userInfo:nil
                                                 repeats:YES];
}

/** This method stops the recording of motion data */
- (void)stopMonitoringMotion
{
    // Stop motion data recording
    [self.motman stopAccelerometerUpdates];
    [self.motman stopGyroUpdates];
}

/** This method retrieves the latest motion data at given intervals */
- (void)pollMotion:(NSTimer *)timer
{
    // Retrieve acceleration data
    CMAcceleration acc = self.motman.accelerometerData.acceleration;
    
    // Retrieve rotation data
    CMRotationRate rot = self.motman.gyroData.rotationRate;
    
    // Refresh data of view
    [self.motDataView updateMotionDataViewWithX:acc.x y:acc.y z:acc.z pitch:rot.x roll:rot.y yaw:rot.z];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.motDataView updateMotionDataViewWithX:0 y:0 z:0 pitch:0 roll:0 yaw:0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
