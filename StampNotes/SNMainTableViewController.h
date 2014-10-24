//
//  SNMainTableViewController.h
//  StampNotes
//
//  Created by Jiahe Kuang on 10/5/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordingScreenViewController.h"
#import "RecordingListTableViewController.h"


@interface SNMainTableViewController : UITableViewController<RecordingScreenViewControllerDelegate, UITextFieldDelegate>
#pragma message "Spacing! You don't need that many empty lines!"


@property(nonatomic, strong) NSMutableArray *recordings;


@end
