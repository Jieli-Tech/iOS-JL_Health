//
//  TipView.h
//  JLWatchDemo
//
//  Created by 杰理科技 on 2022/3/7.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>

NS_ASSUME_NONNULL_BEGIN

@interface TipView : UIView

+(void)startLoadingView:(NSString*)text Delay:(NSTimeInterval)delay;
+(void)setLoadingText:(NSString*)text Delay:(NSTimeInterval)delay;
+(void)setLoadingText:(NSString *)text;
+(void)removeLoading;

@end

NS_ASSUME_NONNULL_END
