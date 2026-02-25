//
//  JLAudioToolBox.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/7/20.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLAudioToolBox : NSObject

/**
 *  单例方法
 *  @return返回一个共享对象
 */
+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)playAudioWithFileUrlString:(NSString *)fileUrlString;

@end

NS_ASSUME_NONNULL_END
