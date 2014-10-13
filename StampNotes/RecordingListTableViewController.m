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
#import "RecordingDetailViewController.h"

@interface RecordingListTableViewController ()


@end

@implementation RecordingListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.recordingList = [NSMutableArray new];
    
    NSError *error;
    
    NSLog(@"At %@", self.currentAlbumFolderPath);
    
    self.recordingList = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.currentAlbumFolderPath error:&error] mutableCopy];
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.recordingList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordingDetailView" forIndexPath:indexPath];
    
    cell.textLabel.text = self.recordingList[indexPath.row];
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddNewRecordingToCurrentAlbum"])
    {
        RecordingScreenViewController *newRecordingScreenViewController = [segue destinationViewController];
        newRecordingScreenViewController.delegate = self;
    }
    
    else if ([segue.identifier isEqualToString:@"RecordingDetailView"])
    {
        RecordingDetailViewController *newRecordingDetailViewController = [segue destinationViewController];
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        newRecordingDetailViewController.recordingFilePath = [NSString stringWithFormat:@"%@/%@", self.currentAlbumFolderPath, self.recordingList[selectedIndexPath.row]];
        NSLog(@"%@", newRecordingDetailViewController.recordingFilePath);
    }
}

-(NSString *)directoryForNewRecording
{
    return self.currentAlbumFolderPath;
}

@end
