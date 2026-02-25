//
//  DeviceVC.h
//  JLWatchDemo
//
//  Created by 杰理科技 on 2022/3/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceVC : UIViewController
@property(nonatomic,assign)BOOL bt_status_phone;            //手机蓝牙是否开启
@property(nonatomic,assign)BOOL bt_status_connect;          //设备是否连接
@end

NS_ASSUME_NONNULL_END
