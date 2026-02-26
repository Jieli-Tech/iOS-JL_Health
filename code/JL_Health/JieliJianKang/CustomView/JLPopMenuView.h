//
//  JLPopMenuView.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/7/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JLPopMenuViewItemObject;

typedef void (^TapBlock)(void);

@interface JLPopMenuView : UIView

- (instancetype)initWithStartPoint:(CGPoint)startPoint withItemObjectArray:(NSArray<JLPopMenuViewItemObject *> *)itemObjectArray;
-(void)setTitleName:(NSArray *)array;

@end

@interface JLPopMenuViewItemObject : NSObject

- (instancetype)initWithName:(NSString *)name withImageName:(NSString *)imageName withTapBlock:(TapBlock)tapBlock;



@end

NS_ASSUME_NONNULL_END
