//
//  AIKITAudioBuilder.h
//  AiSoundDemo
//
//  Created by pcfang on 1.4.22.
//

#import <Foundation/Foundation.h>
#import "AiAudioDefine.h"
@class AiHandle;

#define AIKITAudioBuilderProperty(Type,Name) AIKITAudioBuilder * (^Name)(Type)

NS_ASSUME_NONNULL_BEGIN

@interface AIKITAudioBuilder : NSObject

@property (nonatomic, assign) AudioSampleRate sampleRateValue;

@property (nonatomic, assign) AudioLinearPCMBitDepth depthValue;

@property (nonatomic, assign) AudioChannels channelValue;

@property (nonatomic, strong) AiHandle * handleValue;

@property (nonatomic, assign) UInt32 bufferSizeValue;

// 合成需要设置的参数
@property (nonatomic, assign) UInt64 textLengthValue;

@property (nonatomic, copy) void(^progressValue)(int index);

// 录音参数
@property (nonatomic, strong) NSString * inputKeyValue;

@property (nonatomic, copy) void(^decibelValue)(int decibel);

@property (nonatomic, copy) void(^compeletionValue)(BOOL successfully);



@property (nonatomic, copy, readonly, class) AIKITAudioBuilder * (^builder)(void);

@property (nonatomic, copy, readonly) AIKITAudioBuilderProperty(AudioSampleRate, sampleRate);

@property (nonatomic, copy, readonly) AIKITAudioBuilderProperty(AudioLinearPCMBitDepth, depth);

@property (nonatomic, copy, readonly) AIKITAudioBuilderProperty(AudioChannels, channel);

@property (nonatomic, copy, readonly) AIKITAudioBuilderProperty(AiHandle *, handle);

@property (nonatomic, copy, readonly) AIKITAudioBuilderProperty(UInt32, bufferSize);

@property (nonatomic, copy, readonly) AIKITAudioBuilderProperty(UInt64, textLength);

@property (nonatomic, copy, readonly) AIKITAudioBuilderProperty(void(^)(int index), progress);

@property (nonatomic, copy, readonly) AIKITAudioBuilderProperty(NSString *, inputKey);

@property (nonatomic, copy, readonly) AIKITAudioBuilderProperty(void(^)(int decibel), decibel);

@property (nonatomic, copy, readonly) AIKITAudioBuilderProperty(void(^)(BOOL successfully), compeletion);

@end

NS_ASSUME_NONNULL_END
