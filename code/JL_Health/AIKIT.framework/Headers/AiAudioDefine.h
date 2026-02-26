//
//  AiAudioDefine.h
//  Record
//
//  Created by pcfang on 8.3.22.
//

#ifndef AiAudioDefine_h
#define AiAudioDefine_h

#import <AVFoundation/AVFoundation.h>

// 采样率
typedef enum : uint32_t {
    AudioSampleRate8K = 8000,
    AudioSampleRate12K = 12000,
    AudioSampleRate16K = 16000,
    AudioSampleRate24K = 24000,
    AudioSampleRate32K = 32000
} AudioSampleRate;

// 声道
typedef enum : UInt32 {
    AudioChannelMono = 1,
    AudioChannelStereo = 2
} AudioChannels;

// PCM每个采样数据的大小
typedef enum : UInt32 {
    AudioLinearPCMBitDepth8 = 8,
    AudioLinearPCMBitDepth16 = 16,
    AudioLinearPCMBitDepth24 = 24,
    AudioLinearPCMBitDepth32 = 32
} AudioLinearPCMBitDepth;

typedef NSString* AudioType NS_STRING_ENUM;
FOUNDATION_EXTERN AudioType const AudioTypePCM;
FOUNDATION_EXTERN AudioType const AudioTypeMP3;
FOUNDATION_EXTERN AudioType const AudioTypeWAV;
FOUNDATION_EXTERN AudioType const AudioTypeAAC;

typedef enum : NSUInteger {
    AudioCodecTypeEncode = 0,
    AudioCodecTypeDecode
} AudioCodecType;

#endif /* AiAudioDefine_h */
