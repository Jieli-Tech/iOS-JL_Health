//
//  JLAiManager.h
//  JL_BLEKit
//
//  Created by EzioChan on 2023/8/9.
//  Copyright © 2023 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JL_BLEKit/JL_TypeEnum.h>

NS_ASSUME_NONNULL_BEGIN


@class JL_ManagerM;
@class JLAiManager;

@protocol JLAIManagerDelegate <NSObject>

/// 设备回调/推送结果
/// - Parameter mgr: JLAiManager
-(void)jlaiUpdateStatus:(JLAiManager *)mgr;

@end


/// AI状态 管理类
/// 当前接口适用于一些支持设备对讲的设备，在使用时需要先初始化当前类并接受代理：JLAIManagerDelegate
/// 在初始化后需要主动获取状态才可以获得首次的状态内容
///
@interface JLAiManager : NSObject


/// 版本号
@property(assign,nonatomic)uint8_t version;

/// 0x00:默认状态
/// 0x01:进入AI界面
/// 0x02:退出AI界面
@property(assign,nonatomic)uint8_t status;

/// 回调代理
@property(weak,nonatomic)id<JLAIManagerDelegate> delegate;

/// 获取AI 的状态
///- Parameters:
///   - manager: 设备对象
-(void)getStatus:(JL_ManagerM *)manager;

/// 设置设备的状态
/// - Parameters:
///   - manager: 设备对象
///   - result: 回调结果
-(void)setToDevice:(JL_ManagerM *)manager result:(JL_CMD_RESPOND _Nullable)result;

@end

NS_ASSUME_NONNULL_END
