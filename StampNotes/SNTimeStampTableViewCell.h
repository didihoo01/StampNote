//
//  SNTimeStampTableViewCell.h
//  StampNotes
//
//  Created by Jiahe Kuang on 10/27/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNTimeStampTableViewCell : UITableViewCell

@property (strong, nonatomic) NSString * timeStampTitle;
@property (strong, nonatomic) NSString * timeStampLabelName;


@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;



@end
