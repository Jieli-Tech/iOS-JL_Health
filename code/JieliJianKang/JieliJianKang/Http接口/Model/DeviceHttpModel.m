//
//  DeviceHttpModel.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/16.
//

#import "DeviceHttpModel.h"
#import "UserDeviceModel.h"

@implementation DeviceHttpModel

@end

@implementation DeviceHttpBody

-(NSData *)beData{
    NSDictionary *dict = @{@"pid":@(self.pid),
                           @"vid":@(self.vid),
                           @"mac":self.mac.formatBleEdr,
                           @"type":self.type,
                           @"androidConfigData":self.android?self.android:@"{}",
                           @"iosConfigData":self.ios?self.ios:@"{}",
                           @"configData":self.config,
                           @"explain":self.explain
    };
    //NSLog(@"bindData:%@",dict);
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    return data;
}




@end


@implementation DeviceHttpResp

+(DeviceHttpResp *)objectWithBaseResp:(JLHttpResponse *)response{
    return [self objectWithData:response.data];
}

+(DeviceHttpResp *)objectWithData:(NSData *)data{
    NSError *error;
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    NSDateFormatter *fmt = [EcTools cachedFm];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    DeviceHttpResp *model = [DeviceHttpResp new];
    model.idStr = dataDict[@"id"];
    model.uuid = dataDict[@"uuid"];
    model.userId = dataDict[@"userid"];
    model.pid = [dataDict[@"pid"] intValue];
    model.vid = [dataDict[@"vid"] intValue];
    model.mac = dataDict[@"mac"];
    model.type = dataDict[@"type"];
    model.android = dataDict[@"androidConfigData"];
    model.ios = dataDict[@"iosConfigData"];
    model.config = dataDict[@"configData"];
    model.createTime = [fmt dateFromString:dataDict[@"createTime"]];
    model.updateTime = [fmt dateFromString:dataDict[@"updateTime"]];
    model.explain = dataDict[@"explain"];
    return model;
}

-(UserDeviceModel *)beUdm{
    UserDeviceModel *model = [[UserDeviceModel alloc] init];
    NSData *data = [self.config dataUsingEncoding:kCFStringEncodingUTF8];
    if(data.length ==0){
        return model;
    }
    NSDictionary *nameDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    model.devName = nameDict[@"name"] ? nameDict[@"name"]:@"unknow";
    model.mac = self.mac.formatBleEdrBeDataStr;
    model.pid = [DFTools dataToHex:[DFTools uInt16_data:self.pid Endian:YES]];
    model.vid = [DFTools dataToHex:[DFTools uInt16_data:self.vid Endian:YES]];
    model.userID = self.userId;
    if (![self.ios isEqual:[NSNull null]]) {
        NSData *data2 = [self.ios dataUsingEncoding:kCFStringEncodingUTF8];
        NSDictionary *uuidstrDict = [NSJSONSerialization JSONObjectWithData:data2 options:NSJSONReadingMutableLeaves error:nil];
        model.uuidStr = uuidstrDict[@"uuid"]?uuidstrDict[@"uuid"]:@"";
        model.advData = [JL_Tools HexToData:uuidstrDict[@"advData"]?uuidstrDict[@"advData"]:@""];
    }else{
        model.uuidStr = @"";
    }
    model.type = self.type;
    model.deviceID = self.idStr;
    model.androidConfig = self.android;
    model.explain = self.explain;
    return model;
}

- (NSData *)beData{
    NSDictionary *dict = @{@"pid":@(self.pid),
                           @"vid":@(self.vid),
                           @"mac":self.mac,
                           @"type":self.type,
                           @"androidConfigData":self.android?self.android:@"{}",
                           @"iosConfigData":self.ios?self.ios:@"{}",
                           @"configData":self.config,
                           @"explain":self.explain?self.explain:@"<null>",
                           @"id":self.idStr
    };
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    return data;
}


@end


@implementation JLHttpResponse

+(JLHttpResponse *)initWithDict:(NSDictionary *)dict{
    JLHttpResponse *response = [JLHttpResponse new];
    response.code = [dict[@"code"] intValue];
    NSDictionary *dictData = dict[@"data"];
    if (dictData && response.code == 0) {
        if (![dictData isEqual:[NSNull null]]) {
            response.data = [NSJSONSerialization dataWithJSONObject:dictData options:NSJSONWritingPrettyPrinted error:nil];
        }
    }
    response.msg = dict[@"msg"];
    return response;
}


@end


