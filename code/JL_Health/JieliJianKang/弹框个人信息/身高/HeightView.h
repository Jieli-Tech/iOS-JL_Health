//
//  HeightView.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol HeightDelegate <NSObject>

-(void)heightAction:(NSString *) selectValue;
@end
@interface HeightView : UIView
@property(nonatomic,weak)id<HeightDelegate> delegate;
@property(nonatomic, assign) NSString *selectMValue;
@end

NS_ASSUME_NONNULL_END
