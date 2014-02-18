//
//  ConfigurationCell.m
//  Lightr
//
//  Created by Chris on 2/18/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import "ConfigurationCell.h"

#import "TVIcon.h"

@implementation ConfigurationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _icon = [TVIcon iconWithWidth:60.f];
        _icon.center = CGPointMake(40, 40);
        [self.contentView addSubview:_icon];
        
        _name = [[UILabel alloc] initWithFrame:CGRectMake(80, 3, 240, 60)];
        _name.backgroundColor = [UIColor clearColor];
        _name.font = [UIFont boldSystemFontOfSize:18.f];
        [self.contentView addSubview:_name];
        
        _subtext = [[UILabel alloc] initWithFrame:CGRectMake(80, 43, 240, 20)];
        _subtext.backgroundColor = [UIColor clearColor];
        _subtext.textColor = [UIColor lightGrayColor];
        _subtext.font = [UIFont systemFontOfSize:12.f];
        [self.contentView addSubview:_subtext];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
