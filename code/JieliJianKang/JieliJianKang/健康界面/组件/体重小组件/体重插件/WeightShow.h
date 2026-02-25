//
//  WeightShow.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeightShow : UIView
@property (weak, nonatomic) IBOutlet UILabel *lb_0;
@property (weak, nonatomic) IBOutlet UILabel *lb_1;
- (instancetype)initByFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
