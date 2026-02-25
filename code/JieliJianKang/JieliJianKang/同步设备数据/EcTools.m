//
//  EcTools.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/2.
//

#import "EcTools.h"
#import <objc/runtime.h>

@implementation EcTools

+(void)quickArray:(NSMutableArray *)array withLeftIndex:(NSInteger)leftIndex AndRightIndex:(NSInteger)rightIndex

{
    if (leftIndex >= rightIndex) {//如果数组长度为0或1时返回
        return ;
    }
    NSInteger i = leftIndex;
    NSInteger j = rightIndex;
    //记录比较基准数
    NSInteger key = [array[i] integerValue];
    while (i < j) {
        /**** 首先从右边j开始查找比基准数小的值 ***/
        while (i < j && [array[j] integerValue] >= key) {//如果比基准数大，继续查找
            j--;
        }
        //如果比基准数小，则将查找到的小值调换到i的位置
        array[i] = array[j];
        /**** 当在右边查找到一个比基准数小的值时，就从i开始往后找比基准数大的值 ***/
        while (i < j && [array[i] integerValue] <= key) {//如果比基准数小，继续查找
            i++;
        }
        //如果比基准数大，则将查找到的大值调换到j的位置
        array[j] = array[i];
    }
    //将基准数放到正确位置
    array[i] = @(key);
    // 递归排序
    //排序基准数左边的
    [self quickArray:array withLeftIndex:leftIndex AndRightIndex:i - 1];
    //排序基准数右边的
    [self quickArray:array withLeftIndex:i + 1 AndRightIndex:rightIndex];
}



+ (NSDictionary *)properties_apsClass:(Class _Nullable)cls object:(id)model
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [model valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    return props;
}



static NSDateFormatter *cachedDateFormatter = nil;

+ (NSDateFormatter *)cachedFm{
    
    if (!cachedDateFormatter) {
        cachedDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *local = [NSLocale localeWithLocaleIdentifier:@"en"];
        [cachedDateFormatter setLocale:local];
    }
    return cachedDateFormatter;
}


@end



