//
//  BasicHttp.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BasicHttp : NSObject

+(NSMutableURLRequest *)Url:(NSString *)url Body:(NSData *_Nullable)data;

@end

NS_ASSUME_NONNULL_END
