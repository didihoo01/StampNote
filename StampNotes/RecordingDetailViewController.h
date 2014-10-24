//
//  RecordingDetailViewController.h
//  StampNotes
//
//  Created by Jiahe Kuang on 10/12/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordingDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

#pragma message "these strings are owned by this ViewController, so 'strong' would be the right keyword to use here instead of 'assign'"
@property (assign, nonatomic) NSString *recordingFilePath;
@property (assign, nonatomic) NSString *stampsFilePath;

@property (strong, nonatomic) NSMutableArray *timeStamps;

@end
