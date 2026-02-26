//
//  OCTest.m
//  JieliJianKang
//
//  Created by EzioChan on 2023/12/15.
//

#import "OCTest.h"

@implementation OCTest

+(NSString *)makeDialwithName:(NSString *)watchBinName withSize:(CGSize)size image:(UIImage *)basicImage{
    
//    NSData *imageData0 = UIImageJPEGRepresentation(basicImage, 1.0f);
//    UIImage *img = [UIImage imageWithData:imageData0];
    NSData *imageData = [BitmapTool resizeImage:basicImage andResizeTo:CGSizeMake(size.width, size.height)];
    
    
    NSString *bmpPath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:@"ios_test.bmp"];
    NSString *binPath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:watchBinName];
    
    [JL_Tools removePath:bmpPath];
    [JL_Tools removePath:binPath];
    
    [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:@"ios_test.bmp"];
    [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:watchBinName];
    
    UIImage *image = [UIImage imageWithData:imageData];
    int width = size.width;
    int height = size.height;
    NSLog(@"压缩分辨率 ---> w:%df h:%df",width,height);
    
    NSData *bitmap = [BitmapTool convert_B_G_R_A_BytesFromImage:image];
    [JL_Tools writeData:bitmap fillFile:bmpPath];
    
    
    //带有alpha的图片转换
    br28_btm_to_res_path_with_alpha((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
    NSLog(@"--->Br28 BIN【%@】is OK!", watchBinName);
    
    /*--- BR23压缩算法 ---*/
//    br23_btm_to_res_path((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
//    NSLog(@"--->Br23 BIN【%@】is OK!", watchBinName);

    return [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:watchBinName];
}

@end
