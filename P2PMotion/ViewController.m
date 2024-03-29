//
//  ViewController.m
//  P2PMotion
//
//  This app displays local motion data on the current device
//  (before connected to any other device). And when connected,
//  the two devices essentially exchange their viewing of motion
//  data, i.e. motion data of device A is displayed on device B
//  and vice versa.
//
//  Created by Kelwin Joanes on 2017-03-14.
//  Copyright © 2017 Kelwin Joanes. All rights reserved.
//

#import "ViewController.h"
#import "MotionDataView.h"
#import <CoreMotion/CMMotionManager.h>

@interface ViewController ()
{
    CGRect originalViewFrame;
    BOOL deviceConnected;
    
    // Other devices motion data vars
    CGFloat peerAccX, peerAccY, peerAccZ;
    double peerPitch, peerRoll, peerYaw;
    
    // Labels
    UILabel *accXLabel;
    UILabel *accYLabel;
    UILabel *accZLabel;
    UILabel *pitchLabel;
    UILabel *rollLabel;
    UILabel *yawLabel;
}

// Properties
@property (nonatomic, strong) CMMotionManager *motman;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) MotionDataView *motDataView;
@property (nonatomic, strong) UIBarButtonItem *browseBtn;
@property (nonatomic, strong) UIButton *disconnectBtn;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCAdvertiserAssistant *advAssistant;
@property (nonatomic, strong) MCBrowserViewController *browserVController;

- (void)setNotConnectedState;
- (void)setConnectedState;
- (void)restoreView;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    originalViewFrame = self.view.frame;
    deviceConnected = NO;
    [self setNotConnectedState];
    
    // Create interface
    UINavigationBar * navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    navBar.backgroundColor = [UIColor whiteColor];
    
    UINavigationItem *navItem = [UINavigationItem new];
    navItem.title = @"P2PMotion";
    
    self.browseBtn = [[UIBarButtonItem alloc] initWithTitle:@"Browse"
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(browseForDevices:)];
    
    navItem.rightBarButtonItem = self.browseBtn;
    navBar.items = @[navItem];
    [self.view addSubview:navBar];
    
    self.disconnectBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.disconnectBtn addTarget:self action:@selector(disconnectFromDevice:) forControlEvents:UIControlEventTouchUpInside];
    [self.disconnectBtn setTitle:@"Disconnect" forState:UIControlStateNormal];
    self.disconnectBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [self.disconnectBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.disconnectBtn.frame = CGRectMake(80, 510, 160, 40);
    [self.view addSubview:self.disconnectBtn];
    
    // Prepare the session
    MCPeerID *devicePeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    self.session = [[MCSession alloc] initWithPeer:devicePeerID];
    self.session.delegate = self;
    
    // Begin advertising
    self.advAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:serviceType discoveryInfo:nil session:self.session];
    [self.advAssistant start];
    
    // Initialize motion data
    [self.motDataView updateMotionDataViewWithX:0 y:0 z:0 pitch:0 roll:0 yaw:0];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (deviceConnected)
        [self setConnectedState];
    else
        [self setNotConnectedState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
        accXLabel = [[UILabel alloc] initWithFrame:CGRectMake(155, 117, 100, 20)];
        accXLabel.text = @"X: ";
        accXLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:accXLabel];
        
        // Y bar
        rect = CGRectMake(160, 190, 1, 10);
        view = [[UIView alloc] initWithFrame:rect];
        view.backgroundColor = [UIColor greenColor];
        self.motDataView.viewAccY = view;
        [self.view addSubview:view];
        accYLabel = [[UILabel alloc] initWithFrame:CGRectMake(155, 167, 100, 20)];
        accYLabel.text = @"Y: ";
        accYLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:accYLabel];
        
        // Z bar
        rect = CGRectMake(160, 240, 1, 10);
        view = [[UIView alloc] initWithFrame:rect];
        view.backgroundColor = [UIColor blueColor];
        self.motDataView.viewAccZ = view;
        [self.view addSubview:view];
        accZLabel = [[UILabel alloc] initWithFrame:CGRectMake(155, 217, 100, 20)];
        accZLabel.text = @"Z: ";
        accZLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:accZLabel];
        
        // Bars for displaying acceleration data
        int rotationDataOffset = 240;
        // Pitch bar
        rect = CGRectMake(160, 140 + rotationDataOffset, 1, 10);
        view = [[UIView alloc] initWithFrame:rect];
        view.backgroundColor = [UIColor yellowColor];
        self.motDataView.viewPitch = view;
        [self.view addSubview:view];
        pitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(142, 117 + rotationDataOffset, 140, 20)];
        pitchLabel.text = @"Pitch: ";
        pitchLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:pitchLabel];
        
        // Roll bar
        rect = CGRectMake(160, 190 + rotationDataOffset, 1, 10);
        view = [[UIView alloc] initWithFrame:rect];
        view.backgroundColor = [UIColor cyanColor];
        self.motDataView.viewRoll = view;
        [self.view addSubview:view];
        rollLabel = [[UILabel alloc] initWithFrame:CGRectMake(148, 167 + rotationDataOffset, 140, 20)];
        rollLabel.text = @"Roll: ";
        rollLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:rollLabel];
        
        // Yaw bar
        rect = CGRectMake(160, 240 + rotationDataOffset, 1, 10);
        view = [[UIView alloc] initWithFrame:rect];
        view.backgroundColor = [UIColor orangeColor];
        self.motDataView.viewYaw = view;
        [self.view addSubview:view];
        yawLabel = [[UILabel alloc] initWithFrame:CGRectMake(145, 217 + rotationDataOffset, 140, 20)];
        yawLabel.text = @"Yaw: ";
        yawLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:yawLabel];
        
        self.motman = [CMMotionManager new];
        
        [self startMonitoringMotion];
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
    
    // Send motion data to other device if connected
    if (deviceConnected)
    {
        NSArray *peerIDs = self.session.connectedPeers;
        NSString *strData = [NSString stringWithFormat:@"%f %f %f %f %f %f", acc.x, acc.y, acc.z, rot.x, rot.y, rot.z];
        [self.session sendData:[strData dataUsingEncoding:NSASCIIStringEncoding]
                       toPeers:peerIDs
                      withMode:MCSessionSendDataUnreliable
                         error:nil];
    }
    else // Otherwise use current devices motion data
    {
        peerAccX = acc.x;
        peerAccY = acc.y;
        peerAccZ = acc.z;
        peerPitch = rot.x;
        peerRoll = rot.y;
        peerYaw = rot.z;
    }
    
    // Update labels with data
    accXLabel.text = [NSString stringWithFormat:@"X: %.04f", peerAccX];
    accYLabel.text = [NSString stringWithFormat:@"Y: %.04f", peerAccY];
    accZLabel.text = [NSString stringWithFormat:@"Z: %.04f", peerAccZ];
    pitchLabel.text = [NSString stringWithFormat:@"Pitch: %.04f", peerPitch];
    rollLabel.text = [NSString stringWithFormat:@"Roll: %.04f", peerRoll];
    yawLabel.text = [NSString stringWithFormat:@"Yaw: %.04f", peerYaw];
    
    // Update the view with new motion data
    [self.motDataView updateMotionDataViewWithX:peerAccX y:peerAccY z:peerAccZ pitch:peerPitch roll:peerRoll yaw:peerYaw];
}

/** This method displays a new view to browse for nearby devices */
- (void)browseForDevices:(UIBarButtonItem *)sender
{
    self.browserVController = [[MCBrowserViewController alloc] initWithServiceType:serviceType session:self.session];
    self.browserVController.delegate = self;
    [self presentViewController:self.browserVController animated:YES completion:nil];
}

/** This method disconnects the current device from the connected device */
- (void)disconnectFromDevice:(UIButton *)sender
{
    [self setNotConnectedState];
    deviceConnected = NO;
    [self.session disconnect];
}

/** This method updates the interface when device is disconnected */
- (void)setNotConnectedState
{
    self.browseBtn.enabled = YES;
    self.disconnectBtn.enabled = NO;
}

/** This method updates the interface when the device is connected */
- (void)setConnectedState
{
    self.browseBtn.enabled = NO;
    self.disconnectBtn.enabled = YES;
}

/** This method simply restores the view to our original interface */
- (void)restoreView
{
    self.view.frame = originalViewFrame;
}

#pragma-mark <MCSessionDelegate> methods
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnected)
    {
        [self setConnectedState];
        deviceConnected = YES;
    }
    else
    {
        [self setNotConnectedState];
        deviceConnected = NO;
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSString *strData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    // For debugging
    NSLog(@"Received motion data: %@", strData);
    
    NSArray *motionData = [NSArray new];
    
    // Split string data into individual values representing components of motion data
    motionData = [strData componentsSeparatedByString:@" "];
    
    // Retrieve corresponding motion data values
    peerAccX = [[motionData objectAtIndex:0] floatValue];
    peerAccY = [[motionData objectAtIndex:1] floatValue];
    peerAccZ = [[motionData objectAtIndex:2] floatValue];
    
    peerPitch = [[motionData objectAtIndex:3] doubleValue];
    peerRoll = [[motionData objectAtIndex:4] doubleValue];
    peerYaw = [[motionData objectAtIndex:5] doubleValue];
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}

#pragma-mark <MCBrowserViewControllerDelegate> methods
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
