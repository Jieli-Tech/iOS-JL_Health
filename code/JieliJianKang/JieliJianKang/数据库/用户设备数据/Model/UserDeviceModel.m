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

@end
