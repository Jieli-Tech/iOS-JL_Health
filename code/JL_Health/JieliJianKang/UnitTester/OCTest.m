//
//  OCTest.m
//  JieliJianKang
//
//  Created by EzioChan on 2023/12/15.
//

#import "OCTest.h"

@implementation OCTest

+(void)makeDialwithName:(NSString *)watchBinName withSize:(CGSize)size image:(UIImage *)basicImage{
    
    NSData *imageData = [JLBmpConvert resizeImage:basicImage andResizeTo:CGSizeMake(size.width, size.height)];
    UIImage *image = [UIImage imageWithData:imageData];
    
    NSString *imagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    imagePath = [imagePath stringByAppendingPathComponent:@"basic.png"];
    [JL_Tools writeData:imageData fillFile:imagePath];
    
    //带有alpha的图片转换，方式一
    [JLBmpConvert covert:JLBmpConvertType701N_ARBG Image:image completion:^(NSData * _Nullable outFileData, NSError * _Nullable error) {
        if (error) {
            kJLLog(JLLOG_DEBUG, @"--->PNG BIN【%@】is Error!", watchBinName);
            return;
        }
        kJLLog(JLLOG_DEBUG, @"--->PNG BIN【%@】is OK!", watchBinName);
    }];
    
    //带有有alpha的图片转换，方式二
    //这里的 outFilePath 是可选项，如果需要指定输出路径可以设置
    [JLBmpConvert covert:JLBmpConvertType701N_ARBG inFilePath:imagePath outFilePath:nil completion:^(NSString * _Nonnull inFilePath, NSString * _Nullable outFilePath, NSError * _Nullable error) {
       if (error) {
           kJLLog(JLLOG_DEBUG, @"--->PNG BIN【%@】is Error!", watchBinName);
           return;
       }
       kJLLog(JLLOG_DEBUG, @"--->PNG BIN【%@】is OK!", watchBinName);
    }];
    
}

-(void)getSize{
    JL_ManagerM *mCmdManager = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    [mCmdManager.mFlashManager cmdFlashLeftSizeResult:^(uint32_t leftSize) {
        long long freeSize = (long long)leftSize*1024;
    }];
    
}

@end
