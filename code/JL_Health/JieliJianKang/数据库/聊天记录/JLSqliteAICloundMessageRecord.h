//
//  JLSqliteAICloundMessageRecord.h
//  JieliJianKang
//
//  Created by 李放 on 2023/8/2.
//

#import <Foundation/Foundation.h>
#import "AICloundMessageModel.h"

NS_ASSUME_NONNULL_BEGIN


typedef void(^SqlAICloundMessageBlock)(NSArray<AICloundMessageModel *> *chatMessages);

@interface JLSqliteAICloundMessageRecord : NSObject

/// 查询数据
/// @param date 日期
/// @param block 聊天记录回调
+ (void)s_checkoutWtihDate:(NSDate *)date WithOffset:(int) offset WithResult:(SqlAICloundMessageBlock)block;

/// 插入或更新数据
/// @param model 数据模型
+ (void)s_update:(AICloundMessageModel *)model;

/// 根据日期删除对应的数据
/// @param selectDateArray 日期
+ (void)s_delete:(NSArray *) selectDateArray;

/// 清空所有的数据
+ (void)clean;
@end

NS_ASSUME_NONNULL_END
