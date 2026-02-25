//
//  StepPartsView.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/12.
//

#import <UIKit/UIKit.h>
#import "TransJump.h"

NS_ASSUME_NONNULL_BEGIN

@interface StepPartsView : UIView

@property(nonatomic,assign)float todayStep;
@property(nonatomic,assign)float targetStep;
@property(nonatomic,weak)id<TransJumpDelegate> delegate;

/// 今天走的步数
/// @param todayStep 步数
- (void)setWalkStep:(float)todayStep;

/// 目标步数
/// @param target 目标步数
-(void)setTargetStepAction:(float)target;

/// 达标指数
/// @param km 公里数
/// @param kcl 卡路里
/// @param m 爬楼高度
-(void)setK:(float)km Kcl:(float)kcl m:(float)m;

@end

NS_ASSUME_NONNULL_END
