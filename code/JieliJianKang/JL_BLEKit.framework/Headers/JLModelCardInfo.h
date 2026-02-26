//
//  JLModelCardInfo.h
//  JL_BLEKit
//
//  Created by EzioChan on 2023/11/30.
//  Copyright © 2023 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// 存储卡信息
@interface JLModelCardInfo:NSObject

/// 版本信息
@property(nonatomic,assign)uint8_t version;

/// 存储卡在线数组
@property(nonatomic,strong,readonly)NSArray *cardArray;

/// USB 在线状态
@property (nonatomic, assign) BOOL usbOnline;

/// SD0 在线状态
@property (nonatomic, assign) BOOL sd0Online;

/// SD1 在线状态
@property (nonatomic, assign) BOOL sd1Online;

/// lineIn 在线状态
@property (nonatomic, assign) BOOL lineInOnline;

/// flash 在线状态
@property (nonatomic, assign) BOOL flashOnline;

/// flash 2 在线状态
@property (nonatomic, assign) BOOL flash2Online;

/// flash 3 在线状态
@property (nonatomic, assign) BOOL flash3Online;

/// 是否处于设备复用状态
@property (nonatomic, assign) BOOL isComplex;

/// USB 句柄
@property (nonatomic, copy)NSData *usbHandle;

/// SD0 句柄
@property (nonatomic, copy)NSData *sd0Handle;

/// SD1 句柄
@property (nonatomic, copy)NSData *sd1Handle;

/// flash 句柄
@property (nonatomic, copy)NSData *flashHandle;

/// flash2 句柄
@property (nonatomic, copy)NSData *flash2Handle;

/// flash3 句柄
@property (nonatomic, copy)NSData *flash3Handle;

-(instancetype)initData:(NSData *)data;

@end


NS_ASSUME_NONNULL_END
