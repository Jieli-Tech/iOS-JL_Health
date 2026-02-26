//
//  ECBrokenLine.h
//  CoreDraw
//
//  Created by EzioChan on 2021/3/4.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreDraw/ECDrawTools.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BrokenLineType) {
    BrokenLineType_Normal,
    BrokenLineType_Histogram,
    BrokenLineType_CapNormal
};

@class ECBrokenLine;

@interface ECPoint:NSObject
@property(nonatomic,assign)CGFloat index;
@property(nonatomic,assign)CGFloat maxY;
@property(nonatomic,assign)CGFloat minY;
@property(nonatomic,assign)NSInteger resValue;
@property(nonatomic,strong)NSDate *date;
@property(nonatomic,readonly,assign)CGFloat h;
+(ECPoint *_Nonnull)make:(CGFloat)i max:(CGFloat)mx min:(CGFloat)mn;
@end


@protocol ECBrokenLineDelegate <NSObject>

-(void)ecBrokenLine:(ECBrokenLine *)line dataValue:(NSInteger)value Index:(NSInteger) index;
-(void)ecHistogramPlus:(ECBrokenLine *)echp selectPoint:(ECPoint *)point;

@optional
-(void)ecCapBrokenLine:(ECBrokenLine *)line dataValue:(ECPoint *)value Index:(NSInteger) index;

@end

@interface EcCap:NSObject
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)CGFloat radius;
@property(nonatomic,strong)UIColor *fillColor;
@property(nonatomic,strong)UIColor *borderColor;
@end

@interface ECBrokenLine : UIView

@property(nonatomic,weak)id<ECBrokenLineDelegate> delegate;

@property(nonatomic,strong)EcCap *capType;

@property(nonatomic,strong)UIColor *textColor;

/// 侧面text显示位置
@property(nonatomic,assign)Boolean isLineTextShowLeft;

/// 开始背景色
@property(nonatomic,strong, nullable)UIColor *startBgColor;
/// 结束背景色
@property(nonatomic,strong, nullable)UIColor *endBgColor;

/// 背景色渐变方向
@property(nonatomic,assign)ECDrawBgcType drawType;

/// 上边距
@property(nonatomic,assign)CGFloat ecTop;

/// 左边距
@property(nonatomic,assign)CGFloat ecLeft;

/// 边距
@property(nonatomic,assign)CGFloat ecRight;

/// 下边距
@property(nonatomic,assign)CGFloat ecBottom;

/// 时间栏文字内容
@property(nonatomic,strong)NSArray *timeLabArray;

/// 数据内容
@property(nonatomic,strong)NSArray *dataArray;

/// 带线帽的数组
@property(nonatomic,strong)NSArray <ECPoint *>*dataCapArray;

/// 数据采样间隔，如24*60，代表一天时间内的每分钟就一条数据采样
@property(nonatomic,assign)NSInteger dtNumber;

/// 最大显示值
@property(nonatomic,assign)NSInteger maxValue;

/// 最小显示值
@property(nonatomic,assign)NSInteger minValue;

/// 虚线栏的显示间隔
@property(nonatomic,assign)NSInteger clearance;

/// 线的颜色
@property(nonatomic,strong)UIColor  *lineColor;

/// 底部字体
@property(nonatomic,strong)UIFont *bottomTextFont;

/// 线的阴影颜色
@property(nonatomic,strong)UIColor  *lineShadowStartColor;
@property(nonatomic,strong)UIColor  *lineShadowEndColor;

/// 线的宽度
@property(nonatomic,assign)CGFloat  lineWidth;

///线上的点颜色
@property(nonatomic,strong)UIColor *pointColor;

//MARK:使用柱状图
@property(nonatomic,assign)BrokenLineType    lineType;

/// 指示标虚线的间隙
@property(nonatomic,assign)NSInteger lineClearance;

/// 背景虚线的颜色
@property(nonatomic,strong)UIColor   *dashlineColor;

/// 📊柱状图的宽
@property(nonatomic,assign)CGFloat cellsWidth;

/// 📊柱状图的圆角
@property(nonatomic,assign)CGFloat cellRadius;
/// 柱状图的颜色📊
@property(nonatomic,strong)UIColor *cellColor;

- (void)setDataArray:(NSArray * _Nonnull)dataArray withIsLineTextShowLeft:(Boolean)isLineTextShowLeft;

-(void)addLineByColor:(UIColor *)color Num:(NSInteger)num;

-(void)removeLine;

-(void)showLineAtLastPoint;

-(void)showLineAtFirstPoint;

-(void)setCapTarget:(NSInteger)tag;

-(void)setPointTarget:(NSInteger)tag;

-(void)setTextDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
