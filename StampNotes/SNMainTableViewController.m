//
//  SNMainTableViewController.m
//  StampNotes
//
//  Created by Jiahe Kuang on 10/5/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import "SNMainTableViewController.h"
#import "Recording.h"
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
- (IBAction)createNewClass:(id)sender
{
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Enter a Title" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex ==1)
    {
        NSManagedObjectContext *recordingContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
        
        Recording *newRecording = [NSEntityDescription insertNewObjectForEntityForName:@"Recording" inManagedObjectContext:recordingContext];
        newRecording.name = [alertView textFieldAtIndex:0].text;
        [self.recordings addObject:newRecording];
        [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
        [self performSegueWithIdentifier: @"RecordingScreen" sender: self];

    }
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
