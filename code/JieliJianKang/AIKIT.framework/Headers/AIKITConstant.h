//
//  AEEConstant.h
//  CoreTest
//
//  Created by Jean on 2021/8/24.
//  Copyright © 2021 Jean. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    DATA_TEXT  = 0,
    DATA_AUDIO = 1,
    DATA_IMAGE = 2,
    DATA_VIDEO = 3,
    DATA_PER   = 4
} DATA_TYPE;

typedef enum {
    VAR_STRING  = 0,
    VAR_INT     = 1,
    VAR_DOUBLE  = 2,
    VAR_BOOL    = 3,
    VAR_UNKNOWN = -1
} VAR_TYPE;

@interface AIKITConstant : NSObject

extern NSString *const  EDGE_AI_DATA_KEY;

extern NSString *const  EDGE_AI_DATA;
// 数据状态
extern NSString *const  EDGE_AI_DATA_STATUS;
// 数据类型
extern NSString *const  EDGE_AI_DATA_TYPE;

extern NSString *const  EDGE_AI_DATA_DESC_KEY;

extern NSString *const  EDGE_AI_DATA_DESC;

@end

NS_ASSUME_NONNULL_END
