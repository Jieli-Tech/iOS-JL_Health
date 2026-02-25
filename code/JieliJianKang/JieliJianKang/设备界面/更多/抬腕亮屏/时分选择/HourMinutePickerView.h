//
//  XinLvView.h
//  JieliJianKang
//
//  Created by 李放 on 2021/7/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol HourMinutePickerDelegate <NSObject>

-(void)HourMinutePickerActionStartTime:(NSMutableArray *) selectArray;
-(void)HourMinutePickerActionEndTime:(NSMutableArray *) selectArray;

@end

@interface HourMinutePickerView : UIView
@property(nonatomic,weak)id<HourMinutePickerDelegate> delegate;
@property (nullable, nonatomic, copy) NSArray <NSNumber *> *startTimeselectIndexs;
@property (nullable, nonatomic, copy) NSArray <NSNumber *> *endTimeselectIndexs;
@property (nullable, nonatomic, copy) NSArray <NSNumber *> *selectIndexs;
@property(nonatomic, assign) int type;
@end

NS_ASSUME_NONNULL_END
