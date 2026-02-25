//
//  JLUser.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLUser : NSObject

@property (strong, nonatomic) NSString *nickname;
@property (assign, nonatomic) int gender;
@property (assign, nonatomic) int birthYear;
@property (assign, nonatomic) int birthMonth;
@property (assign, nonatomic) int birthDay;
@property (assign, nonatomic) int height;
@property (assign, nonatomic) float weight;
@property (assign, nonatomic) float weightStart;
@property (assign, nonatomic) float weightTarget;
@property (assign, nonatomic) int step;
@property (assign, nonatomic) NSString *avatarUrl;

- (id)initWithDic:(NSDictionary *)dic;
- (id)initWithWeightStartDic:(NSDictionary *)dic;
- (NSString *)genderText;

@end


@interface UserProfile : NSObject

@property(nonatomic,strong)NSString     *identify;
@property(nonatomic,strong)NSString     *uuid;
@property(nonatomic,strong)NSString     *mobile;
@property(nonatomic,strong)NSString     *email;
@property(nonatomic,strong)NSString     *password;
@property(nonatomic,strong)NSDate       *registerTime;
@property(nonatomic,strong)NSDate       *lastLoginTime;
@property(nonatomic,strong)NSString     *configData;
@property(nonatomic,assign)NSInteger    status;
@property(nonatomic,strong)NSString     *explain;

- (id)initWithDic:(NSDictionary *)dic;
- (NSDictionary *)beDict;
+ (UserProfile * _Nullable)locateProfile;
+ (void)removeProfile;
@end

NS_ASSUME_NONNULL_END
