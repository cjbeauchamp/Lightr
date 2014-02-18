//
//  AppDelegate.h
//  Lightr
//
//  Created by Chris on 2/13/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MasterViewController, DetailViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) MasterViewController *masterViewController;
@property (nonatomic, strong) DetailViewController *detailViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (AppDelegate*) shared;

@end
