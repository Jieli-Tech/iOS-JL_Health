//
//  AEEParameters.h
//  EdgeAISDK
//
//  Created by chun on 2020/10/21.
//  Copyright © 2020 chun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

#define AIKitParametersChainProperty(name,valueType) property (nonatomic, copy, readonly) AIKITParameters * (^name)(NSString * _Nonnull key, valueType value)

@interface AIKITParameters : NSObject

- (void)addInt:(nonnull NSString*)key value:(int)value;

- (void)addDouble:(nonnull NSString*)key value:(double)value;

- (void)addString:(nonnull NSString*)key value:(nonnull NSString*)value;

- (void)addBool:(nonnull NSString*)key value:(bool)value;

// value strong refrence, thread unsafe
- (void)addParam:(nonnull NSString *)key value:(AIKITParameters *)value;

- (void)addHeader;

- (void)addService:(nonnull NSString *) serviceID;

- (void *)getParamBulider;


#pragma mark - chain's invoke
@property (nonatomic,copy,readonly,class) AIKITParameters * (^instance)(void);
@property (nonatomic,copy,readonly) AIKITParameters * (^header)(void);
@property (nonatomic,copy,readonly) AIKITParameters * (^service)(NSString * _Nonnull serviceID);

@AIKitParametersChainProperty(addInt,int);
@AIKitParametersChainProperty(addDouble,double);
@AIKitParametersChainProperty(addString, NSString * _Nonnull);
@AIKitParametersChainProperty(addBool, bool);
@AIKitParametersChainProperty(addParam, AIKITParameters *);

@end

NS_ASSUME_NONNULL_END
