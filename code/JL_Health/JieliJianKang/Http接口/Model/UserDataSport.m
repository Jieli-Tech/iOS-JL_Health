//
//  UserDataSport.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/5/12.
//

#import "UserDataSport.h"

@implementation UserDataSport


+ (UserDataSport *)initWithDictionary:(NSDictionary *)dict {
    UserDataSport *sport = [[UserDataSport alloc] init];
    sport.idString = [dict objectForKey:@"id"];
    sport.uuid = [dict objectForKey:@"uuid"];
    sport.uid = [dict objectForKey:@"uid"];
    sport.type = [dict objectForKey:@"type"];
    NSString *date = [dict objectForKey:@"date"];
    sport.date = date.toDateByNormal;
    NSString *createTime = [dict objectForKey:@"createTime"];
    sport.createTime = createTime.toDateByNormal;
    sport.dataPath = [dict objectForKey:@"data"];
    return sport;
}

@end
