//
//  BushuPlate.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/4.
//

#import "BushuPlate.h"
#import "BushuPick.h"


@interface BushuPlate(){
    CALayer     *mLayer;
    CGFloat     view_W;
    CGFloat     view_H;
    NSInteger   mIndex;
    CGFloat     gap;
    CGFloat     gap_txt;
    
    UIImageView *mImageView;
}

@end

@implementation BushuPlate

- (instancetype)initWithIndex:(NSInteger)index WithHeight:(float)height
{
    self = [super init];
    if (self) {

        self.frame = CGRectMake(0, 0, index*kBushu_SCALE*kBushu_GAP+kBushuPickGAP, height);
        view_W = index*kBushu_SCALE*kBushu_GAP+kBushuPickGAP;
        view_H = height;
        
        mIndex = index;
        gap = 18.0;
        gap_txt = 30.0;
        
        [DFAction delay:0.05 Task:^{
            [self setupUI];
            UIImage *image = [self snapshotImage];
            [self->mLayer removeFromSuperlayer];
            self->mLayer = nil;
            
            CGRect rect = CGRectMake(0, 0, self->view_W, self->view_H);
            self->mImageView = [[UIImageView alloc] initWithFrame:rect];
            self->mImageView.contentMode = UIViewContentModeScaleToFill;
            self->mImageView.image = image;

            [self addSubview:self->mImageView];
        }];
    }
    return self;
}

-(void)setupUI{

    [mLayer removeFromSuperlayer];

    //创建自定义的layer
    mLayer =[CALayer layer];
    mLayer.backgroundColor= [UIColor clearColor].CGColor;
    mLayer.frame=CGRectMake(0, 0, view_W, view_H);
    mLayer.allowsEdgeAntialiasing = YES;
    mLayer.delegate = self;
    [self.layer addSublayer:mLayer];
    
    [mLayer setNeedsDisplay];//重载-drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx；
}


-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    /*--- 描绘刻度 ---*/
    for (NSInteger i = 0; i <= mIndex*kBushu_SCALE; i++)
    {
        /*--- 小刻度 ---*/
        if (i%2 != 0) {
            [self drawScale10:i*kBushu_GAP+kBushuPickGAP/2.0 Context:ctx];
        }
        
        /*--- 大刻度 ---*/
        if (i%2 == 0) {
            [self drawScale20:i*kBushu_GAP+kBushuPickGAP/2.0 Context:ctx];
            
            /*--- 刻度数字 ---*/
            long fp = (i+_startPiont)*1000;
            NSString *text = [NSString stringWithFormat:@"%ld",fp];
            [self drawLabel:i*kBushu_GAP+kBushuPickGAP/2.0 Text:text Layer:layer];
        }
    }
}

#pragma mark --> 画大刻度
-(void)drawScale20:(float)x Context:(CGContextRef)ctx{
    // 创建一个新的空图形路径。
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, x, 0.0);
    CGContextAddLineToPoint(ctx, x, view_H-gap_txt);
    
    CGContextMoveToPoint(ctx, x - kBushu_GAP/2.0, 1.0);
    CGContextAddLineToPoint(ctx, x + kBushu_GAP/2.0, 1.0);
    
    // 设置图形的线宽
    CGContextSetLineWidth(ctx, 1.5);
    CGContextSetShouldAntialias(ctx, NO);
    
    // 设置图形描边颜色
    CGContextSetStrokeColorWithColor(ctx, kDF_RGBA(229, 229, 229, 1.0).CGColor);
    // 根据当前路径，宽度及颜色绘制线
    CGContextStrokePath(ctx);
}

#pragma mark --> 画小刻度
-(void)drawScale10:(float)x Context:(CGContextRef)ctx{
    // 创建一个新的空图形路径。
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, x, 0);
    CGContextAddLineToPoint(ctx, x, view_H-gap_txt-gap);
    
    CGContextMoveToPoint(ctx, x - kBushu_GAP/2.0, 1.0);
    CGContextAddLineToPoint(ctx, x + kBushu_GAP/2.0, 1.0);
    
    // 设置图形的线宽
    CGContextSetLineWidth(ctx, 1.5);
    CGContextSetShouldAntialias(ctx, NO);
    
    // 设置图形描边颜色
    CGContextSetStrokeColorWithColor(ctx, kDF_RGBA(229, 229, 229, 1.0).CGColor);
    // 根据当前路径，宽度及颜色绘制线
    CGContextStrokePath(ctx);
}

#pragma mark --> 在刻度上标记文本
-(void)drawLabel:(float)x Text:(NSString*)text Layer:(CALayer*)layer{
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = text;
    
    UIFont *font = [UIFont fontWithName:@"Arial-BoldMT" size:15];
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    textLayer.font = fontRef;
    textLayer.fontSize = 15;
    CGFontRelease(fontRef);
        
    textLayer.contentsScale = 5.0;
    textLayer.alignmentMode = @"center";
    textLayer.frame = CGRectMake(x-25.0, view_H-25, 50.0f, 18.0f);
    textLayer.backgroundColor = [UIColor clearColor].CGColor;
    textLayer.foregroundColor = kDF_RGBA(215, 215, 215, 1.0).CGColor;
    [layer addSublayer:textLayer];
}

- (UIImage *)snapshotImage {
    UIGraphicsBeginImageContextWithOptions(mLayer.bounds.size, mLayer.opaque, 0);
    [mLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
