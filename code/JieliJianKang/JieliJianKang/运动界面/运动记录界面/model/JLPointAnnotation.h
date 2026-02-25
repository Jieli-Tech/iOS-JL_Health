//
//  JLPointAnnotation.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/15.
//

#import <MAMapKit/MAMapKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JLPointAnnotationType)
{
    JLPointAnnotationTypeStart = 0,    //开始
    JLPointAnnotationTypeEnd = 1,      //结束
};

@interface JLPointAnnotation : MAPointAnnotation

@property (assign, nonatomic) JLPointAnnotationType type;

@end

NS_ASSUME_NONNULL_END
