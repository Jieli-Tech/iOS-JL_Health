//
//  UserDeviceModel.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/22.
//

#import <Foundation/Foundation.h>

@class DeviceHttpResp;

NS_ASSUME_NONNULL_BEGIN

@interface UserDeviceModel : NSObject<NSCopying>

@property(nonatomic,assign)NSInteger identifier;
@property(nonatomic,strong)NSString *devName;
@property(nonatomic,strong)NSString *pid;
@property(nonatomic,strong)NSString *vid;
@property(nonatomic,strong)NSString *type;
@property(nonatomic,strong)NSString *mac;
@property(nonatomic,strong)NSString *uuidStr;
@property(nonatomic,strong)NSString *userID;
@property(nonatomic,strong)NSString *deviceID;
@property(nonatomic,strong)NSString *androidConfig;
@property(nonatomic,strong)NSString *explain;
@property(nonatomic,assign)double timestamp;
@property(nonatomic,strong)NSData   *advData;
@property(nonatomic,strong)NSString *bleAddr;
@property(nonatomic,assign)BOOL     isTemporary; //临时变地址OTA设备 

-(DeviceHttpResp *)beDeviceHttpBody;

@end

NS_ASSUME_NONNULL_END
