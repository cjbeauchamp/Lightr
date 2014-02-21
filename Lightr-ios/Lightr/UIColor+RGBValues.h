//
//  UIColor+RGBValues.h
//  LDBarButtonItemExample
//
//  Created by Christian Di Lorenzo on 1/24/13.
//  Copyright (c) 2013 Light Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RGBValues)

- (int)red;
- (int)green;
- (int)blue;
- (CGFloat)alpha;

- (CGFloat)redFloat;
- (CGFloat)greenFloat;
- (CGFloat)blueFloat;

- (UIColor *)darkerColor;
- (UIColor *)lighterColor;
- (BOOL)isLighterColor;
- (BOOL)isClearColor;

- (NSString*)prettyPrint;

- (NSString*)hexValue;

@end
