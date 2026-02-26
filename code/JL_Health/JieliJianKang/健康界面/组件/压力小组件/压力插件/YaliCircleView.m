//
//  YaliCircleView.m
//  QCY_Demo
//
//  Created by 杰理科技 on 2021/3/29.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import "YaliCircleView.h"

#define kCOLOR_0    kDF_RGBA(215, 119, 119, 1)
#define kCOLOR_1    kDF_RGBA(255, 212, 121, 1)
#define kCOLOR_2    kDF_RGBA(123, 208, 131, 1)
#define kCOLOR_3    kDF_RGBA(150, 197, 218, 1)
#define kCOLOR_C    kDF_RGBA(236, 236, 236, 1)

@interface YaliCircleView(){
    CALayer *layer_0;
    CALayer *layer_1;
    CALayer *layer_2;
    CALayer *layer_3;
    float sW;
    float sH;
}

@end


@implementation YaliCircleView

- (instancetype)initByFrame:(CGRect)frame
{
    self = [DFUITools loadNib:@"YaliCircleView"];
    if (self) {
        self.frame = frame;
        sW = frame.size.width;
        sH = frame.size.height;
        
        [self drawArc_C];
    }
    return self;
}

-(void)updateUI{
    [layer_0 removeFromSuperlayer];
    [layer_1 removeFromSuperlayer];
    [layer_2 removeFromSuperlayer];
    [layer_3 removeFromSuperlayer];

    [self drawArc_0];
    [self drawArc_1];
    [self drawArc_2];
    [self drawArc_3];
}

-(void)drawArc_C{
    [self drawArcAngle_0:0 Angle_1:2*M_PI Color:kCOLOR_C];
}

-(void)drawArc_0{
//    CAShapeLayer *layer = [CAShapeLayer new];
//    layer.frame = CGRectMake(0, 0, sW, sH);
//    layer.lineWidth = 20.0;
//    layer.strokeColor = kCOLOR_0.CGColor;//圆环的颜色
//    layer.fillColor = [UIColor clearColor].CGColor;//背景填充色
//    CGFloat radius = sW/2.0f-10.0;//设置半径为6
//    BOOL clockWise = YES;//按照顺时针方向
//
//    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(sW/2.0, sH/2.0)
//                                                        radius:radius
//                                                    startAngle:0-M_PI_2
//                                                      endAngle:2*M_PI*_value_0-M_PI_2
//                                                     clockwise:clockWise];
//    layer.path = [path CGPath];
//    [self.layer addSublayer:layer];
    CALayer *layer = [self drawArcAngle_0:0-M_PI_2
                                  Angle_1:2*M_PI*_value_0-M_PI_2
                                    Color:kCOLOR_0];
    layer_0 = layer;
}

-(void)drawArc_1{
//    CAShapeLayer *layer = [CAShapeLayer new];
//    layer.frame = CGRectMake(0, 0, sW, sH);
//    layer.lineWidth = 20.0;
//    layer.strokeColor = kCOLOR_1.CGColor;//圆环的颜色
//    layer.fillColor = [UIColor clearColor].CGColor;//背景填充色
//    CGFloat radius = sW/2.0f-10.0;//设置半径为6
//    BOOL clockWise = YES;//按照顺时针方向
//
//    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(sW/2.0, sH/2.0)
//                                                        radius:radius
//                                                    startAngle:2*M_PI*_value_0-M_PI_2
//                                                      endAngle:2*M_PI*(_value_0+_value_1)-M_PI_2
//                                                     clockwise:clockWise];
//    layer.path = [path CGPath];
//    [self.layer addSublayer:layer];
    CALayer *layer = [self drawArcAngle_0:2*M_PI*_value_0-M_PI_2
                                  Angle_1:2*M_PI*(_value_0+_value_1)-M_PI_2
                                    Color:kCOLOR_1];
    layer_1 = layer;
}

-(void)drawArc_2{
//    CAShapeLayer *layer = [CAShapeLayer new];
//    layer.frame = CGRectMake(0, 0, sW, sH);
//    layer.lineWidth = 20.0;
//    layer.strokeColor = kCOLOR_2.CGColor;//圆环的颜色
//    layer.fillColor = [UIColor clearColor].CGColor;//背景填充色
//    CGFloat radius = sW/2.0f-10.0;//设置半径为6
//    BOOL clockWise = YES;//按照顺时针方向
//
//    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(sW/2.0, sH/2.0)
//                                                        radius:radius
//                                                    startAngle:2*M_PI*(_value_0+_value_1)-M_PI_2
//                                                      endAngle:2*M_PI*(_value_0+_value_1+_value_2)-M_PI_2
//                                                     clockwise:clockWise];
//    layer.path = [path CGPath];
//    [self.layer addSublayer:layer];
    CALayer *layer = [self drawArcAngle_0:2*M_PI*(_value_0+_value_1)-M_PI_2
                                  Angle_1:2*M_PI*(_value_0+_value_1+_value_2)-M_PI_2
                                    Color:kCOLOR_2];
    layer_2 = layer;
}

-(void)drawArc_3{
//    CAShapeLayer *layer = [CAShapeLayer new];
//    layer.frame = CGRectMake(0, 0, sW, sH);
//    layer.lineWidth = 20.0;
//    layer.strokeColor = kCOLOR_3.CGColor;//圆环的颜色
//    layer.fillColor = [UIColor clearColor].CGColor;//背景填充色
//    CGFloat radius = sW/2.0f-10.0;//设置半径为6
//    BOOL clockWise = YES;//按照顺时针方向
//
//    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(sW/2.0, sH/2.0)
//                                                        radius:radius
//                                                    startAngle:2*M_PI*(_value_0+_value_1+_value_2)-M_PI_2
//                                                      endAngle:2*M_PI*(_value_0+_value_1+_value_2+_value_3)-M_PI_2
//                                                     clockwise:clockWise];
//    layer.path = [path CGPath];
//    [self.layer addSublayer:layer];
    CALayer *layer = [self drawArcAngle_0:2*M_PI*(_value_0+_value_1+_value_2)-M_PI_2
                                  Angle_1:2*M_PI*(_value_0+_value_1+_value_2+_value_3)-M_PI_2
                                    Color:kCOLOR_3];
    layer_3 = layer;
}


-(CALayer*)drawArcAngle_0:(float)ag_0 Angle_1:(CGFloat)ag_1 Color:(UIColor*)color{
    CAShapeLayer *layer = [CAShapeLayer new];
    layer.frame = CGRectMake(0, 0, sW, sH);
    layer.lineWidth = 20.0;
    layer.strokeColor = color.CGColor;//圆环的颜色
    layer.fillColor = [UIColor clearColor].CGColor;//背景填充色
    CGFloat radius = sW/2.0f-10.0;//设置半径为6
    BOOL clockWise = YES;//按照顺时针方向
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(sW/2.0, sH/2.0)
                                                        radius:radius
                                                    startAngle:ag_0
                                                      endAngle:ag_1
                                                     clockwise:clockWise];
    layer.path = [path CGPath];
    [self.layer addSublayer:layer];
    
    return layer;
}

@end
