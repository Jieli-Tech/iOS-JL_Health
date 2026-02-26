//
//  AiHandle.h
//  AEE
//
//  Created by Jean on 2021/8/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AiHandle : NSObject

@property(nonatomic, assign) NSInteger code;
@property(nonatomic, assign) NSInteger hId;
@property(nonatomic, assign) NSInteger i;

- (BOOL)isSuccess;

@end

NS_ASSUME_NONNULL_END
