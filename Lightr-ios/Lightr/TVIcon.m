//
//  TVIcon.m
//  Lightr
//
//  Created by Chris on 2/13/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import "TVIcon.h"

#define ASPECT_RATIO        3/4
#define HORIZ_BLOCK_COUNT   30.f
#define VERT_BLOCK_COUNT    19.f

@interface TVIcon()

- (void) reconfigure;
+ (NSDictionary*) configDict;

@end

@implementation TVIcon

+ (NSDictionary*) configDict
{    
    NSMutableDictionary *configDict = [NSMutableDictionary dictionary];

    int configIndex = TVConfigurationWhole;
    
    NSArray *configFiles = @[
                             @"whole.config",
                             @"split-horiz.config",
                             @"split-vert.config",
                             @"split-horiz-thirds.config",
                             @"split-vert-thirds.config",
                             @"quadrants.config"
                             ];
    for(NSString *file in configFiles) {
        
        NSString *fileString = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:file];

//        NSLog(@"File => %@", fileString);

        NSData *fileData = [NSData dataWithContentsOfFile:fileString];
        NSString *configString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        
//        NSLog(@"REading configString : %@", configString);
        
        // read the string from top left to right for now
        
        NSMutableString *finalString = [NSMutableString stringWithString:@""];

        NSArray *comp = [configString componentsSeparatedByString:@"\n"];

        // read the bottom line (backwards)
        NSMutableString *reversed = [NSMutableString stringWithString:@""];
        for(int i = ((NSString*)[comp lastObject]).length-1; i>=0; i--) {
            [reversed appendString:[[comp lastObject] substringWithRange:NSMakeRange(i, 1)]];
        }
        [finalString appendString:reversed];
        
        // read the left column (bottom to top)
        for(int i=comp.count-2; i>=0; i--) {
            NSString *line = [comp objectAtIndex:i];
            [finalString appendString:[line substringToIndex:1]];
        }

        // read the top line
        [finalString appendString:[[comp objectAtIndex:0] substringFromIndex:1]];
        
        // read the right column
        for(int i=1; i<comp.count-1; i++) {
            NSString *line = [comp objectAtIndex:i];
            [finalString appendString:[line substringFromIndex:line.length-1]];
        }

        [configDict setObject:finalString forKey:[NSNumber numberWithInt:configIndex]];
        
        ++configIndex;
    }

//    NSLog(@"Configdict => %@", configDict);

    
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
    
    NSLog(@"Clicked v=> %@", v);
    
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
    
    NSString *configString = [[TVIcon configDict] objectForKey:[NSNumber numberWithInt:_configuration]];
    
    for(int i=0; i<configString.length; i++) {
        
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
        block.backgroundColor = [UIColor blackColor];
        block.tag = i;
        block.userInteractionEnabled = TRUE;
        block.font = [UIFont systemFontOfSize:8];
//        block.text = [NSString stringWithFormat:@"%d", i];
        [self addSubview:block];
    }
    
    // use the associated configuration
    for(UIView *v in self.subviews) {
        NSString *str = [[TVIcon configDict] objectForKey:[NSNumber numberWithInt:_configuration]];
        NSString *sstring = [str substringWithRange:NSMakeRange(v.tag, 1)];
        NSUInteger singleValue = sstring.integerValue;
        NSLog(@"SingleValue: %d", singleValue);
        NSLog(@"Colors: %@", _colors);
        v.backgroundColor = [_colors objectAtIndex:singleValue];
    }

}

@end
