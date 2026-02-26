//
//  ECHistogram.h
//  CoreDraw
//
//  Created by EzioChan on 2021/3/2.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreDraw/ECDrawTools.h>

NS_ASSUME_NONNULL_BEGIN

@class ECHistogram;
@protocol ECHistogramDelegate <NSObject>

/// 滑动屏幕或选中屏幕时返回的步数
/// @param step 步数
-(void)ecHistogram:(ECHistogram *) echis StepData:(NSInteger)step Index:(NSInteger) index;

@end

@interface ECHistogram : UIView

@property(weak,nonatomic)id<ECHistogramDelegate> delegate;

/// 上边距
@property(nonatomic,assign)CGFloat ecTop;

/// 左边距
@property(nonatomic,assign)CGFloat ecLeft;

/// 边距
@property(nonatomic,assign)CGFloat ecRight;

/// 下边距
@property(nonatomic,assign)CGFloat ecBottom;

/// 顶栏最大值
@property(assign,nonatomic)NSInteger maxValue;

/// 底栏最小值
@property(assign,nonatomic)NSInteger minValue;

@property(assign,nonatomic)NSInteger timeInterval;

/// 数据组的预设个数
/// （如：24小时里面应该会对应产生24个步行数据，这里就可以设置为24）
@property(assign,nonatomic)NSInteger presetNum;
/// 数据数组
@property(strong,nonatomic)NSArray   *dataArray;

/// 背景色
@property(strong,nonatomic)UIColor   *bgColor;

/// 虚线的颜色
@property(strong,nonatomic)UIColor   *lineColor;

/// 柱状图的颜色📊
@property(strong,nonatomic)UIColor   *cellColor;

/// 📊选中时的颜色
@property(strong,nonatomic)UIColor   *cellSelectedColor;

///柱状图的宽度
@property(assign,nonatomic)CGFloat   cellWidth;

/// 底栏数据展示
@property(strong,nonatomic)NSArray   *timeLabArray;

/// 开始颜色
@property(strong,readonly,nonatomic)   UIColor *sColor;

/// 结束颜色
@property(strong,readonly,nonatomic)   UIColor *eColor;

/// 背景色渐变方向
@property(nonatomic,assign)ECDrawBgcType drawType;

/// 设置渐变背景色
/// @param startColor 开始颜色
/// @param endColor 结束颜色
-(void)setGradientLayer:(UIColor*)startColor endColor:(UIColor*)endColor;

/// 开始重新绘制
-(void)startToDraw;



@end

NS_ASSUME_NONNULL_END
