//
//  RecordingDetailViewController.m
//  StampNotes
//
//  Created by Jiahe Kuang on 10/12/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import "RecordingDetailViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SNTimeStampTableViewCell.h"


@interface RecordingDetailViewController () <AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property(strong, nonatomic) AVAudioPlayer *player;
@property(strong, nonatomic) SNTimeStampTableViewCell *cell;

@property(assign, nonatomic) int forwardOrBackWardTimer;



@end

@implementation RecordingDetailViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //default timer for playing backward or forward set to 3 second;
    self.forwardOrBackWardTimer = 3;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    NSURL *recordingURL = [NSURL fileURLWithPath:self.recordingFilePath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordingURL error:nil];
    [self.player setDelegate:self];
    
    NSLog(@"%@", self.stampsFilePath);

    NSString *tempTimeStampString = [NSString stringWithContentsOfFile:self.stampsFilePath encoding:NSASCIIStringEncoding error:NULL];
    
    
    NSLog(@"%@", tempTimeStampString);
    
    
    self.timeStamps = [[NSMutableArray alloc] initWithArray:[tempTimeStampString componentsSeparatedByString:@"\n"]];
    
    //it removes the termination point at the end of the string that was stored as a component
    [self.timeStamps removeLastObject];
    
    UIImage *playImage = [UIImage imageNamed:@"play-100.png"];
    [self.playPauseButton setImage:playImage forState:UIControlStateNormal];
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.timeStamps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.cell = [tableView dequeueReusableCellWithIdentifier:@"timeStamp" forIndexPath:indexPath];
    
    [self.cell setTimeStampLabelName: [NSString stringWithFormat:@"%d", ((int) (indexPath.row + 1))]];
    
    self.cell.timeStampLabel.backgroundColor = self.timeStampColor;
    
    return self.cell;
    
}


- (IBAction)playPauseRecording:(id)sender
{
    if (self.player.playing)
    {
        [self.player pause];
//        [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
        
        UIImage *playImage = [UIImage imageNamed:@"play-100.png"];
        [self.playPauseButton setImage:playImage forState:UIControlStateNormal];
        

    }
    else
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        [self.player play];
//        [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
        UIImage *pauseImage = [UIImage imageNamed:@"pause-100.png"];
        [self.playPauseButton setImage:pauseImage forState:UIControlStateNormal];
    }
    
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
//    [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    UIImage *playImage = [UIImage imageNamed:@"play-100.png"];
    [self.playPauseButton setImage:playImage forState:UIControlStateNormal];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    float selectedTimeStamp = [self.timeStamps[indexPath.row] floatValue];
    
    NSLog(@"row %d selected", ((int) indexPath.row));
    
    NSLog(@"%f", selectedTimeStamp);
    
    //Forces a playback delay to account for human reacation delay when hearing a new topic being introduced.
    if (selectedTimeStamp > 2)
    {
        self.player.currentTime = selectedTimeStamp - 2;
        
        
        [self.player play];

    }
    else
    {
        self.player.currentTime = selectedTimeStamp;
        [self.player play];
    }
    
//    [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    
    UIImage *pauseImage = [UIImage imageNamed:@"pause-100.png"];
    [self.playPauseButton setImage:pauseImage forState:UIControlStateNormal];

}
- (IBAction)backward:(id)sender {
    
    self.player.currentTime = self.player.currentTime - self.forwardOrBackWardTimer;

}



- (IBAction)forward:(id)sender {
    self.player.currentTime = self.player.currentTime + self.forwardOrBackWardTimer;

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
