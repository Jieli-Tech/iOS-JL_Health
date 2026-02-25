//
//  DefaultPartView.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/19.
//

#import <UIKit/UIKit.h>
#import "TransJump.h"

NS_ASSUME_NONNULL_BEGIN

@interface DefaultPartView : UIView

@property(nonatomic,assign)JumpType type;

@property(nonatomic,weak)id<TransJumpDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame Type:(NSString *)typeName Image:(UIImage *)img;

-(void)setLabValue:(NSString *)value Unit:(NSString *)units day:(NSDate *_Nullable) date;

-(void)setTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
