//
//  RecordingDetailViewController.h
//  StampNotes
//
//  Created by Jiahe Kuang on 10/12/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordingDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (assign, nonatomic) NSString *recordingFilePath;
@property (assign, nonatomic) NSString *stampsFilePath;

@property (strong, nonatomic) NSMutableArray *timeStamps;

@end
