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



@interface SNMainTableViewController ()



@end

@implementation SNMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSError *error;
    NSLog(@"Documents directory: %@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[paths objectAtIndex:0] error:&error]);
    
}

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
    }
    return self;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.recordings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordingCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.recordings[indexPath.row] name];
    
    return cell;
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

    }
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSManagedObjectContext *candyContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    
    [[NSFileManager defaultManager] removeItemAtPath:[self.recordings[indexPath.row] folderDirectory] error:nil];
    
    NSLog(@"Deleting %@", [self.recordings[indexPath.row] folderDirectory]);
    
    [candyContext deleteObject: self.recordings[indexPath.row]];
    
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
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss-a"];
    
    newRecording.name = [NSString stringWithFormat:@"Album_%@", [dateFormatter stringFromDate:newRecording.date]];
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString * path = [[paths objectAtIndex:0] stringByAppendingPathComponent:newRecording.name];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error: nil];
    }
    
    newRecording.folderDirectory = path;
    [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
    [self.recordings addObject:newRecording];

    
    NSLog(@"Creating %@", newRecording.folderDirectory);
    
    return newRecording.folderDirectory;
}



@end
