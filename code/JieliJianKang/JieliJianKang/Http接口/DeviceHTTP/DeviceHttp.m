//
//  DeviceHttp.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/16.
//

#import "DeviceHttp.h"
#import "User_Http.h"
#import "DeviceHttpModel.h"
#import "JL_RunSDK.h"
#import "BasicHttp.h"

@implementation DeviceHttp

+(void)bind:(nullable void (^)(JLHttpResponse * response))result{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *url = [NSString stringWithFormat:@"%@/health/v1/api/basic/device/save",BaseURL];
    DeviceHttpBody *bodyModel = [DeviceHttpBody new];
    
    
    JLModel_Device *deviceModel = [kJL_BLE_CmdManager outputDeviceModel];
    NSString *strPid = nil;
    NSString *strVid = nil;
    if (deviceModel.pidvid.length >0) {
        strPid = [deviceModel.pidvid substringWithRange:NSMakeRange(0, 4)];
        strVid = [deviceModel.pidvid substringWithRange:NSMakeRange(4, 4)];
    }

    bodyModel.pid = (int)[JL_Tools dataToInt:[DFTools HexToData:strPid?:kJL_BLE_EntityM.mPID]];
    bodyModel.vid = (int)[JL_Tools dataToInt:[DFTools HexToData:strVid?:kJL_BLE_EntityM.mVID]];
    bodyModel.mac = deviceModel.btAddr?:kJL_BLE_EntityM.mEdr;
    bodyModel.type = @"手表";
    NSString *advString = [JL_Tools dataChangeToString:kJL_BLE_EntityM.mAdvData];
    bodyModel.ios = [NSString stringWithFormat:@"{\"uuid\":\"%@\",\"advData\":\"%@\"}",kJL_BLE_EntityM.mPeripheral.identifier.UUIDString,advString];
    bodyModel.config = [NSString stringWithFormat:@"{\"name\":\"%@\"}",kJL_BLE_EntityM.mItem];
    bodyModel.explain = @" ";
    
    NSData *data = [bodyModel beData];
    NSMutableURLRequest *request = [BasicHttp Url:url Body:data];
    
    [[manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSDictionary *dict = responseObject;
        if (result) {
            if(dict){
                result([JLHttpResponse initWithDict:dict]);
            }
        }
    }] resume];

}


+(void)unBinding:(NSString *)device_id result:(void(^)(JLHttpResponse* response))result{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    
  
    NSDictionary *bodyDict = @{@"id":device_id};
    NSData *body = [NSJSONSerialization dataWithJSONObject:bodyDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *url = [NSString stringWithFormat:@"%@/health/v1/api/basic/device/remove",BaseURL];
    
    NSMutableURLRequest *request = [BasicHttp Url:url Body:body];
    [[manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (result) {
                result([JLHttpResponse initWithDict:responseObject]);
            }
    }] resume];
    
}

+(void)checkList:(void(^)(NSArray<DeviceHttpResp*>  * _Nullable array)) result{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *token = [JL_Tools getUserByKey:@"accessToken"];
    NSDictionary *headers = @{@"content-type": @"application/json",
                              @"jwt-token":token?:@"",
                              @"cache-control": @"no-cache"};
    NSString *url = [NSString stringWithFormat:@"%@/health/v1/api/basic/device/list",BaseURL];
    [manager POST:url parameters:nil headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = responseObject;
        //NSLog(@"%s: %@",__func__,dict);
        if ([dict[@"code"] intValue] == 0) {
            NSDictionary *array = dict[@"data"];
            NSMutableArray<DeviceHttpResp *> *targetArray = [NSMutableArray new];
            for (NSDictionary *item in array) {
                NSData * tmpData = [NSJSONSerialization dataWithJSONObject:item options:NSJSONWritingPrettyPrinted error:nil];
                [targetArray addObject:[DeviceHttpResp objectWithData:tmpData]];
            }
            if (result) {
                result(targetArray);
            }
        }else{
            NSLog(@"%s:请求错误 %@",__func__,dict);
            if (result) {
                result([NSArray new]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%s:网络错误了！！！%@",__func__,error);
        if (result) {
            result([NSArray new]);
        }
    }];
}

+(void)updateConfig:(DeviceHttpResp *)model Result:(void(^)(JLHttpResponse * response))result{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *url = [NSString stringWithFormat:@"%@/health/v1/api/basic/device/updateConfig",BaseURL];
    NSData *body = [model beData];
    
    NSMutableURLRequest *request = [BasicHttp Url:url Body:body];
    [[manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (result) {
            result([JLHttpResponse initWithDict:responseObject]);
        }
    }] resume];
}

+(void)updateTimeByDeviceID:(NSString *)device_id Result:(void(^)(JLHttpResponse* response))result{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
 
    NSString *url = [NSString stringWithFormat:@"%@/health/v1/api/basic/device/updateTime",BaseURL];
    NSDictionary *bodyDict = @{@"id":device_id};
    NSData *body = [NSJSONSerialization dataWithJSONObject:bodyDict options:NSJSONWritingPrettyPrinted error:nil];
    NSMutableURLRequest *request = [BasicHttp Url:url Body:body];
    [[manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (result) {
            result([JLHttpResponse initWithDict:responseObject]);
        }
    }] resume];
   
}


@end
