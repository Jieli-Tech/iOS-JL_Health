//
//  IFlyAIUIAgent
//  IFlyAIUI
//
//  Created by jmli3 on 2018/7/5.
//

#import <Foundation/Foundation.h>
#import "IFlyAIUIListener.h"
#import "IFlyAIUIMessage.h"

@interface IFlyAIUIAgent : NSObject

-(instancetype) initWithParams:(NSString*) cfgParams withListener:(id) listener;

/*!
 * 创建AIUIAgent
 *
 *  @param cfgParams cfg文件内容
 *  @return YES:设置成功；NO:设置失败
 */
+ (instancetype) createAgent:(NSString *) cfgParams withListener:(id) listener;

/*!
 * 发送AIUI消息
 *
 *  @param msg 消息实例
 */
- (void) sendMessage:(IFlyAIUIMessage *)msg;

/*!
 * 销毁AIUIAgent
 */
- (void) destroy;

/*!
 * 设置GPS定位信息。
 *
 *  @param lng 经度值
 *  @param lat 纬度值
 */
- (void) setGPSwithLng:(NSNumber *)lng andLat:(NSNumber *)lat;

@end
