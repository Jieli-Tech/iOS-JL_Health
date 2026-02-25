//
//  User_Http.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(UInt8, JLHTTP_Result) {
    JLHTTP_ResultFail         = 0x00, //下载失败
    JLHTTP_ResultSuccess      = 0x01, //下载成功
    JLHTTP_ResultDownload     = 0x02, //正在下载
};

typedef NS_ENUM(UInt8, JLUSER_WAY) {
    JLUSER_WAY_PHONE = 0x00, //使用手机号码
    JLUSER_WAY_EMAIL = 0x01, //使用邮箱
};


typedef void(^JLHTTP_BK)(float progress, JLHTTP_Result result);

@class JLUser;
@class UserProfile;

@interface User_Http : NSObject

+ (instancetype)shareInstance;

@property(strong, nonatomic) JLUser *userInfo;
@property(strong, nonatomic) UserProfile *userPfInfo;

@property(nonatomic,strong,readonly)NSString *token;
@property(nonatomic,assign,readonly)JLUSER_WAY userWay;

/**
 发送短信验证码接口
 @param mobile  手机号
 */
- (void)requestSMSCode:(NSString *__nullable)mobile
               OrEmail:(NSString *__nullable)email
                Result:(void(^)(NSDictionary *info))result;

/**
 检查短信验证码
 @param mobile  手机号
 @param code     验证码
 */
- (void)checkSMSCode:(NSString *__nullable)mobile
             OrEmail:(NSString *__nullable)email
                Code:(NSString *)code
              Result:(void(^)(NSDictionary *info))result;

/**
 注册接口
 @param mobile 手机号
 @param password 密码
 @param code 验证码
 */
- (void)requestRegister:(NSString *__nullable)mobile
                OrEmail:(NSString *__nullable)email
                    Pwd:(NSString *)password
                   Code:(NSString *)code
                 Result:(void(^)(NSDictionary *info))result;

/**
 重置密码接口
 @param mobile 手机号
 @param password 密码
 @param code 验证码
 */
- (void)resetPassword:(NSString *__nullable)mobile
              OrEmail:(NSString *__nullable)email
                  Pwd:(NSString *)password
                 Code:(NSString *)code
               Result:(void(^)(NSDictionary *info))result;

/**
 验证码登录接口
 @param mobile 手机号
 @param code 验证码
 */
- (void)requestCodeLogin:(NSString *__nullable)mobile
                 OrEmail:(NSString *__nullable)email
                    Code:(NSString *)code
                  Result:(void(^)(NSDictionary *info))result;

/**
 密码登录接口
 @param mobile 手机号
 @param password 密码
 */
- (void)requestPwdLogin:(NSString *__nullable)mobile
                OrEmail:(NSString *__nullable)email
                    Pwd:(NSString *)password
                 Result:(void(^)(NSDictionary *info))result;

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
                       Result:(void(^ __nullable)(NSDictionary *info))result;

/**
 获取用户配置信息
 */
- (void)requestGetUserConfigInfo:(void(^ __nullable)(JLUser *userInfo))result;

/**
  修改用户手机号
 */
- (void)changeUserPhoneNumber:(NSString *__nullable)mobile
                      OrEmail:(NSString *__nullable)email
                     WithCode:(NSString *)code
                       Result:(nullable void(^)(NSDictionary *info))result;

/**
 刷新jwt-token
 */
-(void)refreshAccessTokenResult:(void(^)(NSDictionary *info))result;

/**
  通过旧密码修改密码
 */
- (void)requestOldPwdModifyNewPwd:(NSString *)oldPwd WithNewPwd:(NSString *)newPwd Result:(void(^)(NSDictionary *info))result;

/**
  判断密码是否为空(首次自动注册)
 */
- (void)requestPwdIsNull:(void(^)(NSDictionary *info))result;

/**
  首次自动注册，设置密码
 */
- (void)requestSetPwd:(NSString *)pwd Result:(void(^)(NSDictionary *info))result;

/**
  根据pid、vid查询表盘产品信息
 */
- (void)requestWatchInfo:(NSString *)pid WithVid:(NSString *)vid  Result:(void(^)(NSDictionary *info))result;

/**
  根据pid、vid、version获取表盘列表
 */
- (void)requestWatchList:(NSString *)pid
                 WithVid:(NSString *)vid
                WithPage:(NSString *)page
                WithSize:(NSString *)size
            WithVersions:(NSArray *)watchArray
                  Result:(void(^)(NSArray *info))result;

/**
  根据表盘唯一UUID获取表盘信息
 */
- (void)getWatchInfo:(NSString *)uuid Result:(void(^)(NSDictionary *info))result;

/**
   根据pidvid获取最新ota文件
 */
-(void)getNewOTAFile:(NSString *)pid WithVid:(NSString *)vid  Result:(void(^)(NSDictionary *info))result;

/**
   删除用户信息
 */
-(void)deleteUserInfo:(void(^)(NSDictionary *info))result;

-(void)downloadUrl:(NSString*)urlString Path:(NSString*)path Result:(JLHTTP_BK)result;
-(void)cancelDownloadTask;

/// 获取用户信息
/// @param result userprofile
-(void)getUserProfile:(void(^)(UserProfile *upInfo)) result;
@end
NS_ASSUME_NONNULL_END
