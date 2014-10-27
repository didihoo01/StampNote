//
//  SNTableViewCell.m
//  StampNotes
//
//  Created by Jiahe Kuang on 10/19/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import "SNTableViewCell.h"

@interface SNTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
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

- (void)setAlbumName:(NSString *) albumName
{
    if (_albumName != albumName)
    {
        _albumName = [albumName copy];
    }
    
    self.albumLabel.text = _albumName;
}


@end
