//
//  AEECtxContent.h
//  AEE
//
//  Created by Jean on 2021/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AIKITCtxContent : NSObject

@property(nonatomic, copy) NSString *ctxName;

@property(nonatomic, assign) NSInteger ctxId;

@property(nonatomic, strong) NSDictionary * userInfo;

@end

NS_ASSUME_NONNULL_END
