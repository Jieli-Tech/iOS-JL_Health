//
//  JLTabBarController.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2022/1/6.
//

#import <UIKit/UIKit.h>
#import <JL_BLEKit/JL_BLEKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLTabBarController : UITabBarController <JLWearSyncProtocol,UITabBarDelegate>

@end

NS_ASSUME_NONNULL_END
