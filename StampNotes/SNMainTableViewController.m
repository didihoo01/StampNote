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
        
        NSLog(@"%@", self.recordings);
    }
    return self;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    self.tableView
    [self.tableView reloadData];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSError *error;
    NSLog(@"Documents directory: %@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[paths objectAtIndex:0] error:&error]);
    
    
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return [self.recordings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.myTableCell = [tableView dequeueReusableCellWithIdentifier:@"RecordingCell" forIndexPath:indexPath];
    
//    [self.myTableCell.cellTextField  setDelegate:self];
    
    
    self.myTableCell.textLabel.font = [UIFont systemFontOfSize:15];
    
    self.myTableCell.backgroundColor = [self colorForCellAtIndexPath:indexPath];

    [self.myTableCell setLabelName:[self.recordings[indexPath.row] nameLable]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *tempMDYString = [dateFormatter stringFromDate:[self.recordings[indexPath.row] date]];
    
    [dateFormatter setDateFormat:@"hh:mma"];

    NSString *tempHMString = [dateFormatter stringFromDate:[self.recordings[indexPath.row] date]];
    
    [self.myTableCell setTimeLabelName:[NSString stringWithFormat:@"%@ at %@", tempMDYString, tempHMString]];
    
    NSArray *directoryContent  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.recordings[indexPath.row] folderDirectory] error:nil];

    [self.myTableCell setItemLabelName:[NSString stringWithFormat:@"%d", [directoryContent count] / 2]];


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
        newRecordingListTableViewController.recordingColor = [self.tableView cellForRowAtIndexPath:selectedIndexPath].backgroundColor;
        

    }
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSManagedObjectContext *recordingContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    
    [[NSFileManager defaultManager] removeItemAtPath:[self.recordings[indexPath.row] folderDirectory] error:nil];
    
    NSLog(@"Deleting %@", [self.recordings[indexPath.row] folderDirectory]);
    
    [recordingContext deleteObject: self.recordings[indexPath.row]];
    
    [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
    
    [self.recordings removeObjectAtIndex:indexPath.row];
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}

-(NSString*)directoryForNewRecording
{
    NSManagedObjectContext *recordingContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    Recording *newRecording = [NSEntityDescription insertNewObjectForEntityForName:@"Recording" inManagedObjectContext:recordingContext];
    
    newRecording.date = [NSDate date];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    
    
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

- (UIColor*)colorForCellAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger row = indexPath.row;
    
    UIColor* color;
    
    switch (row % 10)
    {
        case 0: color = [UIColor colorWithRed:52/255.0f green:152/255.0f blue:219/255.0f alpha:1.0f]; break;
        case 1: color = [UIColor colorWithRed:46/255.0f green:204/255.0f blue:113/255.0f alpha:1.0f]; break;
        case 2: color = [UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f]; break;
        case 3: color = [UIColor colorWithRed:155/255.0f green:89/255.0f blue:182/255.0f alpha:1.0f]; break;
        case 4: color = [UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f]; break;
        case 5: color = [UIColor colorWithRed:241/255.0f green:196/255.0f blue:15/255.0f alpha:1.0f]; break;
        case 6: color = [UIColor colorWithRed:230/255.0f green:126/255.0f blue:34/255.0f alpha:1.0f]; break;
        case 7: color = [UIColor colorWithRed:231/255.0f green:76/255.0f blue:60/255.0f alpha:1.0f]; break;
        case 8: color = [UIColor colorWithRed:236/255.0f green:240/255.0f blue:241/255.0f alpha:1.0f]; break;
        case 9: color = [UIColor colorWithRed:149/255.0f green:165/255.0f blue:166/255.0f alpha:1.0f]; break;


    }
    
    return color;
}


@end
