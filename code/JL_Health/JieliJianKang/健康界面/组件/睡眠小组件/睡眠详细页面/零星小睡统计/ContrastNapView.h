//
//  ContrastNapView.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NapTimeType) {
    NapTimeType_Nap,
    NapTimeType_All,
    NapTimeType_Ave
};
@interface SleepNapModel : NSObject

@property(nonatomic,assign)NapTimeType type;
@property(nonatomic,strong)NSDate *startDate;
@property(nonatomic,strong)JLWearSleepModel *sleepModel;
@property(nonatomic,assign)NSTimeInterval length;

+(SleepNapModel *)makeNap:(NSDate *)start with:(JLWearSleepModel *)sleepModel;
+(SleepNapModel *)makeAll:(NSTimeInterval)timer;
+(SleepNapModel *)makeAve:(NSTimeInterval)timer;
@end


@interface ContrastNapView : UIView

-(void)setArray:(NSArray<SleepNapModel *>*)model;

@end

NS_ASSUME_NONNULL_END
