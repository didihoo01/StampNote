//
//  RecordingScreenViewController.m
//  StampNotes
//
//  Created by Jiahe Kuang on 10/6/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import "RecordingScreenViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface RecordingScreenViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property(strong, nonatomic) AVAudioRecorder *recorder;
@property(strong, nonatomic) AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIButton *startRecordingButton;
@property (weak, nonatomic) IBOutlet UIButton *finishedRecordingButton;
@property (weak, nonatomic) IBOutlet UIButton *playRecordingButton;


@end

@implementation RecordingScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.finishedRecordingButton setEnabled:NO];
    [self.playRecordingButton setEnabled:NO];
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"demo.m4a",
                               nil];
    
    
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordingPlay:(id)sender
{
    if (!self.recorder.recording){
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
        [self.player setDelegate:self];
        [self.player play];
    }

}

- (IBAction)recordingStartOrPause:(id)sender
{
    
    //When a recording is being played, it will be paused
    if (self.player.playing)
    {
        [self.player stop];
    }
    
    //When it is not recording, it will start a new recording
    if (!self.recorder.recording) {
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
        [self.startRecordingButton setTitle:@"Start" forState:UIControlStateNormal];
    }
    
    [self.finishedRecordingButton setEnabled:YES];
    [self.playRecordingButton setEnabled:NO];
    
    
}

- (IBAction)recordingFinished:(id)sender
{
    [self.recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
//    [self.navigationController popViewControllerAnimated:YES];

}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [self.startRecordingButton setTitle:@"Start" forState:UIControlStateNormal];
    
    [self.finishedRecordingButton setEnabled:NO];
    [self.playRecordingButton setEnabled:YES];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
