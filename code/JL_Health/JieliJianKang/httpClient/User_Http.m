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

#define requestSendMobile @"/health/v1/api/auth/sms/send?mobile="
#define requestSendEmail  @"/health/v1/api/auth/email/send?email="
#define checkMobile       @"/health/v1/api/auth/sms/check?"
#define checkEmail        @"/health/v1/api/auth/email/check?"
#define smsRegister       @"/health/v1/api/auth/sms/register?"
#define emailRegister     @"/health/v1/api/auth/email/register?"
#define smsResetPwd       @"/health/v1/api/auth/sms/resetpassword?"
#define smsResetEmail     @"/health/v1/api/auth/email/resetpassword?"
#define smsLogin          @"/health/v1/api/auth/sms/login?"
#define emailLogin        @"/health/v1/api/auth/email/login?"
#define userLogin         @"/health/v1/api/auth/user/login?"
#define emailUserLogin    @"/health/v1/api/auth/email/user/login?"
#define updateMobile      @"/health/v1/api/basic/user/updateMobile?"
#define updateEmail       @"/health/v1/api/basic/user/updateEmail?"
#define updateUserPwd     @"/health/v1/api/basic/user/updatepassword?"
#define setPassword       @"/health/v1/api/basic/user/setpassword?"
#define oneByPidVid       @"/health/v1/api/watch/dial/onebypidvid?"
#define oneByUuid         @"/health/v1/api/watch/dial/version/onebyuuid?"
#define newByPidVid       @"/health/v1/api/watch/ota/version/newbypidvid?"
#define userRemove        @"/health/v1/api/basic/user/remove"
#define pageByVersion     @"/health/v1/api/watch/dial/version/pagebyversion"
#define checkpassword     @"/health/v1/api/basic/user/checkpassword"
#define userRefreshToken  @"/health/v1/api/auth/user/refresh?"
#define emailRefreshToken @"/health/v1/api/auth/email/user/refresh?"
#define configSelect      @"/health/v1/api/basic/user/config/select"
#define configUpdate      @"/health/v1/api/basic/user/config/update"
#define OTA4GModelUrl     @"/health/v1/api/watch/4g/version/newbypidvidid4g?"
#define registerSMSUrl    @"/health/v1/api/auth/sms/captcha/sendregistercode"
#define captchaUrl        @"/health/v1/api/auth/captcha"
#define captchaCheckUrl   @"/health/v1/api/auth/captcha/check?"



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

/// 获取验证码
/// @param result 回调
-(void)requestCapcha:(void(^)(NSDictionary * _Nullable info))result {
    NSDictionary *headers = @{ @"cache-control": @"no-cache"};
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseURL,captchaUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            kJLLog(JLLOG_DEBUG, @"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            kJLLog(JLLOG_DEBUG, @"requestCapcha dict:%@", dict);
            if (result) result(dict);
            
        }
    }];
    [dataTask resume];
}

-(void)checkCapcha:(NSString *)code value:(NSString *)value Result:(void(^)(BOOL status))result{
    NSDictionary *headers = @{ @"cache-control": @"no-cache"};
    NSString *url = [NSString stringWithFormat:@"%@%@code=%@&value=%@",BaseURL,captchaCheckUrl,code,value];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            kJLLog(JLLOG_DEBUG, @"error:%@", error);
            if (result) result(false);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            if ([dict[@"code"] integerValue] == 0 && [dict[@"data"] boolValue]) {
                kJLLog(JLLOG_DEBUG, @"verify Code Success:%@",dict);
                if (result) result(true);
            }else{
                if (result) result(false);
                kJLLog(JLLOG_DEBUG, @"verify Code Fail:%@",dict);
            }
            
        }
    }];
    [dataTask resume];
}

/**
 发送短信验证码接口
 @param mobile  手机号
 */
- (void)requestSMSCode:(NSString *__nullable)mobile
               OrEmail:(NSString *__nullable)email
            CapchaCode:(NSString * __nullable)code
           CapchaValue:(NSString * __nullable)value
                Result:(void(^)(NSDictionary *info))result
{
    NSDictionary *headers = @{ @"cache-control": @"no-cache"};
    
    NSString *rqUrl = nil;
    if (mobile.length > 0) {
        rqUrl = [NSString stringWithFormat:@"%@%@%@&code=%@&value=%@",BaseURL,requestSendMobile,mobile,code,value];
    }
    if (email.length > 0)  rqUrl = [NSString stringWithFormat:@"%@%@%@",BaseURL,requestSendEmail,email];

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            kJLLog(JLLOG_DEBUG, @"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            kJLLog(JLLOG_DEBUG, @"--->requestSMSCode:%@",dict);
            if (result) result(dict);
        }
    }];
    [dataTask resume];
}

- (void)requestRegisterSMSCode:(NSString *)mobile CapchaCode:(NSString *)code CapchaValue:(NSString *)value Result:(void(^)(NSDictionary *info))result{
    NSDictionary *headers = @{ @"cache-control": @"no-cache"};
    NSString *rqUrl = [NSString stringWithFormat:@"%@%@%@&code=%@&value=%@",BaseURL,registerSMSUrl,mobile,code,value];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            kJLLog(JLLOG_DEBUG, @"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            kJLLog(JLLOG_DEBUG, @"--->requestRegisterSMSCode:%@",dict);
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
    if(mobile.length > 0) rqUrl = [NSString stringWithFormat:@"%@%@mobile=%@&code=%@",BaseURL,checkMobile,mobile,code];
    if(email.length > 0)  rqUrl = [NSString stringWithFormat:@"%@%@email=%@&code=%@",BaseURL,checkEmail,email,code];

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            kJLLog(JLLOG_DEBUG, @"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            //kJLLog(JLLOG_DEBUG, @"--->checkSMSCode:%@",dict);
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
        rqUrl = [NSString stringWithFormat:@"%@%@mobile=%@&password=%@&code=%@",BaseURL,smsRegister,mobile,password,code];
        self->myUserWay = JLUSER_WAY_PHONE;
    }
    if(email.length > 0) {
        rqUrl = [NSString stringWithFormat:@"%@%@email=%@&password=%@&code=%@",BaseURL,emailRegister,email,password,code];
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
            kJLLog(JLLOG_DEBUG, @"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            //kJLLog(JLLOG_DEBUG, @"--->requestRegister:%@",dict);
            int code = [dict[@"code"] intValue];
            NSNull *nul = [NSNull new];
            if (![dict[@"data"] isEqual:nul] && code == 0) {
                self->accessToken = dict[@"data"][@"access_token"];
                
                [JL_Tools setUser:@(self->myUserWay) forKey:kUI_HTTP_USER_WAY];
                [JL_Tools setUser:self->accessToken forKey:kUI_ACCESS_TOKEN];
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
    if(mobile.length > 0) rqUrl = [NSString stringWithFormat:@"%@%@mobile=%@&password=%@&code=%@",BaseURL,smsResetPwd,mobile,password,code];
    if(email.length > 0)  rqUrl = [NSString stringWithFormat:@"%@%@email=%@&password=%@&code=%@",BaseURL,smsResetEmail,email,password,code];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            kJLLog(JLLOG_DEBUG, @"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            //kJLLog(JLLOG_DEBUG, @"--->resetPassword:%@",dict);
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
        rqUrl = [NSString stringWithFormat:@"%@%@mobile=%@&code=%@",BaseURL,smsLogin,mobile,code];
        self->myUserWay = JLUSER_WAY_PHONE;
    }
    if(email.length > 0) {
        rqUrl = [NSString stringWithFormat:@"%@%@email=%@&code=%@",BaseURL,emailLogin,email,code];
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
            kJLLog(JLLOG_DEBUG, @"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            int code = [dict[@"code"] intValue];
            NSNull *nul = [NSNull new];
            if (![dict[@"data"] isEqual:nul] && code == 0) {
                self->accessToken = dict[@"data"][@"access_token"];
                
                [JL_Tools setUser:@(self->myUserWay) forKey:kUI_HTTP_USER_WAY];
                [JL_Tools setUser:self->accessToken forKey:kUI_ACCESS_TOKEN];
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
        rqUrl = [NSString stringWithFormat:@"%@%@mobile=%@&password=%@",BaseURL,userLogin,mobile,password];
        self->myUserWay = JLUSER_WAY_PHONE;
    }
    if(email.length > 0) {
        rqUrl = [NSString stringWithFormat:@"%@%@email=%@&password=%@",BaseURL,emailUserLogin,email,password];
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
            kJLLog(JLLOG_DEBUG, @"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            int code = [dict[@"code"] intValue];
            NSNull *nul = [NSNull new];
            if (![dict[@"data"] isEqual:nul] && code == 0) {
                self->accessToken = dict[@"data"][@"access_token"];
                
                [JL_Tools setUser:@(self->myUserWay) forKey:kUI_HTTP_USER_WAY];
                [JL_Tools setUser:self->accessToken forKey:kUI_ACCESS_TOKEN];
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
    accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    
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
    NSString *rqUrl = [NSString stringWithFormat:@"%@%@",BaseURL,configUpdate];
    
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
            kJLLog(JLLOG_DEBUG, @"error:%@", error);
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
    accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    
    if (accessToken.length == 0) {
        self.userInfo = [[JLUser alloc] init];
        if (result) result(self.userInfo);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@%@",BaseURL,configSelect];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            kJLLog(JLLOG_DEBUG, @"error:%@", error);
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
    accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = nil;
    if(mobile.length > 0) rqUrl = [NSString stringWithFormat:@"%@%@mobile=%@&code=%@",BaseURL,updateMobile,mobile,code];
    if(email.length > 0)  rqUrl = [NSString stringWithFormat:@"%@%@email=%@&code=%@",BaseURL,updateEmail,email,code];
    
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
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

/**
 刷新jwt-token
 */
-(void)refreshAccessToken{
    accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    if (accessToken.length == 0) {
        [JL_Tools setUser:@"" forKey:kUI_ACCESS_TOKEN];
        [JL_Tools post:kUI_TOKEN_IS_NULL Object:@"N"];
        return;
    }
    NSDictionary *headers = @{ @"cache-control": @"no-cache"};
    NSString *rqUrl = nil;
    
    JLUSER_WAY userWay = [[JL_Tools getUserByKey:kUI_HTTP_USER_WAY] intValue];
    if (userWay == JLUSER_WAY_PHONE) {
        rqUrl = [NSString stringWithFormat:@"%@%@token=%@",BaseURL,userRefreshToken,accessToken];
    } else {
        rqUrl = [NSString stringWithFormat:@"%@%@token=%@",BaseURL,emailRefreshToken,accessToken];
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
            kJLLog(JLLOG_DEBUG, @"error:%@", error);
            [JL_Tools setUser:@"" forKey:kUI_ACCESS_TOKEN];
            [JL_Tools post:kUI_TOKEN_IS_NULL Object:@"N"];
        } else {
            NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            int code = [info[@"code"] intValue];
            if (code != 0 || info == nil) {
                [JL_Tools setUser:@"" forKey:kUI_ACCESS_TOKEN];
                [JL_Tools post:kUI_TOKEN_IS_NULL Object:@"N"];
            } else {
                self.userPfInfo = [UserProfile locateProfile];
                [self.userPfInfo logProperties];
                if (!self.userPfInfo) {
                    [self getUserProfile:^(UserProfile * _Nonnull upInfo) {
                        
                    }];
                } else {
                    [self initializeDatabase];
                }
            }
        }
    }];
    [dataTask resume];
}

/**
  通过旧密码修改密码
 */
-(void)requestOldPwdModifyNewPwd:(NSString *)oldPwd WithNewPwd:(NSString *)newPwd Result:(void(^)(NSDictionary *info))result{
    accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@%@oldpassword=%@&newpassword=%@",BaseURL,updateUserPwd,oldPwd,newPwd];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
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

/**
  判断密码是否为空(首次自动注册)
 */
-(void)requestPwdIsNull:(void(^)(NSDictionary *info))result{
    accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@%@",BaseURL,checkpassword];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
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

/**
  首次自动注册，设置密码
 */
-(void)requestSetPwd:(NSString *)pwd Result:(void(^)(NSDictionary *info))result{
    accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@%@password=%@",BaseURL,setPassword,pwd];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
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

/**
  根据pid、vid查询表盘产品信息
 */
-(void)requestWatchInfo:(NSString *)pid WithVid:(NSString *)vid Result:(void(^)(NSDictionary *info))result{
    accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    int mPid = [pid intValue];
    int mVid = [vid intValue];
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@%@pid=%d&vid=%d",BaseURL,oneByPidVid,mPid,mVid];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
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
    kJLLog(JLLOG_DEBUG, @"Server Watch Pid:%@ Vid:%@ Page:%@ Size:%@ Versions:%@",pid,vid,page,size,watchArray);
    accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    
    if (accessToken.length == 0 || !watchArray) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"content-type": @"application/json",
                              @"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@%@",BaseURL,pageByVersion];
    
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
            kJLLog(JLLOG_DEBUG, @"error:%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if (![dict[@"data"] isEqual:[NSNull null]]) {
                NSArray *arr = dict[@"data"][@"records"];
                if (result) result(arr);
            }else{
                kJLLog(JLLOG_DEBUG, @"error:%@", error);
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
    accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@%@uuid=%@",BaseURL,oneByUuid,uuid];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
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

/**
   根据pidvid获取最新ota文件
 */
-(void)getNewOTAFile:(NSString *)pid WithVid:(NSString *)vid  Result:(void(^)(NSDictionary *info))result{
    accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    int mPid = [pid intValue];
    int mVid = [vid intValue];
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@%@pid=%d&vid=%d",BaseURL,newByPidVid,mPid,mVid];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
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


/// 根据pid、vid查询 4G 模块升级信息
/// - Parameters:
///   - pid: pid
///   - vid: vid
///   - g4Vendor: 4G 模块的支持信息
///   - result: 结果回调
-(void)getNew4GOtaFile:(NSString *)pid withVid:(NSString *)vid G4Vendor:(int)g4Vendor result:(void(^)(NSDictionary *info))result{
    
    accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    int mPid = [JL_Tools HexToData:pid].beBigendUint16;
    int mVid = [JL_Tools HexToData:vid].beBigendUint16;
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@%@pid=%d&vid=%d&id4g=%d",BaseURL,OTA4GModelUrl,mPid,mVid,g4Vendor];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            kJLLog(JLLOG_DEBUG, @"error:%@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) result(nil);
            });
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) result(dict);
            });
        }
    }];
    [dataTask resume];
    
}
/**
   删除用户信息
 */
-(void)deleteUserInfo:(void(^)(NSDictionary *info))result{
    accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache"};
    
    NSString *rqUrl = [NSString stringWithFormat:@"%@%@",BaseURL,userRemove];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
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
        kJLLog(JLLOG_DEBUG, @"AFN---->%f",progress);
        if (result) { result(progress,JLHTTP_ResultDownload);}
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {

        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //下载完成走这个block
        if (!error)
        {
            //如果请求没有错误(请求成功), 则打印地址
            kJLLog(JLLOG_DEBUG, @"AFN---->Success:%@", [filePath lastPathComponent]);
            if (result) { result(1.0,JLHTTP_ResultSuccess);}
        }else{
            kJLLog(JLLOG_DEBUG, @"AFN---->err");
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
            [self.userPfInfo logProperties];
            [self initializeDatabase];
            if (result) {
                result(self.userPfInfo);
            }
        }else{
            kJLLog(JLLOG_DEBUG, @"%s:%@",__func__,dict);
        }
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        kJLLog(JLLOG_DEBUG, @"%s:get user profile failed:%@",__func__,error);
    }];
}

/**
 * 功能：校验手机号码
 */
- (BOOL)validateMobile:(NSString *)mobileNumber
{
    if (mobileNumber.length != 11) {
        return NO;
    }
    /**
     * 手机号码:
     * 13[0-9], 14[5,7], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[6, 7, 8], 18[0-9], 170[0-9]
     * 移动号段: 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
     * 联通号段: 130,131,132,155,156,185,186,145,176,1709
     * 电信号段: 133,153,180,181,189,177,1700
     * 2017年8月，中国电信获得199号段，中国移动得到198号段，中国联通得到166号段。
     */
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|6[6]|8[0-9]|9[89]|7[0678])\\d{8}$";
    
    /**
     * 中国移动：China Mobile
     * 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
     * 2017年8月,中国移动得到198号段
     */
    NSString *CM = @"(^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478]|9[8])\\d{8}$)|(^1705\\d{7}$)";
    /**
     * 中国联通：China Unicom
     * 130,131,132,155,156,185,186,145,176,1709
     * 2017年8月,中国联通得到166号段
     */
    NSString *CU = @"(^1(3[0-2]|4[5]|5[56]|6[6]|7[6]|8[56])\\d{8}$)|(^1709\\d{7}$)";
    /**
     * 中国电信：China Telecom
     * 133,153,180,181,189,177,1700
     * 2017年8月,中国电信获得199号段
     */
    NSString *CT = @"(^1(33|53|77|99|8[019])\\d{8}$)|(^1700\\d{7}$)";
    
    // 广电
    NSString *NRTA = @"^(13\\d|14[5-9]|15[0-3,5-9]|16[2,5,6,7]|17[0-8]|18\\d|19[0-9])\\d{8}$";
    
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestNRTA = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", NRTA];
    BOOL res1 = [regextestmobile evaluateWithObject:mobileNumber];
    BOOL res2 = [regextestcm evaluateWithObject:mobileNumber];
    BOOL res3 = [regextestcu evaluateWithObject:mobileNumber];
    BOOL res4 = [regextestct evaluateWithObject:mobileNumber];
    BOOL res5 = [regextestNRTA evaluateWithObject:mobileNumber];
    
    if (res1 || res2 || res3 || res4 || res5) {
        return YES;
    } else {
        return NO;
    }
}


@end
