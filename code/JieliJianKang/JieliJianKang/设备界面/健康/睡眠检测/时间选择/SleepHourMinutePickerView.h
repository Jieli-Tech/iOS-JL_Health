//
//  SleepHourMinutePickerView.h
//  JieliJianKang
//
//  Created by 李放 on 2021/10/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SleepHourMinutePickerDelegate <NSObject>

-(void)SleepHourMinutePickerStartTime:(NSMutableArray *) selectArray;
-(void)SleepHourMinutePickerEndTime:(NSMutableArray *) selectArray;
@end

@interface SleepHourMinutePickerView : UIView
@property(nonatomic,weak)id<SleepHourMinutePickerDelegate> delegate;
@property (nullable, nonatomic, copy) NSArray <NSNumber *> *startTimeselectIndexs;
@property (nullable, nonatomic, copy) NSArray <NSNumber *> *endTimeselectIndexs;
@property(nonatomic, assign) int type;
@end

NS_ASSUME_NONNULL_END
