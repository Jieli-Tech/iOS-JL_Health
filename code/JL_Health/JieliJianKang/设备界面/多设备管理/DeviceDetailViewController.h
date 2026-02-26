//
//  DeviceDetailViewController.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/26.
//

#import <UIKit/UIKit.h>

@class UserDeviceModel;
NS_ASSUME_NONNULL_BEGIN

@interface DeviceDetailViewController : UIViewController
@property(nonatomic,strong)UserDeviceModel *mainModel;
@end

NS_ASSUME_NONNULL_END
