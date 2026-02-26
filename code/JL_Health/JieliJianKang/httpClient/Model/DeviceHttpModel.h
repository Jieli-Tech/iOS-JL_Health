//
//  DeviceHttpModel.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/16.
//

#import <Foundation/Foundation.h>
@class UserDeviceModel;
NS_ASSUME_NONNULL_BEGIN

@interface DeviceHttpModel : NSObject

@end

@interface JLHttpResponse : NSObject
@property(nonatomic,assign)NSInteger    code;
@property(nonatomic,strong)NSData       *data;
@property(nonatomic,strong)NSString     *msg;

+(JLHttpResponse *)initWithDict:(NSDictionary *)dict;
@end


@interface DeviceHttpBody : NSObject

@property(nonatomic,assign)int        pid;
@property(nonatomic,assign)int        vid;
@property(nonatomic,strong)NSString  *type;
@property(nonatomic,strong)NSString   *mac;
@property(nonatomic,strong)NSString  *android;
@property(nonatomic,strong)NSString  *ios;
@property(nonatomic,strong)NSString  *config;
@property(nonatomic,strong)NSString  *explain;

-(NSData *)beData;


@end

@interface DeviceHttpResp : DeviceHttpBody

@property(nonatomic,strong)NSString  *idStr;
@property(nonatomic,strong)NSString  *uuid;
@property(nonatomic,strong)NSString  *userId;
@property(nonatomic,strong)NSDate    *createTime;
@property(nonatomic,strong)NSDate  *updateTime;

+(DeviceHttpResp *)objectWithBaseResp:(JLHttpResponse *)response;

+(DeviceHttpResp *)objectWithData:(NSData *)data;

-(UserDeviceModel *)beUdm;
@end




NS_ASSUME_NONNULL_END
