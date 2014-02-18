//
//  Configuration.h
//  Lightr
//
//  Created by Chris on 2/18/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Configuration : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * configurationType;
@property (nonatomic, retain) id colors;
@property (nonatomic, retain) NSNumber * isFavorite;

@end