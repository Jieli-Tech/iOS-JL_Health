//
//  SleepDataView.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/29.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SleepDataType_Day,
    SleepDataType_Other,
}SleepDataType;

typedef enum : NSUInteger {
    SleepData_Normal,
    SleepData_Hight,
    SleepData_Low,
} SleepData_Interval;

NS_ASSUME_NONNULL_BEGIN

@interface SleepDataView : UIView
@property(nonatomic,assign)SleepDataType type;

-(void)deepSleep:(NSString *)percent length:(NSInteger)length;
-(void)shallowSleep:(NSString *)percent length:(NSInteger)length;
-(void)remSleep:(NSString *)percent length:(NSInteger)length;
-(void)setGoal:(int)score;

-(void)setTitleHidden:(BOOL)hiden;

@end

NS_ASSUME_NONNULL_END
