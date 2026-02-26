//
//  ILibrary.h
//  AEE
//
//  Created by Jean on 2021/9/1.
//

#import <Foundation/Foundation.h>
#import "AiHelperMaker.h"

NS_ASSUME_NONNULL_BEGIN

@interface ILibrary : NSObject

+ (int)initSDK:(void(^)(AiHelperMaker *maker))block;

+ (int)unInit;

@end

NS_ASSUME_NONNULL_END
