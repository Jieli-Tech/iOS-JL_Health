//
//  OCHelper.m
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/18.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

#import "OCHelper.h"
#import <JL_BLEKit/JL_BLEKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#include "jpeglib.h"

@implementation OCHelper

+(void)handleBr28Bmp:(NSString *)path size:(CGSize) size binPath:(NSString *)binPath{
    
}

+(void)handleBr23mp:(NSString *)bmpPath size:(CGSize) size binPath:(NSString *)binPath{
}

+(void)testApi{
    char *name = malloc(15);
    char *fname = "test";
    char *suffix = ".bmp";
    uint32_t e = 'TIDX';//convertToBigEndian('TIDX');
    printf("%x\n", e);
    free(name);
}

// 将 32 位整数从小端字节序转换为大端字节序
uint32_t convertToBigEndian(uint32_t littleEndianValue) {
    uint32_t result = 0;

    result |= ((littleEndianValue & 0xFF000000) >> 24);
    result |= ((littleEndianValue & 0x00FF0000) >> 8);
    result |= ((littleEndianValue & 0x0000FF00) << 8);
    result |= ((littleEndianValue & 0x000000FF) << 24);

    return result;
}

+(void)resizeImageSize {
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"PNG"];
    UIImage *sourceImage = [UIImage imageWithContentsOfFile:sourcePath];
    
    CGSize maxImageSize = CGSizeMake(320, 386);
    CGFloat maxSize = 50.0;
    
    // 先调整图像的分辨率
    CGSize newSize = maxImageSize;
    UIGraphicsBeginImageContext(newSize);
    [sourceImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 然后调整图像的文件大小(压缩)
    NSData *imageData = UIImageJPEGRepresentation(newImage, 1.0);
    CGFloat sizeOriginKB = imageData.length / 1024.0;
    
    // 调整压缩率，直到图像大小满足要求
    CGFloat resizeRate = 0.9;
    while (sizeOriginKB > maxSize && resizeRate > 0.1) {
        imageData = UIImageJPEGRepresentation(newImage, resizeRate);
        sizeOriginKB = imageData.length / 1024.0;
        resizeRate -= 0.1;
    }
    
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test.jpg"];
    NSString *path1 = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test1.jpg"];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:path error:nil];
    [fm createFileAtPath:path contents:imageData attributes:nil];
    
    [fm removeItemAtPath:path1 error:nil];
    [self removeDRIAndReencodeJPEGFromPath:path toPath:path1];
    
}



+ (BOOL)removeDRIAndReencodeJPEGFromPath:(NSString *)inputPath toPath:(NSString *)outputPath {
    // 打开输入文件
    FILE *infile = fopen(inputPath.UTF8String, "rb");
    if (!infile) {
        NSLog(@"无法打开输入文件: %@", inputPath);
        return NO;
    }

    // 初始化 JPEG 解压缩对象
    struct jpeg_decompress_struct cinfo;
    struct jpeg_error_mgr jerr;
    cinfo.err = jpeg_std_error(&jerr);
    jpeg_create_decompress(&cinfo);

    // 指定输入文件
    jpeg_stdio_src(&cinfo, infile);

    // 读取文件头
    jpeg_read_header(&cinfo, TRUE);

    // 开始解压缩
    jpeg_start_decompress(&cinfo);

    // 计算行跨度
    int row_stride = cinfo.output_width * cinfo.output_components;

    // 分配缓冲区
    JSAMPARRAY buffer = (*cinfo.mem->alloc_sarray)((j_common_ptr)&cinfo, JPOOL_IMAGE, row_stride, 1);

    // 打开输出文件
    FILE *outfile = fopen(outputPath.UTF8String, "wb");
    if (!outfile) {
        NSLog(@"无法打开输出文件: %@", outputPath);
        jpeg_finish_decompress(&cinfo);
        jpeg_destroy_decompress(&cinfo);
        fclose(infile);
        return NO;
    }

    // 初始化 JPEG 压缩对象
    struct jpeg_compress_struct cinfo_out;
    struct jpeg_error_mgr jerr_out;
    cinfo_out.err = jpeg_std_error(&jerr_out);
    jpeg_create_compress(&cinfo_out);

    // 指定输出文件
    jpeg_stdio_dest(&cinfo_out, outfile);

    // 设置压缩参数（与输入文件相同）
    cinfo_out.image_width = cinfo.output_width;
    cinfo_out.image_height = cinfo.output_height;
    cinfo_out.input_components = cinfo.output_components;
    cinfo_out.in_color_space = cinfo.out_color_space;

    jpeg_set_defaults(&cinfo_out);

    // 不设置 DRI（去掉差分编码累计复位间隔）
    cinfo_out.restart_interval = 0;  // 关键：设置 restart_interval 为 0

    // 开始压缩
    jpeg_start_compress(&cinfo_out, TRUE);

    // 逐行写入数据
    while (cinfo_out.next_scanline < cinfo_out.image_height) {
        jpeg_read_scanlines(&cinfo, buffer, 1);
        jpeg_write_scanlines(&cinfo_out, buffer, 1);
    }

    // 完成压缩
    jpeg_finish_compress(&cinfo_out);

    // 释放资源
    jpeg_destroy_compress(&cinfo_out);
    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);
    fclose(infile);
    fclose(outfile);

    NSLog(@"重新编码完成，输出文件: %@", outputPath);
    return YES;
}

@end
