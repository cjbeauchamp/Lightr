//
//  TVIcon.h
//  Lightr
//
//  Created by Chris on 2/13/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    TVConfigurationWhole,
    TVConfigurationSplitHorizontal,
    TVConfigurationSplitVertical,
    TVConfigurationSplitHorizontalThirds,
    TVConfigurationSplitVerticalThirds,
    TVConfigurationSplitQuadrants
};

typedef NSUInteger TVConfiguration;

@interface TVIcon : UIView

@property (nonatomic, assign) TVConfiguration configuration;
@property (nonatomic, strong) NSArray *colors;

+ (TVIcon*) iconWithWidth:(CGFloat)width;

- (void) configure:(TVConfiguration)config withColors:(NSArray*)colors;
- (NSInteger) indexAtTapPosition:(CGPoint)pt;
- (void) replaceColorAtIndex:(NSUInteger)ndx withColor:(UIColor*)color;

@end
