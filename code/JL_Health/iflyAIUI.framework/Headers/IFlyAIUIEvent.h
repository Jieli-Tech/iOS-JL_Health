//
//  IFlyAIUIEvent.h
//  IFlyAIUI
//
//  Created by jmli3 on 2018/7/5.
//

#import <Foundation/Foundation.h>


/*!
 * AIUI事件类，业务结果、SDK内部状态变化等输出信息都通过事件抛出。
 */
@interface IFlyAIUIEvent : NSObject

/**
 * 事件类型。
 */
@property (nonatomic, assign) int eventType;

/**
 * 扩展参数1。
 */
@property (nonatomic, assign) int arg1;

/**
 * 扩展参数2。
 */
@property (nonatomic, assign) int arg2;

/**
 * 描述信息。
 */
@property (nonatomic, copy) NSString *info;

/**
 * 附带数据。
 */
@property (nonatomic, strong) NSDictionary *data;

@end
