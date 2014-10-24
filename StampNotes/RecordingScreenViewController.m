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
#import "AppDelegate.h"


@interface RecordingScreenViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property(strong, nonatomic) AVAudioRecorder *recorder;
@property(strong, nonatomic) AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIButton *startRecordingButton;
@property (weak, nonatomic) IBOutlet UIButton *finishedRecordingButton;
@property (weak, nonatomic) IBOutlet UIButton *playRecordingButton;


@property (strong, nonatomic) NSURL *recordingURL;
@property (strong, nonatomic) NSString *timeMarksFilePath;
@property (strong, nonatomic) NSMutableArray * timeMarksArray;

@property (strong, nonatomic) NSTimer *scheduleTimer;
@property (assign, nonatomic) int stampButtonLable;
@property (weak, nonatomic) IBOutlet UIButton *stampButton;

@property (assign, nonatomic) float previousTime;



@end

@implementation RecordingScreenViewController


@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scheduleTimer = nil;
    self.stampTimer = 0.0;
    self.stampButtonLable = 1;
    self.previousTime = 0.0;
    
#pragma message "Use dot syntax for these properties instead of calling setter methods"
    [self.finishedRecordingButton setEnabled:NO];
    [self.playRecordingButton setEnabled:NO];

    
    self.timeMarksArray = [NSMutableArray new];

#pragma message "You should access the delegate property with dot syntax instead of calling the getter method"
    self.recordingForFilePath = [[self delegate] directoryForNewRecording];
    NSDate *tempDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
#pragma message "Ideally you should create the date formatter as a class-level (static) variable. Initializing date formatters is pretty expensive so you want to avoid doing it more often than necessary"
    [dateFormatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss-a"];
    
    NSString *tempString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:tempDate]];
    
    self.recordingURL = [NSURL fileURLWithPath: [NSString stringWithFormat:@"%@/%@.m4a", self.recordingForFilePath, tempString]];
    self.timeMarksFilePath = [NSString stringWithFormat:@"%@/%@.txt", self.recordingForFilePath, tempString];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
#pragma message "Use literal syntax: ‘recordSetting[AVFormatIDKey] = xyz‘"
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.recordingURL settings:recordSetting error:NULL];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    
    NSError *error;
    
    NSLog(@"%@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.recordingForFilePath error:&error]);
    
    [self.timeMarksArray addObject:[NSString stringWithFormat:@"0.0\n"]];

    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingFinished:) name:UIApplicationWillTerminateNotification object:nil];
    
//    [UIApplication sharedApplication].delegate = self;
    
    // Do any additional setup after loading the view.
}

#pragma message "Remove empty stub methods"

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        [self.startRecordingButton setTitle:@"Start" forState:UIControlStateNormal];
    }
    
    [self.finishedRecordingButton setEnabled:YES];
    [self.playRecordingButton setEnabled:NO];
    
    
}

- (IBAction)recordingFinished:(id)sender
{
    [self.recorder stop];
    [self killTimer];
    
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    
    NSString *timeStampsInString = [[self.timeMarksArray valueForKey:@"description"] componentsJoinedByString:@""];
    NSData* tempDataBuffer = [timeStampsInString dataUsingEncoding:NSASCIIStringEncoding];
    
    [[NSFileManager defaultManager] createFileAtPath:self.timeMarksFilePath contents:tempDataBuffer attributes:nil];
    
    
    [self.navigationController popViewControllerAnimated:YES];

}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [self.startRecordingButton setTitle:@"Start" forState:UIControlStateNormal];
    
    [self.finishedRecordingButton setEnabled:NO];
    [self.playRecordingButton setEnabled:YES];
}



#pragma message "View Lifecycle methods should come directly after dealloc/init methods"

-(void)viewWillDisappear:(BOOL)animated
{
    
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

-(void)updateStampTimer
{
    self.stampTimer = self.stampTimer+0.1;
}

- (IBAction)stampTime:(id)sender
{
    
    if (self.recorder.recording)
    {
        self.stampButtonLable = self.stampButtonLable + 1;
        [self.stampButton setTitle:[NSString stringWithFormat:@"%d", self.stampButtonLable] forState:UIControlStateNormal];
        
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

@end
