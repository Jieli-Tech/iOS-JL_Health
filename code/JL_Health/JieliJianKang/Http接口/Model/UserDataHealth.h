//
//  UserDataHealth.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/5/12.
//

#import "UserDataSport.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserDataHealth : UserDataSport

@property (nonatomic, strong) NSData *data;

+ (UserDataHealth *)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
