//
//  TVIcon.h
//  Lightr
//
//  Created by Chris on 2/13/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Configuration;

@interface TVIcon : UIView

@property (nonatomic, assign) Configuration *configuration;
@property (nonatomic, strong) NSArray *currentColors;

+ (TVIcon*) iconWithWidth:(CGFloat)width;

- (void) setupWithConfiguration:(Configuration*)configuration;
- (NSInteger) indexAtTapPosition:(CGPoint)pt;
- (void) replaceColorAtIndex:(NSUInteger)ndx withColor:(UIColor*)color;

@end
