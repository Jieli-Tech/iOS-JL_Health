//
//  JLAudioToolBox.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/7/20.
//

#import "JLAudioToolBox.h"

@interface JLAudioToolBox() <AVAudioPlayerDelegate>

/**
 播放器
 */
@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation JLAudioToolBox

+ (instancetype)sharedInstance {
    static JLAudioToolBox *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)playAudioWithFileUrlString:(NSString *)fileUrlString {
    
    NSURL *audioPathUrl = [[NSURL alloc] initFileURLWithPath:fileUrlString];
    NSError *err;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioPathUrl error:&err];
    _player.volume = 1.0f;
    _player.delegate = self;
    _player.rate = 1.0;
    [_player prepareToPlay];
    [_player play];
    
//    NSURL *audioPath = [[NSURL alloc] initFileURLWithPath:fileUrlString];
//    //定义SystemSoundID，后面需要在completion中精确控制控制可交由外部进行定义
//    SystemSoundID soundId;
//    //注册服务
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &soundId);
//    //增添回调方法
//    AudioServicesAddSystemSoundCompletion(soundId, (__bridge CFRunLoopRef _Nullable)([NSRunLoop currentRunLoop]), (CFStringRef)@"NSRunLoopCommonModes", NULL, NULL);
//    //开始播放
//    AudioServicesPlayAlertSound(soundId);
//    AudioServicesPlaySystemSound(soundId);
}

#pragma mark - AVAudioPlayerDelegate

/**
 完成播放， 但是在打断播放和暂停、停止不会调用
 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
}

/**
 播放过程中解码错误时会调用
 */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    
}

@end
