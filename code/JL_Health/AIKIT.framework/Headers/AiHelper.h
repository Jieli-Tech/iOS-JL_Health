//
//  AiHelper.h
//  AIKIT
//
//  Created by pcfang on 20.3.22.
//

#import <Foundation/Foundation.h>
#import <AIKIT/AIKITError.h>
#import <AIKIT/AIKITDataModel.h>
#import <AIKIT/AiHandle.h>
#import <AIKIT/AiAudioDefine.h>
#import <AIKIT/SparkDefine.h>
#import <AIKIT/ChatParam.h>
#import <AIKIT/AIKITUsrContext.h>


#define AIKITDEPRECATED(msg) __attribute__((deprecated(msg)))

typedef NS_ENUM(NSInteger, AIKIT_EVENT_IOS) {
    AIKIT_EVENT_UNKNOWN  = 0,
    AIKIT_EVENT_START    = 1,
    AIKIT_EVENT_END      = 2,
    AIKIT_EVENT_TIMEOUT  = 3,
    AIKIT_EVENT_PROGRESS = 4
};

typedef enum _AIKITLogLvl {
    AIKITLogVerbose = 0,
    AIKITLogDebug   = 1,
    AIKITLogInfo    = 2,
    AIKITLogWarn    = 3,
    AIKITLogError   = 4,
    AIKITLogFatal   = 5,
    AIKITLogOff     = 100
} AIKITLogLvl;

@class AIKITInputData;
@class AIKITCustomData;
@class AIKITParameters;
@class AIKITUserContext;
@class AIKITCtxContent;
@class AiHelperMaker;
@class AIKITAudioBuilder;


NS_ASSUME_NONNULL_BEGIN

@protocol AIKitCoreDelegate<NSObject>
@optional
- (void)aikitOnResult:(NSString*)ability outputData:(NSArray<AIKITDataModel*>*)data usrCtx:(AIKITUserContext*)context AIKITDEPRECATED("use aikitOnResult:handleId:outputData:usrCtx instead");

- (void)aikitOnEvent:(NSString*)ability event:(NSInteger)event eventData:(NSArray<AIKITDataModel*>*)data usrCtx:(AIKITUserContext*)context AIKITDEPRECATED("use -aikitOnEvent:handleId:event:eventData:usrCtx instead");

- (void)aikitOnError:(NSString*)ability error:(AIKITError*)error usrCtx:(AIKITUserContext*)context AIKITDEPRECATED("use aikitOnError:handleId:error:usrCtx instead");

- (void)aikitOnResult:(NSString *)ability
             handleId:(NSInteger)handleId
           outputData:(NSArray<AIKITDataModel *> *)data
               usrCtx:(AIKITCtxContent *)context;

- (void)aikitOnEvent:(NSString *)ability
            handleId:(NSInteger)handleId
               event:(NSInteger)event
           eventData:(NSArray<AIKITDataModel *> *)data
              usrCtx:(AIKITCtxContent *)context;

- (void)aikitOnError:(NSString*)ability
            handleId:(NSInteger)handleId
               error:(AIKITError*)error
              usrCtx:(AIKITCtxContent*)context;
@end



@interface AiHelper : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)shareInstance;

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSMapTable* multiDelegates;

///  SDK初始化
/// - Parameter block: 参数回调
+ (int)initSDK:(void(^)(AiHelperMaker *maker))block;

/// SDK逆初始化
+ (int)unInit;


+ (int)initEngine:(NSString*)ability param:(nullable AIKITParameters*)param;

+ (int)oneShot:(NSString*)ability param:(AIKITParameters*)param data:(AIKITInputData*)data ctxContent:(nullable AIKITCtxContent*)content;

+ (int)loadData:(NSString*)ability data:(AIKITCustomData*)data;

+ (int)unloadData:(NSString *)ability key:(NSString *)key index:(int)index;

+ (int)preProcess:(NSString*)ability data:(AIKITCustomData*)data;

+ (AiHandle*)start:(NSString*)ability param:(nullable AIKITParameters*)param ctxContent:(nullable AIKITCtxContent*)content;

+ (int)write:(nullable AIKITInputData*)data handle:(nonnull AiHandle*)handle;

+ (int)setLogInfo:(AIKITLogLvl)level mode:(NSInteger)mode path:(NSString*)path;

+ (int)specifyDataSet:(NSString*)ability key:(NSString*)key indexs:(nonnull int[])indexs count:(int)count;

+ (int)read:(nonnull AiHandle*)handle;

+ (int)end:(nonnull AiHandle*)handle;

+ (int)setConfig:(nonnull NSString *)key value:(nonnull NSString *)value;

+ (int)setConfig:(NSString *)key anyValue:(nonnull void *)value;

+ (int)getAbility:(nonnull NSString *)abilityId authLeftTime:(int64_t *)leftTime endTime:(int64_t *)endTime;

+ (int)freeAbility:(nonnull NSString *)abilityId;

+ (int)registerAppCallback:(id<AIKitCoreDelegate>)callback;

+ (int)registerAbilityCallback:(NSString*)abilityId callback:(id<AIKitCoreDelegate>)callback;

/// 注册星火回调
/// - Parameter callback: 回调
+ (int)registerChatCallback:(id<AIKITSparkDelegate>)callback;


/// 星火异步会话
/// - Parameters:
///   - param: 会话参数
///   - inputText: 文本
///   - context: 用户自定义
+ (int)asyncChat:(ChatParam *) param inputText:(NSString *)inputText usrContext:(nullable AIKITUsrContext *)context;
#pragma mark - Audio recorder

/// 开始录音
/// @param builder 构造器
+ (void)record:(nonnull AIKITAudioBuilder *)builder;

/// 是否正在录音
+ (BOOL)isRecording;

#pragma mark - Audio Codec

/// 音频编解码
/// @param inPath 音频输入路径
/// @param outPath 音频输出路径
/// @param audioType 输入/输出音频格式(encode为输出音频格式，decode为输入音频格式)
/// @param codecType 编码/解码
+ (int)codeC:(NSString *)inPath outPath:(NSString *)outPath audioType:(AudioType)audioType codecType:(AudioCodecType)codecType;

/// 音频编解码
/// @param inPath 音频输入路径
/// @param outPath 音频输出路径
/// @param audioType 输入/输出音频格式(encode为输出音频格式，decode为输入音频格式)
/// @param codecType 编码/解码
/// @param sampleRate  输出音频采样率
+ (int)codeC:(NSString *)inPath outPath:(NSString *)outPath audioType:(AudioType)audioType codecType:(AudioCodecType)codecType
  sampleRate:(uint32_t)sampleRate;

#pragma mark - Audio Player

/// 开始播放
/// @param builder 播放器参数构造
+ (int)startPlay:(AIKITAudioBuilder *)builder;

/// 暂停播放
+ (int)pausePlay;

/// 继续播放
+ (int)resumePlay;

/// 停止播放
+ (int)stopPlay;

+ (BOOL)isPlaying;

+ (BOOL)isPaused;

/// 写入音频数据
/// @param data 音频数据
+ (void)writeAudioData:(NSData *)data;

/// 写入音频完毕
+ (void)endAudioWrite;

@end

NS_ASSUME_NONNULL_END
