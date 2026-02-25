//
//  JLFileTransferHelper.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/7/15.
//

#import "JLFileTransferHelper.h"

@implementation JLFileTransferHelper

/**
 *  发送联系人文件到flash
 */
+ (void)sendContactFileToFlashWithFileName:(NSString* )fileName
                               withManager:(JL_ManagerM*)manager
                                withResult:(JLFileTransferBK)result {
    
    if (fileName.length < 1 || !fileName) {
        return;
    }
    
    NSString *filePath = [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:fileName];
    
    [JL_Tools subTask:^{
        
        __block uint8_t m_flag = 0;
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        [manager.mFlashManager cmdInsertFlashPath:fileName Size:(uint32_t)fileData.length
                                   Flag:JL_FlashOperateFlagStart Result:^(uint8_t flag) {
            m_flag = flag;
        }];
        if (m_flag != 0) {
            NSLog(@"--->insertFileNameForFlashWithFilePath Insert Fail.");
            [JL_Tools mainTask:^{
                if (result) { result(JLFileTransferOperateTypeFail, 0.0); }
            }];
        } else {
            [self sendContactFileWithFileName:fileName withManager:manager withResult:result];
        }
    }];
}

/**
 *  发送联系人文件到SD卡
 */
+ (void)sendContactFileWithFileName:(NSString* )fileName
                        withManager:(JL_ManagerM*)manager
                         withResult:(JLFileTransferBK)result {
    
    if (fileName.length < 1 || !fileName) {
        return;
    }
    
    JLFileTransferBK result_bk = result;
    
    JLModel_Device *deviceModel = [manager outputDeviceModel];
    
    [manager.mFileManager setCurrentFileHandleType:[JLFileTransferHelper getContactTargetDev:deviceModel]];
    [manager.mFileManager cmdPreEnvironment:0x00 Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
        JL_CMDStatus st = status;
        if (st == JL_CMDStatusSuccess) {
            NSString *path = [JL_Tools findPath:NSLibraryDirectory MiddlePath:@"" File:fileName];
            [manager.mFileManager cmdFileDeleteWithName:fileName Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                JL_CMDStatus st = status;
                if (st == JL_CMDStatusSuccess) {
                    [manager.mFileManager cmdBigFileData:path WithFileName:fileName Result:^(JL_BigFileResult result, float progress) {
                        [JL_Tools mainTask:^{
                            if (result == JL_BigFileTransferOutOfRange || result == JL_BigFileTransferFail || result == JL_BigFileCrcError || result == JL_BigFileTransferNoResponse) {
                                if (result_bk) { result_bk(JLFileTransferOperateTypeFail, 0.0); }
                            }
                            if (result == JL_BigFileTransferStart) {
                                if (result_bk) { result_bk(JLFileTransferOperateTypeStart, 0.0); }
                            }
                            if (result == JL_BigFileTransferDownload) {
                                NSLog(@"---> Progress: %.2f【%d】",progress,result);
                                if (result_bk) { result_bk(JLFileTransferOperateTypeDoing, progress); }
                            }
                            if (result == JL_BigFileTransferEnd) {
                                if (result_bk) { result_bk(JLFileTransferOperateTypeSuccess, 1.0); }
                            }
                        }];
                    }];
                } else {
                    [JL_Tools mainTask:^{
                        if (result_bk) { result_bk(JLFileTransferOperateTypeFail, 0.0);}
                    }];
                }
            }];
        } else {
            [JL_Tools mainTask:^{
                if (result_bk) { result_bk(JLFileTransferOperateTypeFail, 0.0);}
            }];
        }
    }];
}

/**
 *  获取音乐文件传输句柄
 */
+ (JL_FileHandleType)getMusicTargetDev:(JLModel_Device*)deviceModel {

    if ([deviceModel.cardArray containsObject:@(JL_CardTypeSD_1)]) {
        return JL_FileHandleTypeSD_1;
    } else if ([deviceModel.cardArray containsObject:@(JL_CardTypeSD_0)] && [deviceModel.cardArray containsObject:@(JL_CardTypeSD_1)]) {
        return JL_FileHandleTypeSD_1;
    } else if ([deviceModel.cardArray containsObject:@(JL_CardTypeSD_0)]) {
        return JL_FileHandleTypeSD_0;
    } else if ([deviceModel.cardArray containsObject:@(JL_CardTypeUSB)]) {
        return JL_FileHandleTypeUSB;
    }
    return JL_FileHandleTypeSD_1;
}

/**
 *  获取常用联系人传输句柄
 */
+ (JL_FileHandleType)getContactTargetDev:(JLModel_Device*)deviceModel {

    if ([deviceModel.cardArray containsObject:@(JL_CardTypeFLASH2)]) {
        return JL_FileHandleTypeFLASH2;
    } else if ([deviceModel.cardArray containsObject:@(JL_CardTypeSD_1)]) {
        return JL_FileHandleTypeSD_1;
    } else if ([deviceModel.cardArray containsObject:@(JL_CardTypeSD_0)] && [deviceModel.cardArray containsObject:@(JL_CardTypeSD_1)]) {
        return JL_FileHandleTypeSD_1;
    } else if ([deviceModel.cardArray containsObject:@(JL_CardTypeSD_0)]) {
        return JL_FileHandleTypeSD_0;
    } else if ([deviceModel.cardArray containsObject:@(JL_CardTypeUSB)]) {
        return JL_FileHandleTypeUSB;
    }
    return JL_FileHandleTypeSD_1;
}


@end
