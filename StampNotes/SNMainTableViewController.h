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


@interface SNMainTableViewController : UITableViewController<RecordingScreenViewControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@property(nonatomic, strong) NSMutableArray *recordings;
@end
