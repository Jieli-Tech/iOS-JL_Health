//
//  UserDataHealth.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/5/12.
//

#import "UserDataHealth.h"

@implementation UserDataHealth

+ (UserDataHealth *)initWithDictionary:(NSDictionary *)dict {
    UserDataHealth *health = [[UserDataHealth alloc] init];
    health.idString = [dict objectForKey:@"id"];
    health.uuid = [dict objectForKey:@"uuid"];
    health.uid = [dict objectForKey:@"uid"];
    health.type = [dict objectForKey:@"type"];
    NSString *date = [dict objectForKey:@"date"];
    health.date = date.toDateByNormal;
    NSString *createTime = [dict objectForKey:@"createTime"];
    health.createTime = createTime.toDateByNormal;
    NSString *base64Str = [dict objectForKey:@"data"];
    health.data = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return health;
}

@end
