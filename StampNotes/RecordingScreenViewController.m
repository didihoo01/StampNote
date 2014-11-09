//
//  RecordingScreenViewController.m
//  StampNotes
//
//  Created by Jiahe Kuang on 10/6/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import "RecordingScreenViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Recording.h"
#import "SCSiriWaveformView.h"
#import "AppDelegate.h"


@interface RecordingScreenViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property(strong, nonatomic) AVAudioRecorder *recorder;
@property(strong, nonatomic) AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIButton *startRecordingButton;


@property (strong, nonatomic) NSURL *recordingURL;
@property (strong, nonatomic) NSString *timeMarksFilePath;
@property (strong, nonatomic) NSMutableArray * timeMarksArray;

@property (strong, nonatomic) NSTimer *scheduleTimer;
@property (assign, nonatomic) int stampButtonLable;
@property (weak, nonatomic) IBOutlet UIButton *stampButton;

@property (assign, nonatomic) float previousTime;

@property (weak, nonatomic) IBOutlet SCSiriWaveformView *waveFormView;

@property (weak, nonatomic) IBOutlet UILabel *stampNumberLabel;

@end

@implementation RecordingScreenViewController


@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.scheduleTimer = nil;
    self.stampTimer = 0.0;
    self.stampButtonLable = 1;
    self.previousTime = 0.0;
    
//    self.finishedRecordingButton.enabled = NO;

    self.navigationItem.hidesBackButton = YES;

    
    self.timeMarksArray = [NSMutableArray new];

    self.recordingForFilePath = [self.delegate directoryForNewRecording];
    NSDate *tempDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss-a"];
    
    NSString *tempString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:tempDate]];
    
    self.recordingURL = [NSURL fileURLWithPath: [NSString stringWithFormat:@"%@/%@.m4a", self.recordingForFilePath, tempString]];
    self.timeMarksFilePath = [NSString stringWithFormat:@"%@/%@.txt", self.recordingForFilePath, tempString];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    
    
    NSDictionary  *recordSetting = @{AVFormatIDKey : @(kAudioFormatMPEG4AAC), AVSampleRateKey : @44100.0, AVNumberOfChannelsKey: @(2)} ;
    
    // Initiate and prepare the recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.recordingURL settings:recordSetting error:NULL];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    if (!self.scheduleTimer)
    {
        self.stampTimer = self.previousTime;
        self.scheduleTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateStampTimer) userInfo:nil repeats:YES];
    }
    
    
    [session setActive:YES error:nil];
    
    //start recroding
    [self.recorder record];
    
    
    
    [self.startRecordingButton setTitle:@"Pause" forState:UIControlStateNormal];

    
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    
    
    [self.waveFormView setWaveColor:[UIColor blueColor]];
    [self.waveFormView setPrimaryWaveLineWidth:6.0f];
    [self.waveFormView setSecondaryWaveLineWidth:2.0];

    
    NSError *error;
    
    NSLog(@"%@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.recordingForFilePath error:&error]);
    
    [self.timeMarksArray addObject:[NSString stringWithFormat:@"0.0\n"]];

    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingFinished:) name:UIApplicationWillTerminateNotification object:nil];
    
    

    
//    [UIApplication sharedApplication].delegate = self;
    
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    self.navigationController.navigationBarHidden = NO;

    
    if (self.recorder.recording)
    {
        [self.recorder stop];
        [self killTimer];
        
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        
        NSString *timeStampsInString = [[self.timeMarksArray valueForKey:@"description"] componentsJoinedByString:@""];
        NSData* tempDataBuffer = [timeStampsInString dataUsingEncoding:NSASCIIStringEncoding];
        
        [[NSFileManager defaultManager] createFileAtPath:self.timeMarksFilePath contents:tempDataBuffer attributes:nil];
    }
    
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:self.recordingURL options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    NSLog(@"Recording is %f seconds long", audioDurationSeconds);
    
    if (audioDurationSeconds < 1)
    {
        [[NSFileManager defaultManager] removeItemAtURL:self.recordingURL error:nil];
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
}

- (IBAction)recordingStartOrPause:(id)sender
{
    
    //When a recording is being played, it will be paused
    if (self.player.playing)
    {
        [self.player stop];
    }
    
    //When it is not recording, it will start a new recording
    if (!self.recorder.recording)
    {
        
        if (!self.scheduleTimer)
        {
            self.stampTimer = self.previousTime;
            self.scheduleTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateStampTimer) userInfo:nil repeats:YES];
        }


        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        [session setActive:YES error:nil];
        
        //start recroding
        [self.recorder record];
        
    
        
        [self.startRecordingButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    }
    
    //when it is recording, we want to pause
    else
    {
        [self.recorder pause];
        self.previousTime = self.stampTimer;
        self.stampTimer = 0.0;
        [self killTimer];
        
        [self.startRecordingButton setTitle:@"Resume" forState:UIControlStateNormal];
    }
    
    
    
}

- (IBAction)recordingFinished:(id)sender
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done Recording?"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:@"YES", nil];
    [alert show];
    
    

}



- (void)updateMeters
{
        [self.recorder updateMeters];
        
        CGFloat normalizedValue = pow (10, [self.recorder averagePowerForChannel:0] / 20);
        
        [self.waveFormView updateWithLevel:normalizedValue];

}



-(void)updateStampTimer
{
    self.stampTimer = self.stampTimer+0.1;
}

- (IBAction)stampTime:(id)sender
{
    if (self.recorder.recording)
    {
        self.stampButtonLable = self.stampButtonLable + 1;
        self.stampNumberLabel.text = [NSString stringWithFormat:@"%d", self.stampButtonLable];
        NSLog(@"%.2f", self.stampTimer);
        
        [self.timeMarksArray addObject:[NSString stringWithFormat:@"%.2f\n", self.stampTimer]];
    }
    

}

- (void)killTimer
{
    if (self.scheduleTimer)
    {

        [self.scheduleTimer invalidate];
        self.scheduleTimer = nil;

    }
}

//- (void)stateChanged:(UISwitch *)switchState
//{
//    if ([switchState isOn])
//    {
//        [self.recorder stop];
//        [self killTimer];
//        
//        
//        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//        [audioSession setActive:NO error:nil];
//        
//        
//        NSString *timeStampsInString = [[self.timeMarksArray valueForKey:@"description"] componentsJoinedByString:@""];
//        NSData* tempDataBuffer = [timeStampsInString dataUsingEncoding:NSASCIIStringEncoding];
//        
//        [[NSFileManager defaultManager] createFileAtPath:self.timeMarksFilePath contents:tempDataBuffer attributes:nil];
//        
//        
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//}

//- (void)applicationWillTerminate:(UIApplication *)application
//{
//    NSLog(@"YOLO Swag!!!");
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"NO"])
    {
        NSLog(@"Nothing to do here");
    }
    else if([title isEqualToString:@"YES"])
    {
        [self.recorder stop];
        [self killTimer];
        
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        
        NSString *timeStampsInString = [[self.timeMarksArray valueForKey:@"description"] componentsJoinedByString:@""];
        NSData* tempDataBuffer = [timeStampsInString dataUsingEncoding:NSASCIIStringEncoding];
        
        [[NSFileManager defaultManager] createFileAtPath:self.timeMarksFilePath contents:tempDataBuffer attributes:nil];
        
        
        [self.navigationController popViewControllerAnimated:YES];    }
}

@end
