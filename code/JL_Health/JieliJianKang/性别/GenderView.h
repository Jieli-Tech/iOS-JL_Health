//
//  GenderView.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol GenderDelegate <NSObject>
-(void)didSelectGender:(int )index;
@end
@interface GenderView : UIView
@property (assign, nonatomic) id <GenderDelegate> delegate;
@property(nonatomic, assign) int selectValue;
@end

NS_ASSUME_NONNULL_END
