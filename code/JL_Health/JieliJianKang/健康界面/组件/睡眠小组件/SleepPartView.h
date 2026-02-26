//
//  SleepPartView.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/17.
//

#import <UIKit/UIKit.h>
#import <CoreDraw/CoreDraw.h>
#import "TransJump.h"

NS_ASSUME_NONNULL_BEGIN

@interface SleepPartView : UIView

@property(nonatomic,weak)id<TransJumpDelegate> delegate;
/// 睡眠数据
@property(nonatomic,strong)NSArray<ECDiagramPoint *> *dataArray;

@property (nonatomic, assign)NSInteger duration;

-(void)setDateLabel:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
