//
//  ChatParam.h
//  AIKIT
//
//  Created by pcfang on 5.5.23.
//

#import <Foundation/Foundation.h>
#define ChatParamChainProperty(name,valueType) property (nonatomic, copy, readonly) ChatParam * (^name)(valueType value)
#define ChatParamExtensionChainProperty(name,valueType) property (nonatomic, copy, readonly) ChatParam * (^name)(NSString * key, valueType value)
NS_ASSUME_NONNULL_BEGIN

@interface ChatParam : NSObject

/// 获取实例对象
@property (class, readonly, strong) ChatParam * (^builder) (void);

/// 配置授权的用户id，用于关联用户交互的上下文
@ChatParamChainProperty(uid,NSString * _Nonnull);

/// 配置chat领域信息
@ChatParamChainProperty(domain,NSString * _Nonnull);

/// 配置内容审核策略
@ChatParamChainProperty(auditing,NSString * _Nonnull);

/// 配置关联会话chat id标识，需要保障⽤户下唯⼀
@ChatParamChainProperty(chatID,NSString * _Nonnull);

/// 配置核采样阈值，默认值0.5，向上调整可以增加结果的随机程度
@ChatParamChainProperty(temperature,float);

/// 配置从k个候选中随机选择⼀个（⾮等概率），默认值4，取值范围1-99
@ChatParamChainProperty(topK,int);

/// 配置回答的tokens的最大长度，默认值2048
@ChatParamChainProperty(maxToken,int);

/// 配置chat服务域名地址
@ChatParamChainProperty(url,NSString * _Nonnull);

/// 配置chat扩展功能参数

/// 字符串扩展参数
@ChatParamExtensionChainProperty(addString,NSString * _Nonnull);

/// 整形扩展参数
@ChatParamExtensionChainProperty(addInt,int);

/// 浮点扩展参数
@ChatParamExtensionChainProperty(addDouble,double);

/// 布尔扩展参数
@ChatParamExtensionChainProperty(addBool,bool);

- (void *)realParam;
@end

NS_ASSUME_NONNULL_END
