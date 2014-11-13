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
#import "SNTableViewCell.h"
#import <AVFoundation/AVFoundation.h>


@interface RecordingListTableViewController ()
@property (strong, nonatomic) NSIndexPath *indexPathToBeDeleted;
@property (strong, nonatomic) NSDateFormatter *tableCellDateFormatter;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSString * albumNameBeforeChange;

@end

@implementation RecordingListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableCellDateFormatter = [[NSDateFormatter alloc] init];


//    self.tableView.backgroundColor = self.recordingColor;
    
    self.recordingList = [NSMutableArray new];
    
    NSError *error;
    
    NSLog(@"At %@", self.currentAlbumFolderPath);
    
    
    NSArray *allContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.currentAlbumFolderPath error:&error];
    
    self.recordingList = [[allContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.m4a'"]] mutableCopy];
    
    [self.albumName setDelegate:self];
            
    [self.tableView reloadData];
    
    self.albumName.text = self.albumTextFieldLable;
    
    self.albumNameBeforeChange = self.albumName.text;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.recordingList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SNTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordingDetailView" forIndexPath:indexPath];
    
//    cell.backgroundColor = self.recordingColor;
    
//    cell.labelName = self.recordingList[indexPath.row];
    
    NSString *recordingPath = [NSString stringWithFormat:@"%@/%@", self.currentAlbumFolderPath, self.recordingList[indexPath.row]];
    
    NSURL *recordingURL = [NSURL fileURLWithPath:recordingPath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordingURL error:nil];
    
    cell.labelName = [self timeFormatted:[self.player duration]];
    
    
    
    NSDictionary *recordingAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:recordingPath error:nil];
    
    NSDate *date = (NSDate*)[recordingAttributes objectForKey: NSFileCreationDate];
    
    cell.fileSizeLabelName = [NSString stringWithFormat:@"%.02f",([[recordingAttributes objectForKey:NSFileSize] floatValue] / (1000000))];
    
    NSLog(@"%@", cell.fileSizeLabelName);
        
    [self.tableCellDateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    cell.dateLabelName = [self.tableCellDateFormatter stringFromDate:date];
    
    [self.tableCellDateFormatter setDateFormat:@"hh:mm a"];

    cell.timeLabelName = [self.tableCellDateFormatter stringFromDate:date];
    
    
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
        newRecordingDetailViewController.stampsFilePath = [newRecordingDetailViewController.recordingFilePath
                                                           stringByReplacingOccurrencesOfString:@".m4a" withString:@".txt"];
//        newRecordingDetailViewController.timeStampColor = self.recordingColor;
        
        NSLog(@"We have %@ and %@",newRecordingDetailViewController.recordingFilePath, newRecordingDetailViewController.stampsFilePath);
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    
    if ([identifier isEqualToString:@"AddNewRecordingToCurrentAlbum"])
    {
        NSError *error = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
        if (dictionary)
        {
            float freeSpace  = [[dictionary objectForKey: NSFileSystemFreeSize] longLongValue];
            float totalSpace = [[dictionary objectForKey: NSFileSystemSize] longLongValue];
            NSLog(@"Free Space: %f MB, Total Space: %f MB", freeSpace / 1048576 , totalSpace / 1048576);
            if (freeSpace < 400)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning"
                                                                message: @"Not enough space, clean up your device"
                                                               delegate: nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                return NO;
            }
        }

    }
    
    return YES;
}

-(NSString *)directoryForNewRecording
{
    return self.currentAlbumFolderPath;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.albumName resignFirstResponder];
    [self checkFilesWithSameName];
    return YES;
}

-(void)checkFilesWithSameName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"Documents directory at: %@", [paths objectAtIndex:0]);
    NSLog(@"Checking %@ if it exists", self.albumName.text);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], self.albumName.text]])
    {
        if (![self.albumName.text isEqualToString: self.albumNameString])
        {
            NSString * tempErrorMessage = [NSString new];
            
            if ([self.albumName.text isEqualToString:@""])
            {
                tempErrorMessage = [NSString stringWithFormat:@"Can't have an empty name"];
            }
            
            else
            {
                tempErrorMessage = [NSString stringWithFormat:@"File named %@ exists", self.albumName.text];
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning"
                                                            message: tempErrorMessage
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            self.albumName.text = self.albumNameBeforeChange;
            [alert show];

        }
        
    }
    
    else
    {
        NSManagedObjectContext *recordingContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
        
        NSEntityDescription *recordingEntity = [NSEntityDescription entityForName:@"Recording" inManagedObjectContext:recordingContext];
        
        NSFetchRequest *recordingsFetchRequest = [[NSFetchRequest alloc] init];
        
        [recordingsFetchRequest setEntity:recordingEntity];
        
        NSError *error = nil;
        
        NSMutableArray *albumList = [[recordingContext executeFetchRequest:recordingsFetchRequest error: &error] mutableCopy];
        
        for (int i = 0; i < [albumList count]; i++)
        {
            if ([[albumList[i] name] isEqualToString:self.albumNameString])
            {
                
                [[NSFileManager defaultManager] moveItemAtPath:self.currentAlbumFolderPath
                                                        toPath: [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], self.albumName.text]
                                                         error:nil];

                
                Recording *newAlbum = [NSEntityDescription insertNewObjectForEntityForName:@"Recording" inManagedObjectContext:recordingContext];
                
                newAlbum.date = [albumList[i] date];
                [recordingContext deleteObject:albumList[i]];
                
                [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
                
                newAlbum.name = self.albumName.text;
                newAlbum.nameLable = self.albumName.text;
                NSLog(@"new album Name %@", newAlbum.name);
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                
                NSString * path = [[paths objectAtIndex:0] stringByAppendingPathComponent:newAlbum.name];
                
//                newAlbum.folderDirectory = path;
                self.currentAlbumFolderPath = path;
                
                [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
                
                [self.updatedAlbumList removeAllObjects];
                
                [self.updatedAlbumList addObjectsFromArray:[recordingContext executeFetchRequest:recordingsFetchRequest error: &error]];
                break;
            }
        }
        NSLog(@"Folder renamed!");
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        self.indexPathToBeDeleted = indexPath;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Are you sure?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
        
    }
    

    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"No"])
    {
        NSLog(@"Nothing to do here");
    }
    else if([title isEqualToString:@"Yes"])
    {
        NSLog(@"Delete the Track");
        
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", self.currentAlbumFolderPath, self.recordingList[self.indexPathToBeDeleted.row]] error:nil];
        
        [self.recordingList removeObjectAtIndex:self.indexPathToBeDeleted.row];
        
        [self.tableView deleteRowsAtIndexPaths:@[self.indexPathToBeDeleted] withRowAnimation:UITableViewRowAnimationAutomatic];    }
}

- (NSString *)timeFormatted:(float)totalSecondsInFloatingPoint
{
    
    int totalSeconds = floor(lroundf(totalSecondsInFloatingPoint));
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

@end
