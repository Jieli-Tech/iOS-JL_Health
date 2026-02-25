//
//  WeightView.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WeightDelegate <NSObject>

-(void)weightAction:(NSString *) selectValue;
@end
@interface WeightView : UIView
@property(nonatomic,weak)id<WeightDelegate> delegate;
@property(nonatomic, assign) NSString *selectMValue;
@end

NS_ASSUME_NONNULL_END
