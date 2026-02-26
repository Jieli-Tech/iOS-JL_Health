//
//  UserDataSport.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/5/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserDataSport : NSObject

@property (nonatomic, strong) NSString     *idString;
@property (nonatomic, strong) NSString     *uuid;
@property (nonatomic, strong) NSString     *uid;
@property (nonatomic, strong) NSString     *type;
@property (nonatomic, strong) NSDate       *date;
@property (nonatomic, strong) NSDate       *createTime;
@property (nonatomic, strong) NSString     *dataPath;

+ (UserDataSport *)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
