//
//  ContactsTool.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/23.
//  Modify by EzioChan 2024/2/20
//

#import "ContactsTool.h"
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"
#import "JLFileTransferHelper.h"

@interface ContactsTool (){
    JL_Timer *threadTimer_1;
}
@end
@implementation ContactsTool

#pragma mark 设置联系人列表为Data
+ (NSData *)setContactsToData:(NSMutableArray *)array {
    NSMutableData *data = [NSMutableData new];
    for (JHPersonModel *model in array) {
        NSString *name;
        NSArray *titleTextLengthArray = [self unicodeLengthOfString:model.fullName];
        if ([[titleTextLengthArray firstObject] integerValue] > 7) {
            NSInteger maxMumLength = [[titleTextLengthArray lastObject] integerValue];
            model.fullName = [model.fullName stringByReplacingCharactersInRange:NSMakeRange(maxMumLength, model.fullName.length-maxMumLength) withString:@""];
        }
        if (model.fullName.length < 20) {
            name = [self CharacterStringMainString:model.fullName addDigit:20 addString:@"\0"];
        } else {
            name = model.fullName;
        }
        name = [name stringByReplacingOccurrencesOfString:@"<0>"withString:@""];
        name = [name stringByReplacingOccurrencesOfString:@"<0" withString:@""];
        name = [name stringByReplacingOccurrencesOfString:@"0>" withString:@""];
        name = [name stringByReplacingOccurrencesOfString:@"<" withString:@""];
        name = [name stringByReplacingOccurrencesOfString:@">" withString:@""];
        //        NSString *name = [self removeMoreString:model.fullName];
        NSData *nameData = [name dataUsingEncoding:NSUTF8StringEncoding];
        NSData *changeNameData = [JL_Tools data:nameData R:0 L:20];
        [data appendData:changeNameData];
        
        NSString *phoneNum;
        if (model.phoneNum.length < 20) {
            phoneNum = [self CharacterStringMainString:model.phoneNum addDigit:20 addString:@"\0"];
        } else {
            phoneNum = model.phoneNum;
        }
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"<0>"withString:@""];
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"<0" withString:@""];
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"<"withString:@""];
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@">"withString:@""];
        //        NSString *phoneNum = [self removeMoreString:model.phoneNum];
        NSData *phoneNumData = [phoneNum dataUsingEncoding:NSUTF8StringEncoding];
        NSData *changePhoneNumData = [JL_Tools data:phoneNumData R:0 L:20];
        [data appendData:changePhoneNumData];
    }
    return data;
}

+ (NSString *)removeMoreString:(NSString *)text {
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    while (data.length > 19) {
        text = [text substringWithRange:NSMakeRange(0, text.length - 1)];
        data = [text dataUsingEncoding:NSUTF8StringEncoding];
    }
    return text;
}

#pragma mark字符串自动补充方法

+ (NSString*)CharacterStringMainString:(NSString*)MainString addDigit:(int)AddDigit addString:(NSString*)AddString {
    NSString *ret = [[NSString alloc]init];
    ret = MainString;
    for (int y = 0; y < (AddDigit - MainString.length); y++) {
        ret = [NSString stringWithFormat:@"%@%@%@%@", ret, @"<", AddString, @">"];
    }
    return ret;
}

+ (NSMutableArray *)unicodeLengthOfString:(NSString *)text {
    NSMutableArray *array = [NSMutableArray array];
    float asciiLength = 0;
    NSInteger maxmumShowIndex  = 0;
    for (NSUInteger i = 0; i < text.length; i++) {
        unichar uc = [text characterAtIndex: i];
        if (isalnum(uc)) {
            asciiLength += 1.1;
        } else {
            asciiLength += isascii(uc) ? 1 : 2;
        }
        //计算可以显示的最大字数的Index位置
        if (asciiLength / 2 < 8) {
            maxmumShowIndex =i;
        }
    }
    //所有的字数
    NSUInteger unicodeLength = asciiLength / 2;
    
    if((NSInteger)asciiLength % 2) {
        unicodeLength++;
    }
    
    [array addObject:[NSNumber numberWithInteger:unicodeLength]];
    [array addObject:[NSNumber numberWithInteger:maxmumShowIndex]];
    return array;
}


//MARK: - 单例实例方法
+ (instancetype)share{
    static ContactsTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [ContactsTool new];
    });
    return tool;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        threadTimer_1 = [[JL_Timer alloc]init];
    }
    return self;
}

-(void)syncContactsListWithPath:(NSString*)path Result:(EcSyncCallBlock)block{
    
    if (kJL_BLE_CmdManager == nil) return;
    JLModel_Device *modelDevice = [kJL_BLE_CmdManager outputDeviceModel];
    [JLUI_Effect startLoadingView:kJL_TXT("同步中...") Delay:8.0];
    if (modelDevice.smallFileWayType == JL_SmallFileWayTypeNO) {
        /*--- 原来通讯流程 ---*/
        if ([JLFileTransferHelper getContactTargetDev] == JL_CardTypeFLASH2) {
            [JLFileTransferHelper sendContactFileToFlashWithFileName:@"CALL.TXT"
                                                          withResult:^(JLFileTransferOperateType type,
                                                                       float progress) {
                if (type == JLFileTransferOperateTypeStart) {
                    [JLUI_Effect startLoadingView:kJL_TXT("同步中...") Delay:8.0];
                }
                if (type == JLFileTransferOperateTypeSuccess) {
                    [JLUI_Effect setLoadingText:kJL_TXT("同步完成！") Delay:0.5f];
                    block(true);
                }
            }];
        } else {
            [JLFileTransferHelper sendContactFileWithFileName:@"CALL.TXT"
                                                   withResult:^(JLFileTransferOperateType type,
                                                                float progress) {
                if (type == JLFileTransferOperateTypeStart) {
                    [JLUI_Effect startLoadingView:kJL_TXT("同步中...") Delay:8.0];
                }
                if (type == JLFileTransferOperateTypeSuccess) {
                    [JLUI_Effect setLoadingText:kJL_TXT("同步完成！") Delay:0.5f];
                    block(true);
                }
            }];
        }
    }else{
        /*--- 小文件方式传输通讯录 ---*/
        [JL_Tools subTask:^{
            __block JLModel_SmallFile *smallFile = nil;
            
            /*--- 查询小文件列表 ---*/
            [kJL_BLE_CmdManager.mSmallFileManager cmdSmallFileQueryType:JL_SmallFileTypeContacts
                                                                 Result:^(NSArray<JLModel_SmallFile *> * _Nullable array) {
                if (array.count > 0) smallFile = array[0];
                [self->threadTimer_1 threadContinue];
            }];
            [self->threadTimer_1 threadWait];
            
            
            /*--- 先删通讯录 ---*/
            if (smallFile != nil) {
                __block JL_SmallFileOperate status_del = 0;
                [kJL_BLE_CmdManager.mSmallFileManager cmdSmallFileDelete:smallFile
                                                                  Result:^(JL_SmallFileOperate status) {
                    status_del = status;
                    [self->threadTimer_1 threadContinue];
                }];
                [self->threadTimer_1 threadWait];
                
                if (status_del != JL_SmallFileOperateSuceess) {
                    [JL_Tools mainTask:^{
                        NSLog(@"--->小文件 CALL.TXT 传输失败 %s,%d",__func__,__LINE__);
                        [JLUI_Effect setLoadingText:kJL_TXT("同步失败！") Delay:0.5f];
                    }];
                    return;
                }
            }
            
            /*--- 小文件传输文件 ---*/
            NSData *pathData = [NSData dataWithContentsOfFile:path];
            [kJL_BLE_CmdManager.mSmallFileManager cmdSmallFileNew:pathData Type:JL_SmallFileTypeContacts
                                                           Result:^(JL_SmallFileOperate status, float progress,
                                                                    uint16_t fileID) {
                [JL_Tools mainTask:^{
                    if (status == JL_SmallFileOperateSuceess) {
                        NSLog(@"--->小文件 CALL.TXT 传输成功 %s,%d",__func__,__LINE__);
                        [JLUI_Effect setLoadingText:kJL_TXT("同步完成！") Delay:0.5f];
                        
                        block(true);
                        return;
                    }
                    if (status != JL_SmallFileOperateSuceess &&
                        status != JL_SmallFileOperateDoing){
                        NSLog(@"--->小文件 CALL.TXT 传输失败 %s,%d",__func__,__LINE__);
                        [JLUI_Effect setLoadingText:kJL_TXT("同步失败！") Delay:0.5f];
                        block(false);
                    }
                }];
            }];
        }];
    }
}
@end
