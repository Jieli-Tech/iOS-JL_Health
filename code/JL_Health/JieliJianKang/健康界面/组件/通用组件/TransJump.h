//
//  TransJump.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    HeartBeat,
    StepCount,
    SportRecord,
    SleepTime,
    WeightRecord,
    presssureRecord,
    OxygenRecord
} JumpType;

@protocol TransJumpDelegate <NSObject>

-(void)jumpByObject:(JumpType)type;

@end

@interface TransJump : NSObject

@end

NS_ASSUME_NONNULL_END
