//
//  RecordingListTableViewController.h
//  StampNotes
//
//  Created by Jiahe Kuang on 10/6/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordingScreenViewController.h"



@interface RecordingListTableViewController : UITableViewController <RecordingScreenViewControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray * recordingList;
@property (strong, nonatomic) NSString * currentAlbumFolderPath;
@property (strong, nonatomic) NSString * albumNameString;
@property (weak, nonatomic) IBOutlet UITextField *albumName;
@property (strong, nonatomic) NSMutableArray *updatedAlbumList;
@property (strong, nonatomic) UIColor *recordingColor;


@end
