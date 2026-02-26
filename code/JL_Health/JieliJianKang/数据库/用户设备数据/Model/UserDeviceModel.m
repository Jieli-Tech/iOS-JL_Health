//
//  UserDeviceModel.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/22.
//

#import "UserDeviceModel.h"
#import "DeviceHttpModel.h"

@implementation UserDeviceModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.advData = [NSData new];
    }
    return self;
}

-(DeviceHttpResp *)beDeviceHttpBody{
    DeviceHttpResp *body = [[DeviceHttpResp alloc] init];
    body.vid = (int)[DFTools dataToInt:[DFTools HexToData:self.vid]];
    body.pid = (int)[DFTools dataToInt:[DFTools HexToData:self.pid]];
    body.mac = self.mac;
    body.explain = self.explain;
    body.android = self.androidConfig;
    body.idStr = self.deviceID;
    body.config = [NSString stringWithFormat:@"{\"name\":\"%@\"}",self.devName];
    body.ios = [NSString stringWithFormat:@"{\"uuid\":\"%@\"}",self.uuidStr];
    body.type = self.type;
    return body;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone { 
    UserDeviceModel *selfCopy = [[UserDeviceModel allocWithZone:zone] init];
    selfCopy.identifier = self.identifier;
    selfCopy.devName = self.devName;
    selfCopy.pid = self.pid;
    selfCopy.vid = self.vid;
    selfCopy.type = self.type;
    selfCopy.mac = self.mac;
    selfCopy.uuidStr = self.uuidStr;
    selfCopy.userID = self.userID;
    selfCopy.deviceID = self.deviceID;
    selfCopy.androidConfig = self.androidConfig;
    selfCopy.explain = self.explain;
    selfCopy.timestamp = self.timestamp;
    selfCopy.advData = self.advData;
    selfCopy.bleAddr = self.bleAddr;
    selfCopy.isTemporary = self.isTemporary;
    return self;
}

@end
