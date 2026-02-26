//
//  AIClound.h
//  JieliJianKang
//
//  Created by 李放 on 2023/7/26.
//

#import <Foundation/Foundation.h>
#import "AICloundMessageModel.h"
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SqlAICloundMessageBlock)(NSArray<AICloundMessageModel *> *chatMessages);


@protocol AICloundDelegate <NSObject>

-(void)deleteLastItem;
-(void)initMyData:(AICloundMessageModel *) aiCloundMessageModel;
-(void)initAIData:(AICloundMessageModel *) aiCloundMessageModel;
-(void)update:(AICloundMessageModel *) aiCloundMessageModel;
@end

@interface AIClound : NSObject

+(id)sharedMe;

- (void)showUI;

- (void)loadMore:(SqlAICloundMessageBlock)block;

-(NSString *)getCurrentTime;

@property (assign, nonatomic) id <AICloundDelegate> aiCloundDelegate;

@end

NS_ASSUME_NONNULL_END
