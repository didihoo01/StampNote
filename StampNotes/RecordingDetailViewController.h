//
//  RecordingDetailViewController.h
//  StampNotes
//
//  Created by Jiahe Kuang on 10/12/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordingDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) NSString *recordingFilePath;
@property (strong, nonatomic) NSString *stampsFilePath;

@property (strong, nonatomic) NSMutableArray *timeStamps;
@property (strong, nonatomic) UIColor *timeStampColor;

@property (weak, nonatomic) IBOutlet UILabel *timeElapsed;
@property (weak, nonatomic) IBOutlet UILabel *timeDuration;
@property (weak, nonatomic) IBOutlet UISlider *curretTimeSlider;

@property BOOL isPaused;
@property BOOL scrubbing;

@property NSTimer *timer;

@end
