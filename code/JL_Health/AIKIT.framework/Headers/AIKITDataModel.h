//
//  AEEDataModel.h
//  CoreTest
//
//  Created by chun on 2020/9/8.
//  Copyright © 2020 chun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIKITConstant.h"
NS_ASSUME_NONNULL_BEGIN

@interface AIKITDataModel : NSObject

// 数据标识
@property (nonatomic, copy) NSString *key;

// 数据体
@property (nonatomic, assign) void* value;

// 数据长度
@property (nonatomic, assign) unsigned int len;

// 数据状态
@property (nonatomic, assign) int status;

// 数据类型（文本，视频，音频等）
@property (nonatomic, assign) DATA_TYPE type;

@property (nonatomic, assign) VAR_TYPE varType;

@end

NS_ASSUME_NONNULL_END
