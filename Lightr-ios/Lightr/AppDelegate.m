//
//  AppDelegate.m
//  Lightr
//
//  Created by Chris on 2/13/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "Configuration.h"

#import <CoreData/CoreData.h>

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    splitViewController.delegate = (id)navigationController.topViewController;
    
    // clear all the existing configs (besides user generated types)
    // Populate the manufacturerNameList array
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"Configuration" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:ed];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryType != %d AND categoryType != %d", CategoryTypeFavorite, CategoryTypeRecent];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for(Configuration *c in results) {
        [self.managedObjectContext deleteObject:c];
    }
    [self saveContext];

    
    // load the config files into core data
    NSString *dirString = [[NSBundle mainBundle] resourcePath];
    
    for(NSString *dirFile in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirString error:nil]) {
        if([dirFile rangeOfString:@".config"].location != NSNotFound) {
            
            NSString *path = [dirString stringByAppendingPathComponent:dirFile];
            
            // read the config
            NSData *fileData = [NSData dataWithContentsOfFile:path];
            
            NSString *configString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
            
            // get our definitions
            NSArray *lines = [configString componentsSeparatedByString:@"\n"];
            
            NSMutableArray *settingLines = [NSMutableArray array];
            NSMutableArray *configLines = [NSMutableArray array];
            
            for(NSString *line in lines) {
                
                BOOL isConfig = [line rangeOfString:@"=>"].location != NSNotFound;
                
                if(isConfig) {
                    [settingLines addObject:line];
                } else if(line.length > 0) {
                    [configLines addObject:line];
                }
                
            }
            
            NSLog(@"configlines: %@", configLines);
            
            NSMutableDictionary *settings = [NSMutableDictionary dictionary];
            [settings setObject:[NSMutableDictionary dictionary] forKey:@"colors"];
            
            for(NSString *setting in settingLines) {
                
                NSArray *scomps = [setting componentsSeparatedByString:@"=>"];
                NSString *key = [[scomps objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *value = [[scomps lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                // parsing a color
                if([key rangeOfString:@"color_"].location != NSNotFound) {
                    
                    NSError *error = nil;
                    NSString *pattern = @"color_(.*?) => rgb\\(([0-9]+), ([0-9]+), ([0-9]+)\\)";

                    NSRange range = NSMakeRange(0, setting.length);
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
                    NSArray *matches = [regex matchesInString:setting options:0 range:range];
                    
                    for (NSTextCheckingResult *match in matches) {
                        
                        NSString *colorKey = [setting substringWithRange:[match rangeAtIndex:1]];
                        NSString *red = [setting substringWithRange:[match rangeAtIndex:2]];
                        NSString *green = [setting substringWithRange:[match rangeAtIndex:3]];
                        NSString *blue = [setting substringWithRange:[match rangeAtIndex:4]];
                        
                        UIColor *color = [UIColor colorWithRed:red.doubleValue/255.f green:green.doubleValue/255.f blue:blue.doubleValue/255.f alpha:1.0f];
                        [[settings objectForKey:@"colors"] setObject:color forKey:colorKey];
                        
                    }
                } else {
                    [settings setObject:value forKey:key];
                }
            }
            
            NSLog(@"Got Settings: %@", settings);

            NSMutableArray *colors = [NSMutableArray array];
            
            NSMutableString *finalString = [NSMutableString stringWithString:@""];
            
            // read the bottom line (backwards)
            NSMutableString *reversed = [NSMutableString stringWithString:@""];
            for(int i = ((NSString*)[configLines lastObject]).length-1; i>=0; i--) {
                [reversed appendString:[[configLines lastObject] substringWithRange:NSMakeRange(i, 1)]];
            }
            [finalString appendString:reversed];
            
            // read the left column (bottom to top)
            for(int i=configLines.count-2; i>=0; i--) {
                NSString *line = [configLines objectAtIndex:i];
                [finalString appendString:[line substringToIndex:1]];
            }
            
            // read the top line
            [finalString appendString:[[configLines objectAtIndex:0] substringFromIndex:1]];
            
            // read the right column
            for(int i=1; i<configLines.count-1; i++) {
                NSString *line = [configLines objectAtIndex:i];
                [finalString appendString:[line substringFromIndex:line.length-1]];
            }
            
            for(int i=0; i<finalString.length; i++) {
                NSString *key = [finalString substringWithRange:NSMakeRange(i, 1)];
                [colors addObject:[[settings objectForKey:@"colors"] objectForKey:key]];
            }
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Configuration" inManagedObjectContext:self.managedObjectContext];
            Configuration *newObj = (Configuration*)[NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.managedObjectContext];
            
            // If appropriate, configure the new managed object.
            // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
            newObj.created = [NSDate date];
            newObj.categoryType = [NSNumber numberWithInteger:[[settings objectForKey:@"category"] integerValue]];
            newObj.colors = colors;
            newObj.name = [settings objectForKey:@"name"];
            newObj.configurationString = finalString;
            
            // Save the context.
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
        }
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Lightr" withExtension:@"mom"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Lightr.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (AppDelegate*) shared
{
	return (AppDelegate *)[UIApplication sharedApplication].delegate;
}


@end
