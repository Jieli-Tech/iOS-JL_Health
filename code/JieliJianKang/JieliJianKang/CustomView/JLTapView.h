//
//  JLTapView.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TapBlock)(void);

@interface JLTapView : UIView

@property (nonatomic, strong) TapBlock tapBlock;

@end

NS_ASSUME_NONNULL_END
