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
    
    
    NSArray *allContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.currentAlbumFolderPath error:&error];
    
    self.recordingList = [[allContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.m4a'"]] mutableCopy];
    
    [self.albumName setDelegate:self];
            
    [self.tableView reloadData];
    
    self.albumName.text = self.albumNameString;

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
        newRecordingDetailViewController.stampsFilePath = [newRecordingDetailViewController.recordingFilePath
                                                           stringByReplacingOccurrencesOfString:@".m4a" withString:@".txt"];
        
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning"
                                                            message: [NSString stringWithFormat:@"File named %@ exists", self.albumName.text]
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
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
                
                [[NSFileManager defaultManager] moveItemAtPath:[albumList[i] folderDirectory]
                                                        toPath: [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], self.albumName.text]
                                                         error:nil];

                
                Recording *newAlbum = [NSEntityDescription insertNewObjectForEntityForName:@"Recording" inManagedObjectContext:recordingContext];
                
                newAlbum.date = [albumList[i] date];
                [recordingContext deleteObject:albumList[i]];
                
                [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
                
                newAlbum.name = self.albumName.text;
                NSLog(@"new album Name %@", newAlbum.name);
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                
                NSString * path = [[paths objectAtIndex:0] stringByAppendingPathComponent:newAlbum.name];
                
                newAlbum.folderDirectory = path;
                
                [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
                
                [self.updatedAlbumList removeAllObjects];
                
                [self.updatedAlbumList addObjectsFromArray:[recordingContext executeFetchRequest:recordingsFetchRequest error: &error]];
                break;
            }
        }
        NSLog(@"Folder renamed!");
    }
}


@end
