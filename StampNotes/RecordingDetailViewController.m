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



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *recordingURL = [NSURL fileURLWithPath:self.recordingFilePath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordingURL error:nil];
    [self.player setDelegate:self];
    
    NSLog(@"%@", self.stampsFilePath);

    NSString *tempTimeStampString = [NSString stringWithContentsOfFile:self.stampsFilePath encoding:NSASCIIStringEncoding error:NULL];
    
    
    NSLog(@"%@", tempTimeStampString);
    
    
    self.timeStamps = [[NSMutableArray alloc] initWithArray:[tempTimeStampString componentsSeparatedByString:@"\n"]];
    
    //it removes the termination point at the end of the string that was stored as a component
    [self.timeStamps removeLastObject];
    
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.timeStamps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeStamp" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Label %d at %@ second", ((int) (indexPath.row + 1)), self.timeStamps[indexPath.row]];
    
    return cell;
    
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    float selectedTimeStamp = [self.timeStamps[indexPath.row] floatValue];
    
    NSLog(@"%f", selectedTimeStamp);
    
    if (selectedTimeStamp > 1.5)
    {
        self.player.currentTime = selectedTimeStamp - 1.5;
        [self.player play];

    }
    else
    {
        self.player.currentTime = selectedTimeStamp;
        [self.player play];
    }
    
    [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];

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
