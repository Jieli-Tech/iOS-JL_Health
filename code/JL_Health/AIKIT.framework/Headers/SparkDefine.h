//
//  ChatDefine.h
//  AIKIT
//
//  Created by pcfang on 5.5.23.
//

#ifndef ChatDefine_h
#define ChatDefine_h
@class AIKITUsrContext;

@protocol AIKITSparkDelegate <NSObject>

- (void)onChatOutput:(NSUInteger)handleId
                role:(NSString *)role
             content:(NSString *)content
               index:(int)index
         userContext:(AIKITUsrContext *)usrctx;

- (void)onChatToken:(NSUInteger)handleId
         completion:(int)completionTokens
             prompt:(int)promptTokens
              total:(int)totalTokens
        userContext:(AIKITUsrContext *)usrctx;

- (void)onChatError:(NSUInteger)handleId
              errNo:(int)errNo
               desc:(NSString *)errDesc
        userContext:(AIKITUsrContext *)usrctx;

@end

#endif /* ChatDefine_h */
