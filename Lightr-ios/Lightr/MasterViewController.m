//
//  MasterViewController.m
//  Test
//
//  Created by Chris on 2/18/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import "MasterViewController.h"

#import "CategoryViewController.h"
#import "DetailViewController.h"
#import "ConfigurationCell.h"
#import "Configuration.h"
#import "AppDelegate.h"
#import "TVIcon.h"

@interface MasterViewController () {
    NSArray *_rowData;
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7" options:NSNumericSearch] != NSOrderedAscending) {
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }

    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AppDelegate shared].masterViewController = self;
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    // set up our sections
    _rowData = @[
                 [NSNumber numberWithInteger:CategoryTypeRecent],
                 [NSNumber numberWithInteger:CategoryTypeFavorite],
                 [NSNumber numberWithInteger:CategoryTypeStandard],
                 [NSNumber numberWithInteger:CategoryTypeAnimated],
                 [NSNumber numberWithInteger:CategoryTypeFlags],
                 [NSNumber numberWithInteger:CategoryTypeOther]
                 ];
    
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rowData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"CELL_%d", indexPath.row];
    
    UITableViewCell *cell = (UITableViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryType category = [[_rowData objectAtIndex:indexPath.row] integerValue];
    NSMutableString *msg = [NSMutableString stringWithFormat:@"Browsing category => %d", category];
    
    [[AppDelegate shared].detailViewController addLog:msg];
    
    CategoryViewController *vc = [[CategoryViewController alloc] init];
    vc.categoryType = [[_rowData objectAtIndex:indexPath.row] integerValue];
    [self.navigationController pushViewController:vc animated:TRUE];
    
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    CategoryType category = [[_rowData objectAtIndex:indexPath.row] integerValue];
    
    NSString *catString = @"Error";
    
    switch (category) {
        case CategoryTypeAnimated: catString = @"Animated Patterns"; break;
        case CategoryTypeStandard: catString = @"Standard Patterns"; break;
        case CategoryTypeRecent: catString = @"Recent"; break;
        case CategoryTypeFavorite: catString = @"Favorites"; break;
        case CategoryTypeFlags: catString = @"Flags"; break;
        case CategoryTypeOther: catString = @"Other"; break;
        default: break;
    }
    
    cell.textLabel.text = catString;
}

@end
