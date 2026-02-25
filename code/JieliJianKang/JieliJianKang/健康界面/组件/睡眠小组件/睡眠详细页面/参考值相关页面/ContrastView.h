//
//  ContrastView.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/29.
//

#import <UIKit/UIKit.h>
#import "SleepDataView.h"
#import "SelectTitleBar.h"


@interface ContrastData:NSObject
@property(nonatomic,strong)NSString * _Nonnull actural;
@property(nonatomic,strong)NSString * _Nonnull reference;
@property(nonatomic,assign)SleepData_Interval interval;
+(ContrastData *_Nonnull)make:(NSString *_Nonnull)act with:(NSString*_Nonnull)ref interval:(SleepData_Interval)interval;
+(NSArray *_Nonnull)makeDataByType:(DateType)type allTime:(int) sleepHour WithMin:(int ) sleepMin WithDeepPercentage:(NSString* _Nonnull)deep WithShallowPercentage:(NSString * _Nonnull)shallow WithRem:(NSString* _Nonnull)rem DeepSleepScre:(NSInteger)deepSleepScre WithWakeCount:(int)awakeCount;
@end

@protocol ContrastDelegate <NSObject>

-(void)contrastViewDidSelect:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ContrastView : UIView
@property(nonatomic,weak)id<ContrastDelegate> delegate;
-(void)setDataArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
