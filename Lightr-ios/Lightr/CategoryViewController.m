//
//  CategoryViewController.m
//  Test
//
//  Created by Chris on 2/18/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import "CategoryViewController.h"

#import "DetailViewController.h"
#import "ConfigurationCell.h"
#import "Configuration.h"
#import "AppDelegate.h"
#import "TVIcon.h"

@interface CategoryViewController () {
    NSArray *_rowData;
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (NSString*) timeAgo:(NSDate*)date isShortened:(BOOL)shortened;
@end

@implementation CategoryViewController

- (NSString*) timeAgo:(NSDate*)date isShortened:(BOOL)shortened
{
    NSString *retString = @"";
    double changeSeconds = [[NSDate date] timeIntervalSinceDate:date];
    int changeSecondInt = (int) changeSeconds;
    int changeMinutes = floor(changeSeconds / 60);
    int changeHours = floor(changeMinutes / 60);
    int changeDays = floor(changeHours / 24);
    int changeWeeks = floor(changeDays / 7);
    int changeMonths = floor(changeWeeks / 4);
    int changeYears = floor(changeMonths / 12);
    
    if(changeSeconds < 5) {
        retString = @"Just Now";
    } else if(changeSeconds < 60) {
        retString = [NSString stringWithFormat:@"%d%@%@ ago", changeSecondInt, (shortened?@"s":@" second"), (changeSecondInt==1||shortened)?@"":@"s"];
    } else if(changeMinutes < 60) {
        retString = [NSString stringWithFormat:@"%d%@%@ ago", changeMinutes, (shortened?@"m":@" minute"), (changeMinutes==1||shortened)?@"":@"s"];
    } else if(changeHours < 24) {
        retString = [NSString stringWithFormat:@"%d%@%@ ago", changeHours, (shortened?@"h":@" hour"), (changeHours==1||shortened)?@"":@"s"];
    } else if(changeDays < 7) {
        retString = [NSString stringWithFormat:@"%d%@%@ ago", changeDays, (shortened?@"d":@" day"), (changeDays==1||shortened)?@"":@"s"];
    } else if(changeWeeks < 4) {
        retString = [NSString stringWithFormat:@"%d%@%@ ago", changeWeeks, (shortened?@"w":@" week"), (changeWeeks==1||shortened)?@"":@"s"];
    } else if(changeMonths < 12) {
        retString = [NSString stringWithFormat:@"%d%@%@ ago", changeMonths, (shortened?@"mo":@" month"), (changeMonths==1||shortened)?@"":@"s"];
    } else {
        retString = [NSString stringWithFormat:@"%d%@%@ ago", changeYears, (shortened?@"y":@" year"), (changeYears==1||shortened)?@"":@"s"];
    }
    
    return retString;
}


- (void)awakeFromNib
{
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7" options:NSNumericSearch] != NSOrderedAscending) {
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.managedObjectContext = [AppDelegate shared].managedObjectContext;
    
	// Do any additional setup after loading the view, typically from a nib.
    if(_categoryType == CategoryTypeRecent || _categoryType == CategoryTypeFavorite) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
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
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"CELL_%d", indexPath.row];
    
    ConfigurationCell *cell = (ConfigurationCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ConfigurationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return (UITableViewCell*) cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return (_categoryType == CategoryTypeFavorite || _categoryType == CategoryTypeRecent);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Configuration *object = (Configuration*) [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSMutableString *msg = [NSMutableString stringWithFormat:@"Deleting[category=%d] =>", object.categoryType.integerValue];
        for(UIColor *c in object.colors) { [msg appendFormat:@" (%@)", c.description]; }
        [[AppDelegate shared].detailViewController addLog:msg];
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:object];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Configuration *object = (Configuration*) [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    [[AppDelegate shared].detailViewController.previewTV setupWithConfiguration:object];
    
    NSMutableString *msg = [NSMutableString stringWithFormat:@"Restoring[category=%d] =>", object.categoryType.integerValue];
    
    // log the colors
    for(UIColor *c in object.colors) {
        [msg appendFormat:@" (%@)", c.description];
    }
    
    [[AppDelegate shared].detailViewController addLog:msg];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Configuration" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:100];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryType == %@", [NSNumber numberWithInteger:_categoryType]];
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSLog(@"Req => %@", fetchRequest);
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil]; //@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)configureCell:(ConfigurationCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Configuration *object = (Configuration*) [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if(object.name != nil) {
        cell.name.text = object.name;
    } else {
        cell.name.text = [NSString stringWithFormat:@"Applied %@", [self timeAgo:object.created isShortened:FALSE]];
    }
    
    if(object.categoryType.integerValue == CategoryTypeFavorite ||
       object.categoryType.integerValue == CategoryTypeRecent)
    {
        cell.subtext.text = [object.created description];
    }
    
    [cell.icon setupWithConfiguration:object];
}

@end
