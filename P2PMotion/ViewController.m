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
        CGRect rect = CGRectMake(160, 140, 1, 10);
        UIView *view = [[UIView alloc] initWithFrame:rect];
        view.backgroundColor = [UIColor redColor];
        self.motDataView.viewAccX = view;
        [self.view addSubview:view];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(155, 117, 20, 20)];
        label.text = @"X";
        [self.view addSubview:label];
        
        // Y bar
        rect = CGRectMake(160, 190, 1, 10);
        view = [[UIView alloc] initWithFrame:rect];
        view.backgroundColor = [UIColor redColor];
        self.motDataView.viewAccY = view;
        [self.view addSubview:view];
        label = [[UILabel alloc] initWithFrame:CGRectMake(155, 167, 20, 20)];
        label.text = @"Y";
        [self.view addSubview:label];
        
        // Z bar
        rect = CGRectMake(160, 240, 1, 10);
        view = [[UIView alloc] initWithFrame:rect];
        view.backgroundColor = [UIColor redColor];
        self.motDataView.viewAccZ = view;
        [self.view addSubview:view];
        label = [[UILabel alloc] initWithFrame:CGRectMake(155, 217, 20, 20)];
        label.text = @"Z";
        [self.view addSubview:label];
        
        // Bars for displaying acceleration data
        int rotationDataOffset = 240;
        // Pitch bar
        rect = CGRectMake(160, 140 + rotationDataOffset, 1, 10);
        view = [[UIView alloc] initWithFrame:rect];
        view.backgroundColor = [UIColor blueColor];
        self.motDataView.viewPitch = view;
        [self.view addSubview:view];
        label = [[UILabel alloc] initWithFrame:CGRectMake(142, 117 + rotationDataOffset, 60, 20)];
        label.text = @"Pitch";
        [self.view addSubview:label];
        
        // Roll bar
        rect = CGRectMake(160, 190 + rotationDataOffset, 1, 10);
        view = [[UIView alloc] initWithFrame:rect];
        view.backgroundColor = [UIColor blueColor];
        self.motDataView.viewRoll = view;
        [self.view addSubview:view];
        label = [[UILabel alloc] initWithFrame:CGRectMake(148, 167 + rotationDataOffset, 60, 20)];
        label.text = @"Roll";
        [self.view addSubview:label];
        
        // Yaw bar
        rect = CGRectMake(160, 240 + rotationDataOffset, 1, 10);
        view = [[UIView alloc] initWithFrame:rect];
        view.backgroundColor = [UIColor blueColor];
        self.motDataView.viewYaw = view;
        [self.view addSubview:view];
        label = [[UILabel alloc] initWithFrame:CGRectMake(145, 217 + rotationDataOffset, 60, 20)];
        label.text = @"Yaw";
        [self.view addSubview:label];
        
        self.motman = [CMMotionManager new];
        
        // Check if accelerometer and gyro available
        if (self.motman.deviceMotionAvailable)
            [self startMonitoringMotion];
        else
            NSLog(@"Sorry, device does not support accelerometer or gyro...");
    }
    return self;
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
