//
//  User_Http.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/9.
//

#import "User_Http.h"
#import "JL_RunSDK.h"
#import "JLUser.h"
#import "JLSqliteHeartRate.h"
#import "JLSqliteOxyhemoglobinSaturation.h"
#import "JLSqliteStep.h"
#import "JLSqliteSleep.h"
#import "JLSqliteSportRunningRecord.h"
#import "UserDataSync.h"

@implementation User_Http {
    NSString *accessToken; //访问令牌
    JLUSER_WAY myUserWay;
    
    NSURLSessionDownloadTask *downloadTask;
}

+ (User_Http *)shareInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        
        [self refreshAccessTokenResult:^(NSDictionary * _Nonnull info) {
            int code = [info[@"code"] intValue];
            if (code != 0 || info == nil) {
                [JL_Tools setUser:@"" forKey:@"accessToken"];
                [JL_Tools post:@"TOKEN_IS_NULL" Object:@"N"];
            } else {
                self.userPfInfo = [UserProfile locateProfile];
                if (!self.userPfInfo) {
                    [self getUserProfile:^(UserProfile * _Nonnull upInfo) {
                        
                    }];
                } else {
                    [self initializeDatabase];
                }
            }
        }];
    }
    return self;
}

-(NSString *)token{
    return accessToken;
}

-(JLUSER_WAY)userWay{
    return myUserWay;
}

/**
 *  初始化用户数据库
 */
- (void)initializeDatabase {
   // return;
    NSString *identify = self.userPfInfo.identify;
    if (identify != nil && identify.length > 0) {
        [[JLSqliteManager sharedInstance] initializeDatabaseWithUserIdentify:identify];
    }
}

/**
 发送短信验证码接口
 @param mobile  手机号
 */
-(void)requestSMSCode:(NSString *__nullable)mobile
              OrEmail:(NSString *__nullable)email
               Result:(void(^)(NSDictionary *info))result
{
    NSDictionary *headers = @{ @"cache-control": @"no-cache"};
    
    NSString *rqUrl = nil;
    if (mobile.length > 0) rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/auth/sms/send?mobile=%@",BaseURL,mobile];
    if (email.length > 0)  rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/auth/email/send?email=%@",BaseURL,email];

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            //NSLog(@"--->requestSMSCode:%@",dict);
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

/**
 检查短信验证码
 @param mobile  手机号
 @param code     验证码
 */
-(void)checkSMSCode:(NSString *__nullable)mobile
            OrEmail:(NSString *__nullable)email
               Code:(NSString *)code
             Result:(void(^)(NSDictionary *info))result
{
    NSDictionary *headers = @{ @"cache-control": @"no-cache"};
    
    NSString *rqUrl = nil;
    if(mobile.length > 0) rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/auth/sms/check?mobile=%@&code=%@",BaseURL,mobile,code];
    if(email.length > 0)  rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/auth/email/check?email=%@&code=%@",BaseURL,email,code];

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            //NSLog(@"--->checkSMSCode:%@",dict);
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

/**
 注册接口
 @param mobile 手机号
 @param password 密码
 @param code 验证码
 */
-(void)requestRegister:(NSString *__nullable)mobile
               OrEmail:(NSString *__nullable)email
                   Pwd:(NSString *)password
                  Code:(NSString *)code
                Result:(void(^)(NSDictionary *info))result
{
    NSDictionary *headers = @{ @"cache-control": @"no-cache"};
    
    NSString *rqUrl = nil;
    if(mobile.length > 0) {
        rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/auth/sms/register?mobile=%@&password=%@&code=%@",BaseURL,mobile,password,code];
        self->myUserWay = JLUSER_WAY_PHONE;
    }
    if(email.length > 0) {
        rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/auth/email/register?email=%@&password=%@&code=%@",BaseURL,email,password,code];
        self->myUserWay = JLUSER_WAY_EMAIL;
    }

    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            //NSLog(@"--->requestRegister:%@",dict);
            int code = [dict[@"code"] intValue];
            NSNull *nul = [NSNull new];
            if (![dict[@"data"] isEqual:nul] && code == 0) {
                self->accessToken = dict[@"data"][@"access_token"];
                
                [JL_Tools setUser:@(self->myUserWay) forKey:@"httpUserWay"];
                [JL_Tools setUser:self->accessToken forKey:@"accessToken"];
            }
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

/**
 重置密码接口
 @param mobile 手机号
 @param password 密码
 @param code 验证码
 */
-(void)resetPassword:(NSString *__nullable)mobile
             OrEmail:(NSString *__nullable)email
                 Pwd:(NSString *)password
                Code:(NSString *)code
              Result:(void(^)(NSDictionary *info))result
{
    NSDictionary *headers = @{ @"cache-control": @"no-cache"};
    
    NSString *rqUrl = nil;
    if(mobile.length > 0) rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/auth/sms/resetpassword?mobile=%@&password=%@&code=%@",BaseURL,mobile,password,code];
    if(email.length > 0)  rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/auth/email/resetpassword?email=%@&password=%@&code=%@",BaseURL,email,password,code];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            //NSLog(@"--->resetPassword:%@",dict);
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

/**
 验证码登录接口
 @param mobile 手机号
 @param code 验证码
 */
-(void)requestCodeLogin:(NSString *__nullable)mobile
                OrEmail:(NSString *__nullable)email
                   Code:(NSString *)code
                 Result:(void(^)(NSDictionary *info))result
{
    NSDictionary *headers = @{ @"cache-control": @"no-cache"};
    
    NSString *rqUrl = nil;
    if(mobile.length > 0) {
        rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/auth/sms/login?mobile=%@&code=%@",BaseURL,mobile,code];
        self->myUserWay = JLUSER_WAY_PHONE;
    }
    if(email.length > 0) {
        rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/auth/email/login?email=%@&code=%@",BaseURL,email,code];
        self->myUserWay = JLUSER_WAY_EMAIL;
    }

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            int code = [dict[@"code"] intValue];
            NSNull *nul = [NSNull new];
            if (![dict[@"data"] isEqual:nul] && code == 0) {
                self->accessToken = dict[@"data"][@"access_token"];
                
                [JL_Tools setUser:@(self->myUserWay) forKey:@"httpUserWay"];
                [JL_Tools setUser:self->accessToken forKey:@"accessToken"];
                [self getUserProfile:^(UserProfile * _Nonnull upInfo) {
                    
                }];
            }
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

/**
 密码登录接口
 @param mobile 手机号
 @param password 密码
 */
-(void)requestPwdLogin:(NSString *__nullable)mobile
               OrEmail:(NSString *__nullable)email
                   Pwd:(NSString *)password
                Result:(void(^)(NSDictionary *info))result
{
    NSDictionary *headers = @{ @"cache-control": @"no-cache"};
    NSString *rqUrl = nil;
    
    if(mobile.length > 0) {
        rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/auth/user/login?mobile=%@&password=%@",BaseURL,mobile,password];
        self->myUserWay = JLUSER_WAY_PHONE;
    }
    if(email.length > 0) {
        rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/auth/email/user/login?email=%@&password=%@",BaseURL,email,password];
        self->myUserWay = JLUSER_WAY_EMAIL;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            int code = [dict[@"code"] intValue];
            NSNull *nul = [NSNull new];
            if (![dict[@"data"] isEqual:nul] && code == 0) {
                self->accessToken = dict[@"data"][@"access_token"];
                
                [JL_Tools setUser:@(self->myUserWay) forKey:@"httpUserWay"];
                [JL_Tools setUser:self->accessToken forKey:@"accessToken"];
                [self getUserProfile:^(UserProfile * _Nonnull upInfo) {
                    
                }];
            }
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

/**
 设置用户配置信息
 */
- (void)requestUserConfigInfo:(NSString *)nickname
                       Gender:(NSString *)gender
                 BirthdayYear:(NSString *)birthdayYear
                BirthdayMonth:(NSString *)birthdayMonth
                  BirthdayDay:(NSString *)birthdayDay
                       Height:(NSString *)height
                      Weigtht:(NSString *)weight
                         Step:(NSString *)step
                    AvatarUrl:(NSString *)avatarUrl
                  WeightStart:(NSString *)weightStart
                 WeightTarget:(NSString *)weightTarget
                       Result:(void(^ __nullable)(NSDictionary *info))result
{
    accessToken = [JL_Tools getUserByKey:@"accessToken"];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"content-type": @"application/json",
                              @"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSDictionary *userDic = @{ @"nickname": nickname,
                               @"gender": @([gender intValue]),
                               @"birthYear":@([birthdayYear intValue]),
                               @"birthMonth":@([birthdayMonth intValue]),
                               @"birthDay":@([birthdayDay intValue]),
                               @"height": @([height intValue]),
                               @"weight": @([weight floatValue]),
                               @"step": @([step intValue]),
                               @"avatarUrl": @"",
                               @"weightStart": @([weightStart floatValue]),
                               @"weightTarget": @([weightTarget floatValue])
    };
    NSData *postData = [NSJSONSerialization dataWithJSONObject:userDic options:0 error:nil];
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/basic/user/config/update",BaseURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            self.userInfo = [[JLUser alloc] initWithDic:dict];
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

/**
 获取用户配置信息
 */
- (void)requestGetUserConfigInfo:(void(^ __nullable)(JLUser *userInfo))result {
    accessToken = [JL_Tools getUserByKey:@"accessToken"];
    
    if (accessToken.length == 0) {
        self.userInfo = [[JLUser alloc] init];
        if (result) result(self.userInfo);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/basic/user/config/select",BaseURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            int code = [dict[@"code"] intValue];
            if(code == 0){
                NSData *data = [dict[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
                if (data) {
                    NSDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    self.userInfo = [[JLUser alloc] initWithDic:tempDic];
                }
                if (result) result(self.userInfo);
            }
        }
    }];
    [dataTask resume];
}

/**
  修改用户手机号
 */
- (void)changeUserPhoneNumber:(NSString *__nullable)mobile
                      OrEmail:(NSString *__nullable)email
                     WithCode:(NSString *)code
                       Result:(void(^)(NSDictionary *info))result
{
    accessToken = [JL_Tools getUserByKey:@"accessToken"];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = nil;
    if(mobile.length > 0) rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/basic/user/updateMobile?mobile=%@&code=%@",BaseURL,mobile,code];
    if(email.length > 0)  rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/basic/user/updateEmail?email=%@&code=%@",BaseURL,email,code];
    
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

/**
 刷新jwt-token
 */
-(void)refreshAccessTokenResult:(void(^)(NSDictionary *info))result{
    accessToken = [JL_Tools getUserByKey:@"accessToken"];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    NSDictionary *headers = @{ @"cache-control": @"no-cache"};
    NSString *rqUrl = nil;
    
    JLUSER_WAY userWay = [[JL_Tools getUserByKey:@"httpUserWay"] intValue];
    if (userWay == JLUSER_WAY_PHONE) {
        rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/auth/user/refresh?token=%@",BaseURL,accessToken];
    } else {
        rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/auth/email/user/refresh?token=%@",BaseURL,accessToken];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

/**
  通过旧密码修改密码
 */
-(void)requestOldPwdModifyNewPwd:(NSString *)oldPwd WithNewPwd:(NSString *)newPwd Result:(void(^)(NSDictionary *info))result{
    accessToken = [JL_Tools getUserByKey:@"accessToken"];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/basic/user/updatepassword?oldpassword=%@&newpassword=%@",BaseURL,oldPwd,newPwd];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

/**
  判断密码是否为空(首次自动注册)
 */
-(void)requestPwdIsNull:(void(^)(NSDictionary *info))result{
    accessToken = [JL_Tools getUserByKey:@"accessToken"];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/basic/user/checkpassword",BaseURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

/**
  首次自动注册，设置密码
 */
-(void)requestSetPwd:(NSString *)pwd Result:(void(^)(NSDictionary *info))result{
    accessToken = [JL_Tools getUserByKey:@"accessToken"];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/basic/user/setpassword?password=%@",BaseURL,pwd];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

/**
  根据pid、vid查询表盘产品信息
 */
-(void)requestWatchInfo:(NSString *)pid WithVid:(NSString *)vid Result:(void(^)(NSDictionary *info))result{
    accessToken = [JL_Tools getUserByKey:@"accessToken"];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    int mPid = [pid intValue];
    int mVid = [vid intValue];
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/watch/dial/onebypidvid?pid=%d&vid=%d",BaseURL,mPid,mVid];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

/**
  根据pid、vid、version获取表盘列表
 */
-(void)requestWatchList:(NSString *)pid
                WithVid:(NSString *)vid
               WithPage:(NSString *)page
               WithSize:(NSString *)size
           WithVersions:(NSArray *)watchArray
                 Result:(void(^)(NSArray *info))result
{
    NSLog(@"Server Watch Pid:%@ Vid:%@ Page:%@ Size:%@ Versions:%@",pid,vid,page,size,watchArray);
    accessToken = [JL_Tools getUserByKey:@"accessToken"];
    
    if (accessToken.length == 0 || !watchArray) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"content-type": @"application/json",
                              @"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/watch/dial/version/pagebyversion",BaseURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    NSDictionary *deviceDic = @{ @"pid": pid,
                                 @"vid": vid,
                                 @"page": page,
                                 @"size": size,
                                 @"versions": watchArray};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:deviceDic options:0 error:nil];
    
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if (![dict[@"data"] isEqual:[NSNull null]]) {
                NSArray *arr = dict[@"data"][@"records"];
                if (result) result(arr);
            }else{
                NSLog(@"error:%@", error);
                if (result) result(nil);
            }
        }
    }];
    [dataTask resume];
}

/**
  根据表盘唯一UUID获取表盘信息
 */
-(void)getWatchInfo:(NSString *)uuid Result:(void(^)(NSDictionary *info))result{
    accessToken = [JL_Tools getUserByKey:@"accessToken"];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/watch/dial/version/onebyuuid?uuid=%@",BaseURL,uuid];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

/**
   根据pidvid获取最新ota文件
 */
-(void)getNewOTAFile:(NSString *)pid WithVid:(NSString *)vid  Result:(void(^)(NSDictionary *info))result{
    accessToken = [JL_Tools getUserByKey:@"accessToken"];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    int mPid = [pid intValue];
    int mVid = [vid intValue];
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/watch/ota/version/newbypidvid?pid=%d&vid=%d",BaseURL,mPid,mVid];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

/**
   删除用户信息
 */
-(void)deleteUserInfo:(void(^)(NSDictionary *info))result{
    accessToken = [JL_Tools getUserByKey:@"accessToken"];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@/health/v1/api/basic/user/remove",BaseURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

-(void)downloadUrl:(NSString*)urlString Path:(NSString*)path Result:(JLHTTP_BK)result{
    //构造资源链接
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //创建AFN的manager对象
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    //构造URL对象
    NSURL *url = [NSURL URLWithString:urlString];
    //构造request对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //使用系统类创建downLoad Task对象
    downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        float progress = 1.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount;
        NSLog(@"AFN---->%f",progress);
        if (result) { result(progress,JLHTTP_ResultDownload);}
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {

        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //下载完成走这个block
        if (!error)
        {
            //如果请求没有错误(请求成功), 则打印地址
            NSLog(@"AFN---->Success:%@", [filePath lastPathComponent]);
            if (result) { result(1.0,JLHTTP_ResultSuccess);}
        }else{
            NSLog(@"AFN---->err");
            if (result) { result(1.0,JLHTTP_ResultFail);}
        }
    }];
    //开始请求
    [downloadTask resume];
}

-(void)cancelDownloadTask{
    [downloadTask cancel];
}




/// 获取用户信息
/// @param result userprofile
-(void)getUserProfile:(void(^)(UserProfile *upInfo))result{

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [AFJSONRequestSerializer serializer].cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSDictionary *headers = @{@"content-type": @"application/json",
                              @"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    NSString *url = [NSString stringWithFormat:@"%@/health/v1/api/basic/user/profile",BaseURL];
    [manager POST:url parameters:nil headers:headers progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSDictionary *dict = responseObject;
        if ([dict[@"code"] intValue] == 0) {
            self.userPfInfo = [[UserProfile alloc] initWithDic:dict];
            [self initializeDatabase];
            if (result) {
                result(self.userPfInfo);
            }
        }else{
            NSLog(@"%s:%@",__func__,dict);
        }
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%s:get user profile failed:%@",__func__,error);
    }];
    
}


@end
