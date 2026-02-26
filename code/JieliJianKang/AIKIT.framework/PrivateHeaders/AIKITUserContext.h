//
//  EdgeAIUserParam.h
//  EdgeAISDK
//
//  Created by Jean.
//  Copyright © 2021 Jean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AiHelper.h"
#import "AIKITCtxContent.h"
NS_ASSUME_NONNULL_BEGIN

@interface AIKITUserContext : NSObject
// 当前执行服务对象
@property(nonatomic, strong) AiHelper *helper;

@property(nonatomic, strong) AIKITCtxContent *content;

@end

NS_ASSUME_NONNULL_END
