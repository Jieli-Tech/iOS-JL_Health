//
//  ECBlockDiagram.h
//  CoreDraw
//
//  Created by EzioChan on 2021/3/9.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreDraw/ECDrawTools.h>


typedef enum : NSUInteger {
    SleepType_Deep,
    SleepType_Shallow,
    SleepType_Awake,
    SleepType_Rem,
    SleepType_SporadicNap
} SleepType;

@interface ECDiagramPoint:NSObject
@property(nonatomic,strong)NSDate  * _Nonnull start;
@property(nonatomic,assign)NSInteger length;
@property(nonatomic,assign)SleepType type;
+(ECDiagramPoint*_Nonnull)make:(NSDate *_Nonnull)s len:(NSInteger)end type:(SleepType)type;
-(NSString *_Nonnull)dateToString;
-(NSString *_Nonnull)dateToStringEnd;
@end

@interface ECSleepDuration:NSObject
@property(nonatomic,assign)NSInteger duration;
@property(nonatomic,strong)NSDate * _Nullable date;
@property(nonatomic,strong)NSArray * _Nonnull presents;
+(ECSleepDuration *_Nonnull)make:(float)d shallow:(float)s awake:(float)a rem:(float)r Duration:(NSInteger)duration Date:(NSDate *_Nullable)date;
@end

@protocol ECDiagramDeleagte <NSObject>

-(void)ecDiagramdidSelect:(ECSleepDuration *_Nonnull)duration number:(NSInteger)num;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ECBlockDiagram : UIView
/// 上边距
@property(nonatomic,assign)CGFloat ecTop;

/// 左边距
@property(nonatomic,assign)CGFloat ecLeft;

/// 边距
@property(nonatomic,assign)CGFloat ecRight;

/// 下边距
@property(nonatomic,assign)CGFloat ecBottom;

/// 起始图标
@property(nonatomic,strong)UIImage *beginImage;
/// 结束图标
@property(nonatomic,strong)UIImage *endImage;

/// 睡眠数据(天)
@property(nonatomic,strong)NSArray<ECDiagramPoint *> *dataArray;

/// 指示标的种类名称
@property(nonatomic,strong)NSArray *textArray;

/// 数据组，用来写周/月/年的数据名称
@property(nonatomic,strong)NSArray *groupArray;

///分组的颜色
@property(nonatomic,strong)NSArray<UIColor *> *colorArray;
/// 开始颜色（背景）
@property(strong,nonatomic)UIColor *sColor;
/// 结束颜色（背景）
@property(strong,nonatomic)UIColor *eColor;
/// 背景色渐变方向
@property(nonatomic,assign)ECDrawBgcType drawType;

@property(nonatomic,strong)NSArray<ECSleepDuration *> *dataArray2;

/// 最大值，不设的话默认为数组里的最大数值
@property(nonatomic,assign)CGFloat maxValue;

/// 宽度，默认为12dp
@property(nonatomic,assign)CGFloat cellWidth;

/// 是否为柱状图，默认不是
@property(nonatomic,assign)BOOL    isHistogram;

/// 底部字体
@property(nonatomic,strong)UIFont *bottomTextFont;

/// 柱状图数据回调代理
@property(nonatomic,weak)id<ECDiagramDeleagte> delegate;

@end

NS_ASSUME_NONNULL_END
