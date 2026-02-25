//
//  HeartBitPartView.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/16.
//

#import <UIKit/UIKit.h>
#import "TransJump.h"

NS_ASSUME_NONNULL_BEGIN

@interface HeartBitPartView : UIView
@property(nonatomic,weak)id<TransJumpDelegate> delegate;

@property(nonatomic,strong)NSArray *dataArray;
/// 数据采样间隔，如24*60，代表一天时间内的每分钟就一条数据采样
@property(nonatomic,assign)NSInteger dtNumber;

/// 心跳的最大值
@property(nonatomic,assign)NSInteger maxValue;
@property(nonatomic,assign)NSInteger minValue;

-(void)setHeartBeat:(NSInteger )beat forDay:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
