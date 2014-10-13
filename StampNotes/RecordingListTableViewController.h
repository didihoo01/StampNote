//
//  RecordingListTableViewController.h
//  StampNotes
//
//  Created by Jiahe Kuang on 10/6/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordingScreenViewController.h"

@interface RecordingListTableViewController : UITableViewController <RecordingScreenViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray * recordingList;
#pragma message "'assign' should only be used for primitive types. In this case I'm pretty sure you want to store the string object 'strong'"
@property (assign, nonatomic) NSString * currentAlbumFolderPath;

@end
