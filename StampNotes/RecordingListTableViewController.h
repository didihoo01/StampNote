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
@property (assign, nonatomic) NSString * currentAlbumFolderPath;

@end
