//
//  JLFileTransferHelper.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/7/15.
//

#import <Foundation/Foundation.h>
#import "JLHeadFile.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JLFileTransferOperateType) {
    JLFileTransferOperateTypeNoSpace     = 0,    //空间不足
    JLFileTransferOperateTypeStart       = 1,    //开始操作
    JLFileTransferOperateTypeDoing       = 2,    //正在操作
    JLFileTransferOperateTypeFail        = 3,    //操作失败
    JLFileTransferOperateTypeSuccess     = 4,    //操作成功
    JLFileTransferOperateTypeUnnecessary = 5,    //无需重复打开文件系统
};

typedef void(^JLFileTransferBK)(JLFileTransferOperateType type, float progress);

@interface JLFileTransferHelper : NSObject

/**
 *  发送联系人文件到flash
 */
+ (void)sendContactFileToFlashWithFileName:(NSString* )fileName
                               withManager:(JL_ManagerM*)manager
                                withResult:(JLFileTransferBK)result;

/**
 *  发送联系人文件到SD卡
 */
+ (void)sendContactFileWithFileName:(NSString* )fileName
                        withManager:(JL_ManagerM*)manager
                         withResult:(JLFileTransferBK)result;
/**
 *  获取音乐文件传输句柄
 */
+ (JL_FileHandleType)getMusicTargetDev:(JLModel_Device*)deviceModel;

/**
 *  获取常用联系人传输句柄
 */
+ (JL_FileHandleType)getContactTargetDev:(JLModel_Device*)deviceModel;

@end

NS_ASSUME_NONNULL_END
