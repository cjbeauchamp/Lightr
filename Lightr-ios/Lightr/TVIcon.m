//
//  TVIcon.m
//  Lightr
//
//  Created by Chris on 2/13/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import "TVIcon.h"

#define ASPECT_RATIO        3/4
#define HORIZ_BLOCK_COUNT   16.f
#define VERT_BLOCK_COUNT    8.f

@interface TVIcon()

- (void) reconfigure;
+ (NSDictionary*) configDict;

@end

@implementation TVIcon

+ (NSDictionary*) configDict
{
    NSMutableDictionary *configDict = [NSMutableDictionary dictionary];
    [configDict setObject:@"00000000000000000000000000000000000000000000"
                   forKey:[NSNumber numberWithInt:TVConfigurationWhole]];
    [configDict setObject:@"00000000111111111111111111111100000000000000"
                   forKey:[NSNumber numberWithInt:TVConfigurationSplitHorizontal]];
    [configDict setObject:@"00000000000000000001111111111111111111111000"
                   forKey:[NSNumber numberWithInt:TVConfigurationSplitVertical]];
    [configDict setObject:@"00000111111222222222222222211111100000000000"
                   forKey:[NSNumber numberWithInt:TVConfigurationSplitHorizontalThirds]];
    [configDict setObject:@"00000000000000000111122222222222222222211110"
                   forKey:[NSNumber numberWithInt:TVConfigurationSplitVerticalThirds]];
    [configDict setObject:@"00000000111111111112222222222233333333333000"
                   forKey:[NSNumber numberWithInt:TVConfigurationSplitQuadrants]];

    return [NSDictionary dictionaryWithDictionary:configDict];
}

+ (TVIcon*) iconWithWidth:(CGFloat)width
{
    CGFloat newWidth = roundf(width / HORIZ_BLOCK_COUNT) * HORIZ_BLOCK_COUNT;
    CGFloat newHeight = roundf(newWidth * ASPECT_RATIO / VERT_BLOCK_COUNT) * VERT_BLOCK_COUNT;
    CGRect frame = CGRectMake(0, 0, newWidth, newHeight);
    TVIcon *icon = [[TVIcon alloc] initWithFrame:frame];
    icon.backgroundColor = [UIColor blackColor];
    return icon;
}

- (NSInteger) indexAtTapPosition:(CGPoint)pt
{
    NSInteger ndx = -1;
    
    UIView *v = [self hitTest:pt withEvent:nil];
    
    if(![v isKindOfClass:[TVIcon class]]) {
        
        NSInteger tag = v.tag;
        NSString *items = [[TVIcon configDict] objectForKey:[NSNumber numberWithInteger:_configuration]];
        NSString *item = [items substringWithRange:NSMakeRange(tag, 1)];
        
        ndx = item.integerValue;
    }
    
    
    return ndx;
}

- (void) replaceColorAtIndex:(NSUInteger)ndx withColor:(UIColor*)color
{
    NSMutableArray *colors = [_colors mutableCopy];
    [colors replaceObjectAtIndex:ndx withObject:color];
    _colors = [NSArray arrayWithArray:colors];
    
    [self reconfigure];
}

- (void) configure:(TVConfiguration)config
        withColors:(NSArray*)colors
{
    _colors = colors;
    _configuration = config;
    
    [self reconfigure];
}

- (void) reconfigure
{
    // clear the subviews
    for(UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    
    // draw our frame
    CGFloat blockWidth = roundf(self.frame.size.width / HORIZ_BLOCK_COUNT);
    CGFloat blockHeight = roundf(self.frame.size.width * ASPECT_RATIO / VERT_BLOCK_COUNT);
    
    for(int i=0; i<HORIZ_BLOCK_COUNT; i++) {
        UIView *topBlock = [[UIView alloc] initWithFrame:CGRectMake(i*blockWidth, 0, blockWidth, blockHeight)];
        topBlock.backgroundColor = [UIColor blackColor];
        topBlock.tag = i;
        [self addSubview:topBlock];
        
        UIView *bottomBlock = [[UIView alloc] initWithFrame:CGRectMake(i*blockWidth, self.frame.size.height-blockHeight, blockWidth, blockHeight)];
        bottomBlock.backgroundColor = [UIColor blackColor];
        bottomBlock.tag = HORIZ_BLOCK_COUNT + VERT_BLOCK_COUNT - 2 + (HORIZ_BLOCK_COUNT - i) - 1;
        [self addSubview:bottomBlock];
    }
    
    for(int i=1; i<VERT_BLOCK_COUNT-1; i++) {
        UIView *leftBlock = [[UIView alloc] initWithFrame:CGRectMake(0, i*blockHeight, blockWidth, blockHeight)];
        leftBlock.backgroundColor = [UIColor redColor];
        leftBlock.tag = HORIZ_BLOCK_COUNT * 2 + (VERT_BLOCK_COUNT - 2) + VERT_BLOCK_COUNT - i - 2;
        [self addSubview:leftBlock];
        
        UIView *rightBlock = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-blockWidth, i*blockHeight, blockWidth, blockHeight)];
        rightBlock.tag = i + HORIZ_BLOCK_COUNT - 1;
        rightBlock.backgroundColor = [UIColor redColor];
        [self addSubview:rightBlock];
    }
    
    // use the associated configuration
    for(UIView *v in self.subviews) {
        NSString *str = [[TVIcon configDict] objectForKey:[NSNumber numberWithInt:_configuration]];
        NSString *sstring = [str substringWithRange:NSMakeRange(v.tag, 1)];
        NSUInteger singleValue = sstring.integerValue;
        v.backgroundColor = [_colors objectAtIndex:singleValue];
    }

}

@end
