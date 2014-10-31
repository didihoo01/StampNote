//
//  SNTimeStampTableViewCell.m
//  StampNotes
//
//  Created by Jiahe Kuang on 10/27/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import "SNTimeStampTableViewCell.h"


@interface SNTimeStampTableViewCell()


@end

@implementation SNTimeStampTableViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/




- (void)setTimeStampLabelName:(NSString *)timeStampLabelName
{
    if (_timeStampLabelName != timeStampLabelName)
    {
        _timeStampLabelName = [timeStampLabelName copy];
    }
    
    self.timeStampLabel.text = _timeStampLabelName;
}



@end
