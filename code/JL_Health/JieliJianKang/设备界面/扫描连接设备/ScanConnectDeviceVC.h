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
@property(nonatomic,strong)NSDictionary *_Nullable mScanDict;
@property(nonatomic,strong)JL_EntityM  *_Nullable connectEntity;
@end

NS_ASSUME_NONNULL_END
