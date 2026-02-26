//
//  JL_Talk.m
//  JL_BLE
//
//  Created by DFung on 2018/1/8.
//  Copyright © 2018年 DFung. All rights reserved.
//

#import "JL_Talk.h"

@implementation JL_Talk


#pragma mark - 记录对话
#define kFIND_PATH  [JL_Tools findPath:NSLibraryDirectory MiddlePath:@"JL_TALKLIST" File:@"speech.txt"]
#define kMAKE_PATH  [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"JL_TALKLIST" File:@"speech.txt"]
+(void)talkPost:(NSDictionary*)dic{
    [self talkWrite:dic];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JL_BDTalk" object:dic];
}
+(void)talkWrite:(NSDictionary*)dic{
    NSString *path = kFIND_PATH;
    if (!path) path = kMAKE_PATH;
    
    NSMutableArray *mArr = [NSMutableArray new];
    NSArray *pArr = [JL_Tools JsonPath:path];
    
    if (pArr.count != 0)  mArr = [NSMutableArray arrayWithArray:pArr];
    [mArr addObject:dic];
    
    NSString *text = [JL_Tools arrayToJson:mArr];
    [JL_Tools writeData:[text dataUsingEncoding:NSUTF8StringEncoding] fillFile:path];
}
+(NSArray*)talkRed{
    NSString *path = kFIND_PATH;
    if (!path) return nil;
    NSArray *pArr = [JL_Tools JsonPath:path];
    return pArr;
}
+(void)talkRemove{
    NSString *path = kFIND_PATH;
    [JL_Tools removePath:path];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JL_BDTalk" object:nil];
}


@end
