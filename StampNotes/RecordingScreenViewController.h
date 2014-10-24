//
//  RecordingScreenViewController.h
//  StampNotes
//
//  Created by Jiahe Kuang on 10/6/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RecordingScreenViewControllerDelegate

-(NSString*)directoryForNewRecording;

@end

@interface RecordingScreenViewController : UIViewController

@property (nonatomic, strong) NSString *recordingForFilePath;
@property (nonatomic, weak) id <RecordingScreenViewControllerDelegate> delegate;
@property (nonatomic, assign) float stampTimer;


@end
