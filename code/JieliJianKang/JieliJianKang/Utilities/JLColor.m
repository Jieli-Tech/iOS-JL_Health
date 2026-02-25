//
//  JLColor.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/2.
//

#import "JLColor.h"

@implementation JLColor

+ (UIColor *)colorWithString:(NSString *)stringToConvert
{
    return [self colorWithString:stringToConvert alpha:1];
}

+ (UIColor *)colorWithString:(NSString *)stringToConvert alpha:(CGFloat)alpha
{
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    
    // Delete #.
    [scanner setScanLocation:1];
    
    unsigned int color = 0;
    
    [scanner scanHexInt:&color];
    
    NSUInteger r = color >> 16;
    NSUInteger g = (color >> 8) & 0x00FF;
    NSUInteger b = color & 0x0000FF;
    
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:alpha];
}

@end
