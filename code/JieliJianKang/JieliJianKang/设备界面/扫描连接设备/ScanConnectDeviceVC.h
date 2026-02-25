//
//  ScanConnectDeviceVC.h
//  JieliJianKang
//
//  Created by 李放 on 2021/4/1.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScanConnectDeviceVC : UIViewController
@property(nonatomic,strong)NSDictionary *mScanDict;
-(void)setScanDict:(NSDictionary*)dict;
-(void)setConnectDevice:(JL_EntityM*)entity;
@end

NS_ASSUME_NONNULL_END
