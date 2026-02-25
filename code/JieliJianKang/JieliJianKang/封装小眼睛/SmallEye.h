//
//  SmallEye.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/2.
//

#import <UIKit/UIKit.h>

typedef void (^ActionBlock)(BOOL selected);
@interface SmallEye : UIButton
@property (nonatomic ,copy)ActionBlock actionBlock;
@end
