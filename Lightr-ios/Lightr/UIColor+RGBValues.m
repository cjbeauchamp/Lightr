//
//  UIColor+RGBValues.m
//  LDBarButtonItemExample
//
//  Created by Christian Di Lorenzo on 1/24/13.
//  Copyright (c) 2013 Light Design. All rights reserved.
//

#import "UIColor+RGBValues.h"

@implementation UIColor (RGBValues)

- (NSString*) prettyPrint
{
    return [NSString stringWithFormat:@"rgb(%d, %d, %d) /=> %@", self.red, self.green, self.blue, self.hexValue];
//    return [NSString stringWithFormat:@"rgb(%lf, %lf, %lf)", self.redFloat, self.greenFloat, self.blueFloat];
}

- (NSString*)hexValue
{
    NSString *redString = [NSString stringWithFormat:@"%X", self.red];
    NSString *greenString = [NSString stringWithFormat:@"%X", self.green];
    NSString *blueString = [NSString stringWithFormat:@"%X", self.blue];
    
    if(redString.length == 1) { redString = [NSString stringWithFormat:@"0%@", redString]; }
    if(greenString.length == 1) { greenString = [NSString stringWithFormat:@"0%@", greenString]; }
    if(blueString.length == 1) { blueString = [NSString stringWithFormat:@"0%@", blueString]; }
    
    return [NSString stringWithFormat:@"%@%@%@", redString, greenString, blueString];
}

- (int) colorSpaceComponentCount
{
    return (int)CGColorSpaceGetNumberOfComponents(CGColorGetColorSpace(self.CGColor));
}

- (CGFloat)redFloat {
    
    const CGFloat* components = CGColorGetComponents(self.CGColor);

    // it's whitescale
    if([self colorSpaceComponentCount] == 1) {
        return components[0];
    } else {
        return components[0];
    }

}

- (CGFloat)greenFloat {
    
    const CGFloat* components = CGColorGetComponents(self.CGColor);
    
    // it's whitescale
    if([self colorSpaceComponentCount] == 1) {
        return components[0];
    } else {
        return components[1];
    }
    
}

- (CGFloat)blueFloat {
    
    const CGFloat* components = CGColorGetComponents(self.CGColor);
    
    // it's whitescale
    if([self colorSpaceComponentCount] == 1) {
        return components[0];
    } else {
        return components[2];
    }
    
}

- (int)red {
    return round(self.redFloat * 255);
}

- (int)green {
    return round(self.greenFloat * 255);
}

- (int)blue {
    return round(self.blueFloat * 255);
}

- (CGFloat)alpha {
    return CGColorGetAlpha(self.CGColor);
}

- (BOOL)isClearColor {
    return [self isEqual:[UIColor clearColor]];
}

- (BOOL)isLighterColor {
    const CGFloat* components = CGColorGetComponents(self.CGColor);
    return (components[0]+components[1]+components[2])/3 >= 0.5;
}

- (UIColor *)lighterColor {
    if ([self isEqual:[UIColor whiteColor]]) return [UIColor colorWithWhite:0.99 alpha:1.0];
    if ([self isEqual:[UIColor blackColor]]) return [UIColor colorWithWhite:0.01 alpha:1.0];
    float hue, saturation, brightness, alpha, white;
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        return [UIColor colorWithHue:hue
                          saturation:saturation
                          brightness:MIN(brightness * 1.3, 1.0)
                               alpha:alpha];
    } else if ([self getWhite:&white alpha:&alpha]) {
        return [UIColor colorWithWhite:MIN(white * 1.3, 1.0) alpha:alpha];
    }
    return nil;
}

- (UIColor *)darkerColor {
    if ([self isEqual:[UIColor whiteColor]]) return [UIColor colorWithWhite:0.99 alpha:1.0];
    if ([self isEqual:[UIColor blackColor]]) return [UIColor colorWithWhite:0.01 alpha:1.0];
    float hue, saturation, brightness, alpha, white;
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        return [UIColor colorWithHue:hue
                          saturation:saturation
                          brightness:brightness * 0.75
                               alpha:alpha];
    } else if ([self getWhite:&white alpha:&alpha]) {
        return [UIColor colorWithWhite:MAX(white * 0.75, 0.0) alpha:alpha];
    }
    return nil;
}

@end
