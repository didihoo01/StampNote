//
//  RecordingListTableViewController.m
//  StampNotes
//
//  Created by Jiahe Kuang on 10/6/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import "RecordingListTableViewController.h"
#import "Recording.h"
#import "AppDelegate.h"

@interface RecordingListTableViewController ()



@end

@implementation RecordingListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.recordingList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordingDetailView" forIndexPath:indexPath];
    
//    cell.textLabel.text = [self.recordingList[indexPath.row] name];
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddNewRecordingToCurrentAlbum"])
    {
        RecordingScreenViewController *newRecordingScreenViewController = [RecordingScreenViewController new];
        newRecordingScreenViewController = [segue destinationViewController];
        
    }
}

-(NSString *)directoryForNewRecording
{
    return self.currentAlbumFolderPath;
}

@end
