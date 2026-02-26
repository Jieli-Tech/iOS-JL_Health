//
//  ContactsTool.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/23.
//  Modify by EzioChan 2024/2/20
//

#import <Foundation/Foundation.h>
#import "JHPersonModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^EcSyncCallBlock)(BOOL status);

@interface ContactsTool : NSObject

+ (NSData *)setContactsToData:(NSMutableArray *)array;

+ (instancetype)share;

-(void)syncContactsListWithPath:(NSString*)path Result:(EcSyncCallBlock)block;

@end


NS_ASSUME_NONNULL_END
