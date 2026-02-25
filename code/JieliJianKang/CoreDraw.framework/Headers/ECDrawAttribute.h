//
//  ECDrawAttribute.h
//  CoreDraw
//
//  Created by EzioChan on 2021/3/30.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ECOrientation_Up,
    ECOrientation_Down,
    ECOrientation_Left,
    ECOrientation_Right
} ECOrientation;

@interface ECDrawAttribute : NSObject


@end

NS_ASSUME_NONNULL_END
