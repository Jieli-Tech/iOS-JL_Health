//
//  JLGPSView.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLGPSView : UIView

+ (instancetype)gpsView;

/**
 * 当使用多个JLGPSView的时候，可以使用该方法重设代理内部manager代理
 */
- (void)resetIntensityManagerDelegate;

@end

NS_ASSUME_NONNULL_END
