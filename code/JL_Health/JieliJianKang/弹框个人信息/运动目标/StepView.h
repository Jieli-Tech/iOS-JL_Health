//
//  StepView.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol StepDelegate <NSObject>

-(void)stepAction:(NSString *) selectValue;
@end
@interface StepView : UIView
@property(nonatomic,weak)id<StepDelegate> delegate;
@property(nonatomic, assign) NSString *selectMValue;
@end

NS_ASSUME_NONNULL_END
