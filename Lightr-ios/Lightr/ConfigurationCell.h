//
//  ConfigurationCell.h
//  Lightr
//
//  Created by Chris on 2/18/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TVIcon;

@interface ConfigurationCell : UITableViewCell

@property (nonatomic, strong) TVIcon *icon;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *subtext;

@end
