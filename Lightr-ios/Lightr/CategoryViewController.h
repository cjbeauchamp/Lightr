//
//  CategoryViewController.h
//  Lightr
//
//  Created by Chris on 2/22/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "MasterViewController.h"

@class DetailViewController;

@interface CategoryViewController : UITableViewController
<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, assign) CategoryType categoryType;

@end
