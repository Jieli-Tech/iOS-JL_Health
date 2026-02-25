//
//  YaLiShow1.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/29.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface YaLiShow1 : UIView
@property(assign,nonatomic)float subValue_0;
@property(assign,nonatomic)float subValue_1;
@property(assign,nonatomic)float subValue_2;
@property(assign,nonatomic)float subValue_3;
- (instancetype)initByFrame:(CGRect)frame;
-(void)updateUI;
@end

NS_ASSUME_NONNULL_END
