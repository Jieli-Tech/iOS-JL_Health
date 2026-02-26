//
//  AIChat.h
//  AIKIT
//
//  Created by pcfang on 5.5.23.
//

#import <Foundation/Foundation.h>
#import "SparkDefine.h"
@class AIKITUsrContext;

@class  ChatParam;

NS_ASSUME_NONNULL_BEGIN

@interface AIKITSpark : NSObject

@property (nonatomic, weak, readonly) id <AIKITSparkDelegate> delegate;

- (instancetype)initWithDelegate:(id<AIKITSparkDelegate>)delegate;

- (int)asyncChat:(ChatParam *)config inputText:(NSString *) inputText usrContext:(AIKITUsrContext * _Nullable)usrctx;
@end

NS_ASSUME_NONNULL_END
