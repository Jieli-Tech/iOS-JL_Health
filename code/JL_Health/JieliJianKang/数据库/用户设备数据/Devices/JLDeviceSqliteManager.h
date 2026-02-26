//
//  JLDeviceSqliteManager.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/22.
//

#import <Foundation/Foundation.h>

@class UserDeviceModel;

NS_ASSUME_NONNULL_BEGIN

@interface JLDeviceSqliteManager : NSObject

+(instancetype)share;

-(void)update:(UserDeviceModel *)model;

-(void)update:(UserDeviceModel *)model Time:(NSDate *)updateDate;

-(void)checkoutBy:(NSString *)checkUserID result:(void(^)(NSArray<UserDeviceModel *> * resultArray))result;

-(void)checkoutAll:(void(^)(NSArray<UserDeviceModel *> *resultArray))result;

-(void)deleteBy:(UserDeviceModel *)model;

@end

NS_ASSUME_NONNULL_END
