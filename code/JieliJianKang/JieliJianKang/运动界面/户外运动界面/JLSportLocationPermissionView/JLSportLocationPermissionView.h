//
//  JLSportLocationPermissionView.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JLSportLocationPermissionViewDelegate <NSObject>

@optional
- (void)cancelBtnFunction;
- (void)continueStartBtnFunction;
- (void)settingBtnFunction;

@end

@interface JLSportLocationPermissionView : UIView

@property(weak, nonatomic, nullable) id<JLSportLocationPermissionViewDelegate> delegate;
+ (instancetype)sportLocationPermissionView;

@end

NS_ASSUME_NONNULL_END
