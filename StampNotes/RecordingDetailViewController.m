//
//  RecordingDetailViewController.m
//  StampNotes
//
//  Created by Jiahe Kuang on 10/12/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import "RecordingDetailViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface RecordingDetailViewController () <AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property(strong, nonatomic) AVAudioPlayer *player;


@end

@implementation RecordingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *recordingURL = [NSURL fileURLWithPath:self.recordingFilePath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordingURL error:nil];
    [self.player setDelegate:self];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)playPauseRecording:(id)sender
{
    if (self.player.playing)
    {
        [self.player pause];
        [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    else
    {
        [self.player play];
        [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
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
