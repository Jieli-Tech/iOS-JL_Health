//
//  UnitsView.h
//  JieliJianKang
//
//  Created by 李放 on 2021/5/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol UnitsDelegate <NSObject>
-(void)didSelectUnits:(int )index;
@end
@interface UnitsView : UIView
@property (assign, nonatomic) id <UnitsDelegate> delegate;
@property(nonatomic, assign) int selectValue;
@end

NS_ASSUME_NONNULL_END
