//
//  AIKITUsrContext.h
//  AIKIT
//
//  Created by pcfang on 19.5.23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AIKITUsrContext : NSObject

/// 用户标识名称
@property(nonatomic, copy) NSString *ctxName;


/// 用户标识id
@property(nonatomic, assign) NSInteger ctxId;


/// 用户信息
@property(nonatomic, strong) NSDictionary * userInfo;

@end

NS_ASSUME_NONNULL_END
