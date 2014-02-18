//
//  MasterViewController.h
//  Lightr
//
//  Created by Chris on 2/13/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController
<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) IBOutlet UISegmentedControl *segment;

- (IBAction) segmentChanged:(id)sender;

@end
