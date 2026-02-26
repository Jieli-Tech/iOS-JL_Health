//
//  AiHelperMaker.h
//  AEE
//
//  Created by Jean on 2021/8/19.
//

#import <Foundation/Foundation.h>

@interface AiHelperMaker : NSObject

@property(nonatomic, copy) NSString *appIdValue;
@property(nonatomic, copy) NSString *apiKeyValue;
@property(nonatomic, copy) NSString *apiSecretValue;
@property(nonatomic, copy) NSString *batchIdValue;
@property(nonatomic, copy) NSString *customDeviceIdValue;
@property(nonatomic, copy) NSString *userDeviceIdValue;
@property(nonatomic, copy) NSString *licenseFileValue;
@property(nonatomic, assign) NSInteger authIntervalValue;
@property(nonatomic, assign) NSInteger iLogMaxCountValue;
@property(nonatomic, assign) NSInteger iLogMaxSizeValue;
@property(nonatomic, assign) NSInteger authTypeValue;
@property(nonatomic, assign) BOOL logOpenValue;
@property(nonatomic, assign) BOOL iLogOpenValue;
@property(nonatomic, copy) NSString * workDirValue;
@property(nonatomic, copy) NSString * resDirValue;
@property(nonatomic, copy) NSString * abilityValue;
@property(nonatomic, copy) NSString * channelIDValue;

@property(nonatomic, copy) AiHelperMaker *(^appId)(NSString *appId);
@property(nonatomic, copy) AiHelperMaker *(^apiKey)(NSString *apiKey);
@property(nonatomic, copy) AiHelperMaker *(^apiSecret)(NSString *apiSecret);
@property(nonatomic, copy) AiHelperMaker *(^licenseFile)(NSString *licenseFile);
@property(nonatomic, copy) AiHelperMaker *(^batchId)(NSString *batchId);
@property(nonatomic, copy) AiHelperMaker *(^customDeviceId)(NSString *customDeviceId);
@property(nonatomic, copy) AiHelperMaker *(^userDeviceId)(NSString *userDeviceId);
@property(nonatomic, copy) AiHelperMaker *(^authInterval)(NSInteger authInterval);
@property(nonatomic, copy) AiHelperMaker *(^iLogMaxCount)(NSInteger iLogMaxCount);
@property(nonatomic, copy) AiHelperMaker *(^iLogMaxSize)(NSInteger iLogMaxSize);
@property(nonatomic, copy) AiHelperMaker *(^authType)(NSInteger authType);
@property(nonatomic, copy) AiHelperMaker *(^iLogOpen)(BOOL iLogOpen);
@property(nonatomic, copy) AiHelperMaker *(^logOpen)(BOOL logOpen);
@property(nonatomic, copy) AiHelperMaker *(^workDir)(NSString * workDir);
@property(nonatomic, copy) AiHelperMaker *(^resDir)(NSString * resDir);
@property(nonatomic, copy) AiHelperMaker *(^ability)(NSString * ability);
@property(nonatomic, copy) AiHelperMaker *(^channelID)(NSString * channelID);
@end

