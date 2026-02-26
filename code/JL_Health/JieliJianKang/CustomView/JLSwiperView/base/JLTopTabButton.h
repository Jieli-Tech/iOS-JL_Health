//
//  JLTopTabButton.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TouchesBeganBlock)(void);

@interface JLTopTabButton : UIView

@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, strong) TouchesBeganBlock touchesBeganBlock;

+ (instancetype)topTabButtonWithFrame:(CGRect)frame withTitle:(NSString *)title withDefaulTitleColor:(UIColor *)defaultTitleColor withSelectedTitleColor:(UIColor *)selectedTitleColor;

@end

NS_ASSUME_NONNULL_END
