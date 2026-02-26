//
//  AEEError.h
//  CoreTest
//
//  Created by chun on 2020/9/9.
//  Copyright © 2020 chun. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    EdgeAI_EngineError       = 0,
    EdgeAI_LinceseError      = 1,
    EdgeAI_SDKError          = 2,
    EdgeAI_SysError          = 3,
    EdgeAI_ParamsError       = 4,
    EdgeAI_ProtocolError     = 5,
    EdgeAI_CloudError        = 6,
    EdgeAI_DataAnalysisError = 7,
    EdgeAI_LoadResourceError = 8,
    EdgeAI_ServiceError      = 9,
    EdgeAI_UnknowError       = 10,
    EdgeAI_NoneError         = 11
} AIKITErrorType;
NS_ASSUME_NONNULL_BEGIN

@interface AIKITError : NSObject

@property (nonatomic, assign) int code;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, assign) AIKITErrorType type;


/// 错误码封装转换
/// @param errorCode 错误码
- (void)converterWithError:(int)errorCode;

+ (instancetype)zoneError;

@end

NS_ASSUME_NONNULL_END
