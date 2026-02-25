//
//  SporadicNapView.h
//  JieliJianKang
//
//  Created by 李放 on 2021/11/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SporadicNapView : UIView


-(void)setCurrentTime:(int) type WithStartTime:(NSString *) startTime WithEndTime:(NSString *) endTime WithHour:(int) hour WithMinute:(int) minute;
@end

NS_ASSUME_NONNULL_END
