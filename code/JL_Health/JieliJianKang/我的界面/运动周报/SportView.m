//
//  YaLiView.m
//  QCY_Demo
//
//  Created by 杰理科技 on 2021/3/22.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import "SportView.h"
#import "JL_RunSDK.h"

@interface SportView() {
    float   sW;
    float   sH;
    float   gap_T;
    float   gap_L;
    float   gap_R;
    float   gap_B;
    
    UIView     *lineView;
    CALayer         *blueLayer;
    NSMutableArray  *pArr;
    
    UIView *gradientBackgroundView;
    CAGradientLayer *gradientLayer;
    NSMutableArray *gradientLayerColors;
}

@end

@implementation SportView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        sW = frame.size.width;
        sH = frame.size.height;
        self.frame = frame;
        
        gap_T = 20.0;
        gap_L = 30.0;
        gap_B = 60.0;
        gap_R = 50.0;
        self.lineShadowStartColor = [UIColor whiteColor];
        self.lineShadowEndColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.01];
    }
    return self;
}

-(void)resetUI{
    [lineView removeFromSuperview];
    lineView = nil;
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    lineView = [[UIView alloc] init];
    lineView.frame = CGRectMake(gap_L, gap_T, sW-gap_L-gap_R*0.3, sH-gap_T-gap_B);
    [self addSubview:lineView];
}

-(void)loadUI{
    [self resetUI];

    NSInteger ct = self.textArray.count;
    float gap_label = (sW - gap_L - gap_R*0.3)/(ct-1);
    
    for (int i = 0; i < ct; i++) {
        UILabel *lb = [UILabel new];
        lb.textAlignment = NSTextAlignmentCenter;
        lb.textColor = kDF_RGBA(145, 145, 145, 1.0);
        lb.font = [UIFont systemFontOfSize:10.0];
        lb.text = self.textArray[i];
        lb.bounds = CGRectMake(0, 0, 100.0, 20.0);
        lb.center = CGPointMake(gap_L+i*gap_label, sH-gap_B/2.0+15);
        [self addSubview:lb];
    }
    
    pArr = [NSMutableArray new];
    NSInteger ct_2 = self.dataArray.count;
    float w = lineView.frame.size.width;
    float h = lineView.frame.size.height;
    float gap = w/(ct-1);
    
    for (int i = 0 ; i < ct_2; i++) {
        float num = [self.dataArray[i] floatValue];
        float x = i*gap;
        float y = h - h*(num/100.0f)+25;

        NSDictionary *pDict = @{@"x":@(x),
                                @"y":@(y)};
        [pArr addObject:pDict];
    }
    UIView *bottomLineView = [UIView new];
//    bottomLineView.frame = CGRectMake(16, sH-gap_B/2.0 - 5, self.width - 16, 0.8);
    bottomLineView.frame = CGRectMake(-20, h + gap_T + 5, w + 40, 0.8);
    bottomLineView.backgroundColor = [JLColor colorWithString:@"#E7E7E7"];
    [lineView addSubview:bottomLineView];
    
    [self drawLineView_0];
    [self drawLineView_1];
    [self drawRealData];
    
    NSDictionary *dict = pArr[0];
    float x = [dict[@"x"] floatValue];
    float y = [dict[@"y"] floatValue];
    [self drawBlueArcPoint:CGPointMake(x, y)];
    
}

-(void)drawLineView_0{
    // 画出折线图阴影
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0,0, lineView.width, lineView.height);
    gradientLayer.colors = @[(__bridge id)[JLColor colorWithString:@"#805BEB"].CGColor, (__bridge id)[UIColor whiteColor].CGColor];
    UIBezierPath *gradientPath = [UIBezierPath bezierPath];
    CGPoint firstPoint = CGPointMake(-20, lineView.height + gap_T + 5);
    [gradientPath moveToPoint:firstPoint];
    for (int i = 0; i < pArr.count; i++) {
        NSDictionary *dict = pArr[i];
        float x = [dict[@"x"] floatValue];
        float y = [dict[@"y"] floatValue];
        [gradientPath addLineToPoint:CGPointMake(x, y+1.5)];
    }
    CGPoint lastPoint = CGPointMake(lineView.width + 20, lineView.height + gap_T + 5);
    [gradientPath addLineToPoint:lastPoint];
    CAShapeLayer *gradientPathShapeLayer = [CAShapeLayer layer];
    gradientPathShapeLayer.path = gradientPath.CGPath;
    gradientLayer.mask = gradientPathShapeLayer;
    [lineView.layer addSublayer:gradientLayer];
    
    // 画出折线图
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < pArr.count; i++) {
        NSDictionary *dict = pArr[i];
        float x = [dict[@"x"] floatValue];
        float y = [dict[@"y"] floatValue];
        if (i == 0) {
            [path moveToPoint:CGPointMake(x, y)];
        } else {
            [path addLineToPoint:CGPointMake(x, y)];
        }
    }
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.lineWidth = 1.5;
    layer.strokeColor = [JLColor colorWithString:@"#805BEB"].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.path = [path CGPath];
    [lineView.layer addSublayer:layer];
}

-(void)drawLineView_1{
    for (int i = 0 ; i < pArr.count; i++) {
        NSDictionary *dict = pArr[i];
        float x = [dict[@"x"] floatValue];
        float y = [dict[@"y"] floatValue];
        [self drawArcPoint:CGPointMake(x, y)];
    }
}

-(void)drawRealData {
    for (int i = 0; i < pArr.count; i++) {
        NSDictionary *dict = pArr[i];
        int j = i;
        if (j > (self.realDataArray.count - 1)) {
            j = (int)self.realDataArray.count - 1;
        }
        NSNumber *num = self.realDataArray[j];
        float x = [dict[@"x"] floatValue] - 30;
        float y = [dict[@"y"] floatValue] - 23;
        [self drawIntegerPoint:CGPointMake(x, y) withInteger:[num integerValue]];
    }
}

/**
 *  添加坐标文本
 */
-(void)drawIntegerPoint:(CGPoint)point withInteger:(NSInteger)integer {
    UILabel *lb = [UILabel new];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.textColor = [JLColor colorWithString:@"#919191"];
    lb.font = [UIFont fontWithName:@"PingFang SC" size:12];
    lb.text = [NSString stringWithFormat:@"%ld%@", (long)integer,kJL_TXT("步")];
    lb.frame = CGRectMake(point.x, point.y, 60.0, 17.0);
    [lineView addSubview:lb];
}

-(void)drawArcPoint:(CGPoint)point{
    CAShapeLayer *layer = [CAShapeLayer new];
    layer.lineWidth = 1.5;
    layer.strokeColor = kDF_RGBA(128, 91, 235, 1.0).CGColor;//圆环的颜色
    
    layer.fillColor = [UIColor whiteColor].CGColor;
    
    CGFloat radius = 6;//设置半径为6
    BOOL clockWise = true;//按照顺时针方向
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:radius
                                                    startAngle:0 endAngle:2*M_PI
                                                     clockwise:clockWise];
    layer.path = [path CGPath];
    [lineView.layer addSublayer:layer];
}

-(void)drawBlueArcPoint:(CGPoint)point{
    CAShapeLayer *layer = [CAShapeLayer new];
    layer.lineWidth = 1.5;
    layer.strokeColor = kDF_RGBA(128, 91, 235, 1.0).CGColor;//圆环的颜色
    
    layer.fillColor = [UIColor whiteColor].CGColor;
    
    CGFloat radius = 6;//设置半径为6
    BOOL clockWise = true;//按照顺时针方向
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:radius
                                                    startAngle:0 endAngle:2*M_PI
                                                     clockwise:clockWise];
    layer.path = [path CGPath];
    [lineView.layer addSublayer:layer];
    
    blueLayer = layer;
}

- (void)drawGradientBackgroundView {
    // 渐变背景视图（不包含坐标轴）
    gradientBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(gap_T, 0, self.bounds.size.width - gap_T, self.bounds.size.height - gap_T)];
    [self addSubview:gradientBackgroundView];
    /** 创建并设置渐变背景图层 */
    //初始化CAGradientlayer对象，使它的大小为渐变背景视图的大小
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = gradientBackgroundView.bounds;
    //设置渐变区域的起始和终止位置（范围为0-1），即渐变路径
    gradientLayer.startPoint = CGPointMake(0, 0.0);
    gradientLayer.endPoint = CGPointMake(1.0, 0.0);
    //设置颜色的渐变过程
    gradientLayerColors = [NSMutableArray arrayWithArray:@[(__bridge id)kDF_RGBA(128, 91, 235, 1.0).CGColor, (__bridge id)kDF_RGBA(255, 255, 255, 1.0).CGColor]];
    gradientLayer.colors = gradientLayerColors;
    //将CAGradientlayer对象添加在我们要设置背景色的视图的layer层
    [gradientBackgroundView.layer addSublayer:gradientLayer];
}

-(void)drawGradienLine:(CGContextRef)ctx colors:(CFArrayRef)colors locations:(CGFloat [])locations rect:(CGRect)rect{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, locations);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint startPoint,endPoint;
    startPoint = CGPointMake(rect.size.width, 0);
    endPoint = CGPointMake(rect.size.width, rect.size.height);
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}

@end



