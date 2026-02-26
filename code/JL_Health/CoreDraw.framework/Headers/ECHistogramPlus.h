//
//  ECHistogramPlus.h
//  CoreDraw
//
//  Created by EzioChan on 2021/3/8.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//


#import <CoreDraw/CoreDraw.h>

@class ECHistogramPlus;


NS_ASSUME_NONNULL_BEGIN

@protocol ECHPlusDelegate <NSObject>

-(void)ecHistogramPlus:(ECHistogramPlus *)echp selectPoint:(ECPoint *)point;

@end

@interface ECHistogramPlus : ECHistogram

@property(nonatomic,weak)id<ECHPlusDelegate> delegatePlus;

/// 底部字体大小
@property(nonatomic,strong)UIFont *bottomTextFont;

/// 显示的单位
@property(nonatomic,strong)NSString *units;

/// 指示标虚线的间隙
@property(nonatomic,assign)NSInteger lineClearance;

/// 对应每一条cell的颜色，默认为白色
@property(nonatomic,strong)NSArray *cellColors;

/// 📊柱状图的宽
@property(nonatomic,assign)CGFloat cellsWidth;

/// 📊柱状图的圆角
@property(nonatomic,assign)CGFloat cellRadius;

-(void)setPointTarget:(NSInteger)tag;

@end

NS_ASSUME_NONNULL_END
