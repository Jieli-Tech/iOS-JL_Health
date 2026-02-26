//
//  AEEInputData.h
//  EdgeAISDK
//
//  Created by chun on 2020/10/23.
//  Copyright © 2020 chun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIKITDataBuilder.h"
@class AIKITParameters;

#define AIKitInputDataChainProperty(name,valueType) property (nonatomic, copy, readonly) AIKITInputData * (^name)(NSString * , valueType,DataStatus)

typedef enum _DataStatus {
    DataStatusBegin  = 0,
    DataStatusContinue,
    DataStatusEnd,
    DataStatusOnce
} DataStatus;

@class AIKITDataModel;
NS_ASSUME_NONNULL_BEGIN

@interface AIKITInputData : NSObject

- (void)addText:(NSString*)text key:(NSString*)key status:(DataStatus)status;

- (void)addTextData:(NSData*)data key:(NSString*)key status:(DataStatus)status;

- (void)addTextPath:(NSString*)path key:(NSString*)key status:(DataStatus)status;

- (void)addImage:(NSData*)image key:(NSString*)key status:(DataStatus)status;

- (void)addImagePath:(NSString*)path key:(NSString*)key status:(DataStatus)status;

- (void)addVideo:(NSData*)video key:(NSString*)key status:(DataStatus)status;

- (void)addVideoPath:(NSString*)path key:(NSString*)key status:(DataStatus)staus;

- (void)addAudio:(NSData*)audio key:(NSString*)key status:(DataStatus)status;

- (void)addAudioPath:(NSString*)path key:(NSString*)key status:(DataStatus)status;

- (void)addDesc:(NSString *)key param:(AIKITParameters *)param;

- (void *)getDataBuilder;

- (instancetype)addPayload:(id<AIData>)aiData;

#pragma mark - chain's invoke
@property(nonatomic,copy,readonly,class)AIKITInputData * (^instance)(void);
@property(nonatomic,copy,readonly)AIKITInputData * (^desc)(NSString * key, AIKITParameters * param);
@property(nonatomic,copy,readonly)AIKITInputData * (^payload)(id<AIData>);
@AIKitInputDataChainProperty(text, NSString *);
@AIKitInputDataChainProperty(textData, NSData *);
@AIKitInputDataChainProperty(textPath, NSString *);
@AIKitInputDataChainProperty(image, NSData *);
@AIKitInputDataChainProperty(imagePath, NSString *);
@AIKitInputDataChainProperty(video, NSData *);
@AIKitInputDataChainProperty(videoPath, NSString *);
@AIKitInputDataChainProperty(audio, NSData *);
@AIKitInputDataChainProperty(audioPath, NSString *);

@end

NS_ASSUME_NONNULL_END
