//
//  SNMainTableViewController.h
//  StampNotes
//
//  Created by Jiahe Kuang on 10/5/14.
//  Copyright (c) 2014 Jiahe Kuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNMainTableViewController : UITableViewController<UIAlertViewDelegate>

@property(nonatomic, strong) NSMutableArray* recordings;

@end
