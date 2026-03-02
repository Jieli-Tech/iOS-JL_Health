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
    JLBmpConvertOption *option = [[JLBmpConvertOption alloc] init];
    option.convertType = JLBmpConvertType701N_ARBG;
    JLImageConvertResult *convertResult = [JLBmpConvert convert:option ImageData:imageData];
    
}

-(void)getSize{
    JL_ManagerM *mCmdManager = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    [mCmdManager.mFlashManager cmdFlashLeftSizeResult:^(uint32_t leftSize) {
        long long freeSize = (long long)leftSize*1024;
    }];
    
}

@end
