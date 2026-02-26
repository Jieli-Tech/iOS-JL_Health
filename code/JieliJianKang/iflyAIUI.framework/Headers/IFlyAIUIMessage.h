//
//  IFlyAIUIMessage.h
//  IFlyAIUI
//
//  Created by jmli3 on 2018/7/5.
//

#import <Foundation/Foundation.h>

/*!
 * AIUI消息类，AIUI所有的输入都是通过消息发送到SDK内部。
 */
@interface IFlyAIUIMessage : NSObject

/**
 * 消息类型。
 */
@property (nonatomic, assign) int msgType;

/**
 * 扩展参数1。
 */
@property (nonatomic, assign) int arg1;

/**
 * 扩展参数2。
 */
@property (nonatomic, assign) int arg2;

/**
 * 业务参数。
 */
@property (nonatomic, copy) NSString *params;

/**
 * 附带数据。
 */
@property (nonatomic, strong) NSData *data;

/**
 * 附加参数，一般用于控件层。
 */
@property (nonatomic, strong) NSDictionary *dic;

@end
