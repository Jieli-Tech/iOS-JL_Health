//
//  LoginVC.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol LoginDelegate <NSObject>

-(void)loginAction:(NSString*)mobile;
@end

@interface LoginVC : UIViewController
@property(nonatomic,weak)id<LoginDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
