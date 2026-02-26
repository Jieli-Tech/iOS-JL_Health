//
//  JLAnimationTool.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/31.
//

#import <Foundation/Foundation.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface JLAnimationTool : NSObject
+(void)loadImageResource;
+(void)unloadImageResource;
+(void)startSearchAnimationTime:(float)time;

@end

NS_ASSUME_NONNULL_END
