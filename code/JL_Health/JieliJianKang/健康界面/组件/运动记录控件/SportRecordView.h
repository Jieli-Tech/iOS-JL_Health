//
//  SportRecordView.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/15.
//

#import <UIKit/UIKit.h>
#import "TransJump.h"

NS_ASSUME_NONNULL_BEGIN

@interface SportRecordView : UIView

@property(nonatomic,weak)id<TransJumpDelegate> delegate;

/// 设置参数
/// @param unit 单位
/// @param record 记录数
/// @param type 运动类型
/// @param day 时间
-(void)setTheRecord:(NSString *)unit Record:(NSString *_Nullable)record type:(NSString *_Nullable)type withDay:(NSString *_Nullable)day;
@end

NS_ASSUME_NONNULL_END
