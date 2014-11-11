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
@property(assign, nonatomic) float forwardBackWardTimer;
@property (weak, nonatomic) IBOutlet UITableView *stampTableView;

@end

@implementation RecordingDetailViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isPaused = NO;
    
    //default timer for playing backward or forward set to 3 second;
    self.forwardBackWardTimer = 3.0f;
    

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
    
//    if (!self.timer)
//    {
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateStamps) userInfo:nil repeats:YES];
//    }
    
    
    self.curretTimeSlider.maximumValue = [self.player duration];
    
    self.timeElapsed.text = @"00:00:00";
    
    self.timeDuration.text = [NSString stringWithFormat:@"-%@", [self timeFormatted:[self.player duration]]];

    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(updateTime:)
                                                userInfo:nil
                                                 repeats:YES];
    
    [self.player play];
    UIImage *pauseImage = [UIImage imageNamed:@"pause-100.png"];
    [self.playPauseButton setImage:pauseImage forState:UIControlStateNormal];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.timeStamps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.cell = [tableView dequeueReusableCellWithIdentifier:@"timeStamp" forIndexPath:indexPath];
    self.cell.timeStampLabelName = [NSString stringWithFormat:@"%d", ((int) (indexPath.row + 1))];
    
//    self.cell.timeStampLabel.backgroundColor = self.timeStampColor;
    
    return self.cell;
    
}


- (IBAction)playPauseRecording:(id)sender
{

    if (self.player.playing)
    {
//        [self.timer invalidate];
        [self.player pause];
        self.isPaused = YES;
        UIImage *playImage = [UIImage imageNamed:@"play-100.png"];
        [self.playPauseButton setImage:playImage forState:UIControlStateNormal];
        

    }
    else
    {
        self.isPaused = NO;

        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(updateTime:)
                                                    userInfo:nil
                                                     repeats:YES];
         [self.player play];
         UIImage *pauseImage = [UIImage imageNamed:@"pause-100.png"];
         [self.playPauseButton setImage:pauseImage forState:UIControlStateNormal];
    }
    
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
//    [self killTimer];
    
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(updateTime:)
                                   userInfo:nil
                                    repeats:NO];
    

//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
//                                                    message: @"Finish playing the recording!"
//                                                   delegate: nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
//    [self.timer invalidate];

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
        //if update the timestate, call updateTime faster not to wait a second and dont repeat it
        
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(updateTime:)
                                       userInfo:nil
                                        repeats:NO];
        self.isPaused = NO;

        [self.player play];

    }
    else
    {
        self.player.currentTime = selectedTimeStamp;
        //if update the timestate, call updateTime faster not to wait a second and dont repeat it
        
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(updateTime:)
                                       userInfo:nil
                                        repeats:NO];
        self.isPaused = NO;

        [self.player play];
    }
    
//    [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    
    UIImage *pauseImage = [UIImage imageNamed:@"pause-100.png"];
    [self.playPauseButton setImage:pauseImage forState:UIControlStateNormal];

}
- (IBAction)backward:(id)sender {
    
    //if update the timestate, call updateTime faster not to wait a second and dont repeat it
    
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(updateTime:)
                                       userInfo:nil
                                        repeats:NO];
        
        self.player.currentTime = self.player.currentTime - self.forwardBackWardTimer;
    


}



- (IBAction)forward:(id)sender {
    
    //if update the timestate, call updateTime faster not to wait a second and dont repeat it
    
    
    

    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateTime:)
                                   userInfo:nil
                                    repeats:NO];

    self.player.currentTime = self.player.currentTime + self.forwardBackWardTimer;
    

}


//-(void)updateStamps
//{
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection: 0];
//    
//    SNTimeStampTableViewCell * newCell =  (SNTimeStampTableViewCell *)[self.stampTableView cellForRowAtIndexPath:indexPath];
//    
//    [newCell.timeStampLabel setHighlighted:YES];
//    
//    
//}


//-(void)killTimer
//{
//    if (self.timer)
//    {
//        [self.timer invalidate];
//        self.timer = nil;
//    }
//}


- (void)updateTime:(NSTimer *)timer
{
    //to don't update every second. When scrubber is mouseDown the the slider will not set
    
  
        if (!self.scrubbing) {
            self.curretTimeSlider.value = [self.player currentTime];
        }
        self.timeElapsed.text = [NSString stringWithFormat:@"%@",
                                 [self timeFormatted:[self.player currentTime]]];
        
        self.timeDuration.text = [NSString stringWithFormat:@"-%@",
                                  [self timeFormatted:[self.player duration] - [self.player currentTime]]];


}


- (NSString *)timeFormatted:(float)totalSecondsInFloatingPoint
{
    
    int totalSeconds = floor(lroundf(totalSecondsInFloatingPoint));
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}
- (IBAction)userIsScrubbing:(id)sender
{
    self.scrubbing = TRUE;
}
- (IBAction)setCurrentTime:(id)sender
{
    //if scrubbing update the timestate, call updateTime faster not to wait a second and dont repeat it

    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(updateTime:)
                                   userInfo:nil
                                    repeats:NO];
    
    [self.player setCurrentTime:self.curretTimeSlider.value];
    self.scrubbing = FALSE;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.timer invalidate];
    [self.player stop];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
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
