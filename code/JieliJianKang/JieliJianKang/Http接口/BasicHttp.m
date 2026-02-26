//
//  BasicHttp.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/28.
//

#import "BasicHttp.h"

@implementation BasicHttp

+(NSMutableURLRequest *)Url:(NSString *)url Body:(NSData *_Nullable)data{
    NSString *token = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    NSDictionary *headers = @{@"content-type": @"application/json",
                              @"jwt-token":token?:@"",
                              @"cache-control": @"no-cache"};
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    if (data) {
        [request setHTTPBody:data];
    }
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    
    return request;
}

@end
