//
//  JLWatchHttp.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2022/6/10.
//

#import "JLWatchHttp.h"
#import "User_Http.h"

@implementation JLWatchHttp

/**
  根据pid、vid查询表盘产品信息
 */
+(void)requestWatchInfoPid:(int )pid Vid:(int )vid Result:(void(^)(NSDictionary *info))result{
    NSString *accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/watch/shop/onebypidvid?pid=%d&vid=%d",BaseURL,pid,vid];
    [self requestUrl:rqUrl Header:headers Body:nil Result:result];
}


/**
  根据手表ID获取表盘市场里【免费表盘】或【付费表盘】
 */
+(void)requestDialsID:(NSString *)dialID
               IsFree:(BOOL)isFree
                 Page:(int )page Size:(int)size
               Result:(void(^)(NSArray *info))result
{
    NSString * accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    NSDictionary *headers = @{@"content-type": @"application/json",
                              @"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/watch/shop/page?dialid=%@&page=%d&size=%d&isfree=false",BaseURL,dialID,page,size];
    if (isFree == YES) {
        rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/watch/shop/page?dialid=%@&page=%d&size=%d&isfree=true",BaseURL,dialID,page,size];
    }
    
    [self requestUrl:rqUrl Header:headers  Body:nil Result:^(NSDictionary *info) {
        if(info){
            if (![info[@"data"] isEqual:[NSNull null]]) {
                NSArray *arr = info[@"data"][@"records"];
                if (result) result(arr);
            }else{
                kJLLog(JLLOG_DEBUG, @"Purchased Watch null");
                if (result) result(nil);
            }
        }else{
            if (result) result(nil);
        }
    }];
}



/**
  已购买的表盘
 */
+(void)requestPurchasedDialsPage:(int )page Size:(int)size
                          Result:(void(^)(NSArray *info))result{

    NSString * accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"content-type": @"application/json",
                              @"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/watch/shop/payment/page?page=%d&size=%d",BaseURL,page,size];
                              
    [self requestUrl:rqUrl Header:headers Body:nil Result:^(NSDictionary *info) {
        if(info){
            if (![info[@"data"] isEqual:[NSNull null]]) {
                NSArray *arr = info[@"data"][@"records"];
                if (result) result(arr);
            }else{
                kJLLog(JLLOG_DEBUG, @"Purchased Watch null");
                if (result) result(nil);
            }
        }else{
            if (result) result(nil);
        }
    }];
}



/**
  根据表盘唯一UUID，pid，vid获取表盘信息及图片
 */
+(void)getDialInfoWithUUID:(NSString*)uuid Pid:(int)pid Vid:(int)vid
                     IsPay:(BOOL)isPay Result:(void(^)(NSDictionary *info))result{
    NSString * accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = nil;
    if(!isPay){
        //API:5-3
        rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/watch/dial/version/onebyuuid?uuid=%@&pid=%d&vid=%d",BaseURL,uuid,pid,vid];
    }else{
        //API:9-3
        rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/watch/shop/onebyuuid?uuid=%@&pid=%d&vid=%d",BaseURL,uuid,pid,vid];
    }
    
    [self requestUrl:rqUrl Header:headers Body:nil Result:result];
}

/**
   获取表盘的下载url
 */
+(void)getDialDownloadUrlWithID:(NSString *)idstr Result:(void(^)(NSDictionary *info))result{
    NSString * accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/watch/shop/downloadbyid?id=%@",BaseURL,idstr];
    [self requestUrl:rqUrl Header:headers Body:nil Result:result];
}


/**
   获取表盘的下载url
 */
+(void)verifyReceipt:(NSString *)receipt
           isSandBox:(BOOL)isBox
              ShopID:(NSString*)shopId
              Result:(void(^)(NSDictionary *info))result
{
    NSString * accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"content-type": @"application/json",
                              @"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/watch/shop/apple/verify",BaseURL];
    NSDictionary *deviceDic = @{@"isSandBox": @(isBox),
                                @"receiptData": receipt,
                                @"shopId": shopId};
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:deviceDic options:0 error:nil];
    [self requestUrl:rqUrl Header:headers Body:bodyData Result:result];
}

/**
    购买记录
 */
+(void)requestPayRecordPage:(int )page Size:(int)size
                     Result:(void(^)(NSArray *info))result{

    NSString * accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"content-type": @"application/json",
                              @"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/watch/shop/payment/record/page?page=%d&size=%d",BaseURL,page,size];
                              
    [self requestUrl:rqUrl Header:headers Body:nil Result:^(NSDictionary *info) {
        if(info){
            if (![info[@"data"] isEqual:[NSNull null]]) {
                NSArray *arr = info[@"data"][@"records"];
                if (result) result(arr);
            }else{
                kJLLog(JLLOG_DEBUG, @"Purchased Watch null");
                if (result) result(nil);
            }
        }else{
            if (result) result(nil);
        }
    }];
}

/**
   免费表盘支付
 */
+(void)payForFreeDialShopID:(NSString*)shopId
                     Result:(void(^)(NSDictionary *info))result
{
    NSString * accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"content-type": @"application/json",
                              @"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/watch/shop/freepay?shopid=%@",BaseURL,shopId];
    [self requestUrl:rqUrl Header:headers Body:nil Result:result];
}

+(void)deleteHistoryDialRecordID:(NSString*)shopId
                        Result:(void(^)(NSDictionary *info))result{
    NSString * accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"content-type": @"application/json",
                              @"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/watch/shop/payment/removebyid?id=%@",BaseURL,shopId];
    [self requestUrl:rqUrl Header:headers Body:nil Result:result];
}


+(void)requestUrl:(NSString*)url
           Header:(NSDictionary*)headers
             Body:(NSData *__nullable)bodyData
           Result:(void(^)(NSDictionary *info))result
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    if(bodyData)[request setHTTPBody:bodyData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            kJLLog(JLLOG_DEBUG, @"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}



@end
