//
//  MasterViewController.h
//  Lightr
//
//  Created by Chris on 2/13/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

enum {
    CategoryTypeNone = 0,
    CategoryTypeRecent = 1,
    CategoryTypeFavorite = 2,
    CategoryTypeStandard = 3,
    CategoryTypeAnimated = 4,
    CategoryTypeFlags = 5,
    CategoryTypeOther = 6
}; typedef NSUInteger CategoryType;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
