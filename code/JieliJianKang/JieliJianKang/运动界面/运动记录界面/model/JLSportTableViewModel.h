//
//  JLSportTableViewModel.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JLSportTableViewModelType)
{
    JLSportTableViewModelTypeSpeedPerKM = 0,         // 每公里配速
    JLSportTableViewModelTypeStepFrequency = 1,      // 步频
    JLSportTableViewModelTypeHeartRate = 2,          // 心率
};

@interface JLSportTableViewModel : NSObject

@property (assign, nonatomic) JLSportTableViewModelType type;
- (instancetype)initWithType:(JLSportTableViewModelType)type;

@end

NS_ASSUME_NONNULL_END
