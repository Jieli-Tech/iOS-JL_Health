//
//  IFlyAIUIServiceDelegate.h
//  IFlyAIUI
//
//  Created by jmli3 on 2018/7/5.
//

#import "IFlyAIUIEvent.h"

@protocol IFlyAIUIListener <NSObject>

@required
/*!
 * 事件回调<br>
 * SDK所有输出都通过event抛出。
 *
 @param event AIUI事件，具体参见IFlyAIUIEvent。
 */
- (void) onEvent:(IFlyAIUIEvent *) event ;

@end
