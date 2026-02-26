//
//  DebugTools.m
//  JieliJianKang
//
//  Created by EzioChan on 2022/11/7.
//

#import "DebugTools.h"

@implementation DebugTools




+(void)configDeviceTest{
#ifdef DEBUG
    uint8_t byte[] = { 0x00,
        0x00,
        0x1F,0x00,
        0x0F,0x00,
        0x75,0x00,
        0x02,0x00,0x03,
        0x02,0x01,0x03,
        0x02,0x02,0x00,
        0x02,0xFE,0x0F,
        0x02,0xFF,0x9D};
    NSData *data = [NSData dataWithBytes:byte length:23];
    [[JLDeviceConfig share] pDeviceTest:data Status:YES];
#endif
}


@end
