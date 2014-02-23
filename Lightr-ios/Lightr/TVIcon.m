//
//  TVIcon.m
//  Lightr
//
//  Created by Chris on 2/13/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import "TVIcon.h"

#import "Configuration.h"

#define ASPECT_RATIO        3/4
#define HORIZ_BLOCK_COUNT   32.f
#define VERT_BLOCK_COUNT    19.f

@interface TVIcon()

- (void) reconfigure;

@end

@implementation TVIcon

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
    
    NSLog(@"Clicked v=> %@", v);
    
    if(![v isKindOfClass:[TVIcon class]]) {
        
        NSInteger tag = v.tag;
        NSString *item = [_configuration.configurationString substringWithRange:NSMakeRange(tag, 1)];
        
        ndx = item.integerValue;
    }
    
    return ndx;
}

- (void) replaceColorAtIndex:(NSUInteger)ndx withColor:(UIColor*)color
{
    NSMutableArray *colors = [(NSArray*)_configuration.colors mutableCopy];

    // iterate thru our string to get everything with the same config
    NSString *ch = [_configuration.configurationString substringWithRange:NSMakeRange(ndx, 1)];
    
    for(int i=0; i<_configuration.configurationString.length; i++) {
        NSString *testCh = [_configuration.configurationString substringWithRange:NSMakeRange(i, 1)];
                
        if([testCh isEqualToString:ch]) {
            [colors replaceObjectAtIndex:i withObject:color];
        }
    }
    
    _currentColors = [NSArray arrayWithArray:colors];
    
    [self reconfigure];
}

- (void) setupWithConfiguration:(Configuration*)configuration
{
    _configuration = configuration;
    _currentColors = [NSArray arrayWithArray:configuration.colors];
    
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
    
//    NSString *configString = [[TVIcon configDict] objectForKey:[NSNumber numberWithInt:_configuration]];
    
    for(int i=0; i<_currentColors.count; i++) {
        
        // start in the bottom-right
        CGFloat x = 0;
        if(i < HORIZ_BLOCK_COUNT) {
            x = self.frame.size.width - blockWidth * (i+1);
        } else if(i < HORIZ_BLOCK_COUNT+VERT_BLOCK_COUNT-1) {
            x = 0;
        } else if(i < HORIZ_BLOCK_COUNT*2 + VERT_BLOCK_COUNT-2) {
            x = (i - (HORIZ_BLOCK_COUNT + VERT_BLOCK_COUNT - 2)) * blockWidth;
        } else {
            x = self.frame.size.width - blockWidth;
        }
        
        CGFloat y = 0;
        if(i < HORIZ_BLOCK_COUNT) {
            y = self.frame.size.height - blockHeight;
        } else if(i < HORIZ_BLOCK_COUNT+VERT_BLOCK_COUNT-1) {
            y = self.frame.size.height - blockHeight * (i - HORIZ_BLOCK_COUNT + 2);
        } else if(i < HORIZ_BLOCK_COUNT*2 + VERT_BLOCK_COUNT-2) {
            y = 0;
        } else {
            y = blockHeight * (i - (VERT_BLOCK_COUNT - 3 + HORIZ_BLOCK_COUNT*2));
        }

        UILabel *block = [[UILabel alloc] initWithFrame:CGRectMake(x, y, blockWidth, blockHeight)];
        block.backgroundColor = [_currentColors objectAtIndex:i];
        block.tag = i;
        block.userInteractionEnabled = TRUE;
        block.font = [UIFont systemFontOfSize:8];
//        block.text = [NSString stringWithFormat:@"%d", i];
        [self addSubview:block];
    }

}

@end
