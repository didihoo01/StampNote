//
//  SNTableViewCell.m
//  StampNotes
//
//  Created by Jiahe Kuang on 10/19/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import "SNTableViewCell.h"

@interface SNTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation SNTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setters

- (void)setLabelName:(NSString *) labelName
{
    if (_labelName != labelName)
    {
        _labelName = [labelName copy];
    }
    
    self.label.text = _labelName;
}

-(void)setTimeLabelName:(NSString *)timeLabelName
{
    if (_timeLabelName != timeLabelName)
    {
        _timeLabelName = [timeLabelName copy];
    }
    
    self.timeLabel.text = _timeLabelName;
}

-(void)setDateLabelName:(NSString *)dateLabelName
{
    if (_dateLabelName != dateLabelName)
    {
        _dateLabelName = [dateLabelName copy];
    }
    self.dateLabel.text = _dateLabelName;
}

-(void)setItemLabelName:(NSString *)itemLabelName
{
    if (_itemLabelName != itemLabelName)
    {
        _itemLabelName = [itemLabelName copy];
    }
    self.itemLabel.text = _itemLabelName;

}


@end
