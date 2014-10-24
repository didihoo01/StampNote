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

#pragma message "This should be stored 'strong'"
@property (nonatomic, assign) NSString *recordingForFilePath;
#pragma message "This should be stored 'weak'"
@property (nonatomic, assign) id <RecordingScreenViewControllerDelegate> delegate;
@property (nonatomic, assign) float stampTimer;


@end
