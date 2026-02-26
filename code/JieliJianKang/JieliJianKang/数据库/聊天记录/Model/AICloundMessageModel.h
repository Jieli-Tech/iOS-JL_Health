//
//  AICloundMessageModel.h
//  JieliJianKang
//
//  Created by 李放 on 2023/8/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AICloundMessageModel : NSObject

@property (nonatomic, assign) NSInteger index; //选中的索引
@property (nonatomic, assign) int role;//角色
@property (nonatomic, assign) int aiCloudState; //语音识别的状态
@property (nonatomic, assign) NSDate *date; //聊天记录的时间
@property (nonatomic, strong) NSString *text; //文本内容
@property (nonatomic, assign) BOOL isFirstPage; //是否是第一页

@end

NS_ASSUME_NONNULL_END
