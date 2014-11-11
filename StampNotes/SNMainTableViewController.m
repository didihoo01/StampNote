//
//  SNMainTableViewController.m
//  StampNotes
//
//  Created by Jiahe Kuang on 10/5/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import "SNMainTableViewController.h"
#import "Recording.h"
#import "RecordingListTableViewController.h"
#import "AppDelegate.h"
#import "SNTableViewCell.h"
#import "RecordingListTableViewController.h"

@interface SNMainTableViewController ()
@property(nonatomic, strong) SNTableViewCell *myTableCell;
@property (strong, nonatomic) NSIndexPath *indexPathToBeDeleted;



@end

@implementation SNMainTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if(self = [super initWithCoder:aDecoder])
    {
        
        self.recordings = [NSMutableArray array];
        
        NSManagedObjectContext *recordingContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
        
        NSEntityDescription *recordingEntity = [NSEntityDescription entityForName:@"Recording" inManagedObjectContext:recordingContext];
        
        NSFetchRequest *recordingsFetchRequest = [[NSFetchRequest alloc] init];
        
        [recordingsFetchRequest setEntity:recordingEntity];
        
        NSError *error = nil;
        
        NSArray *recordingList = [recordingContext executeFetchRequest:recordingsFetchRequest error: &error];
        
        self.recordings = [recordingList mutableCopy];
        
//        NSLog(@"%@", self.recordings);
    }
    return self;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    self.tableView
    [self.tableView reloadData];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSError *error;
    NSArray * allFolders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[paths objectAtIndex:0] error:&error];
    
    NSArray *filteredNoteFolders = [allFolders filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH 'Session'"]];
    
    
    for (int i = 0; i < [filteredNoteFolders count]; i++)
    {
        for (int ii = 0;  ii < [self.recordings count]; ii++)
        {
            //if a file in the document folder is not equal to any of the folders in coredata, it means the user just imported a new note folder via itunes, it could happen when a user restores their note or shares their note with others
            if (![[self.recordings[ii] name] isEqualToString:filteredNoteFolders[i]])
            {
                ;
            }
        }
    }
    
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return [self.recordings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.myTableCell = [tableView dequeueReusableCellWithIdentifier:@"RecordingCell" forIndexPath:indexPath];
    
//    [self.myTableCell.cellTextField  setDelegate:self];
    
    
//    self.myTableCell.textLabel.font = [UIFont systemFontOfSize:15];
    
//    self.myTableCell.backgroundColor = [self colorForCellAtIndexPath:indexPath];

    [self.myTableCell setLabelName:[self.recordings[indexPath.row] nameLable]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *tempMDYString = [dateFormatter stringFromDate:[self.recordings[indexPath.row] date]];
    
    [self.myTableCell setDateLabelName:tempMDYString];
    
    [dateFormatter setDateFormat:@"hh:mma"];

    NSString *tempHMString = [dateFormatter stringFromDate:[self.recordings[indexPath.row] date]];
    
    [self.myTableCell setTimeLabelName:tempHMString];
    
    NSArray *directoryContent  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.recordings[indexPath.row] folderDirectory] error:nil];

    [self.myTableCell setItemLabelName:[NSString stringWithFormat:@"%d", (int)[directoryContent count] / 2]];


    return self.myTableCell;
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"newRecordingSession"])
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"newRecordingSession"])
    {
        
        RecordingScreenViewController* newRecordingScreenViewController = [segue destinationViewController];
        newRecordingScreenViewController.delegate = self;
        
    }
    
    else if ([segue.identifier isEqualToString:@"RecordingListView"])
    {
        RecordingListTableViewController *newRecordingListTableViewController = [segue destinationViewController];
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        newRecordingListTableViewController.currentAlbumFolderPath = [self.recordings[selectedIndexPath.row] folderDirectory];
        newRecordingListTableViewController.albumNameString = [self.recordings[selectedIndexPath.row] name];
        newRecordingListTableViewController.albumTextFieldLable = [self.recordings[selectedIndexPath.row] nameLable];
        newRecordingListTableViewController.updatedAlbumList = self.recordings;
//        newRecordingListTableViewController.recordingColor = [self.tableView cellForRowAtIndexPath:selectedIndexPath].backgroundColor;
        

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
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:@"YES", nil];
    [alert show];
    
    }
    
}

-(NSString*)directoryForNewRecording
{
    NSManagedObjectContext *recordingContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    Recording *newRecording = [NSEntityDescription insertNewObjectForEntityForName:@"Recording" inManagedObjectContext:recordingContext];
    
    newRecording.date = [NSDate date];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
//    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    [dateFormatter setLocale:usLocale];
    
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss-a"];
    
    newRecording.name = [NSString stringWithFormat:@"Session_%@", [dateFormatter stringFromDate:newRecording.date]];

    newRecording.nameLable = @"Untitled";

    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString * path = [[paths objectAtIndex:0] stringByAppendingPathComponent:newRecording.name];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    }
    
    newRecording.folderDirectory = path;
    [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
    
    [self.recordings addObject:newRecording];

    
    NSLog(@"Creating %@", newRecording.folderDirectory);
    
    return newRecording.folderDirectory;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"NO"])
    {
        NSLog(@"Nothing to do here");
    }
    else if([title isEqualToString:@"YES"])
    {
        NSLog(@"Delete the FOLDER");
        
        NSManagedObjectContext *recordingContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
        
        
        [[NSFileManager defaultManager] removeItemAtPath:[self.recordings[self.indexPathToBeDeleted.row] folderDirectory] error:nil];
        
        NSLog(@"Deleting %@", [self.recordings[self.indexPathToBeDeleted.row] folderDirectory]);
        
        [recordingContext deleteObject: self.recordings[self.indexPathToBeDeleted.row]];
        
        [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
        
        [self.recordings removeObjectAtIndex:self.indexPathToBeDeleted.row];
        
        [self.tableView deleteRowsAtIndexPaths:@[self.indexPathToBeDeleted] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


@end
