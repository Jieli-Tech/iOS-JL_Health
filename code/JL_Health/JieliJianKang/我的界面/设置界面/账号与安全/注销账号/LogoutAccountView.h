//
//  ChangeMobileView.h
//  JieliJianKang
//
//  Created by 李放 on 2021/4/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LogoutAccountViewPickDelegate <NSObject>
@optional
-(void)onLogoutAccountCancel;
-(void)onLogoutAccountSure;
@end

@interface LogoutAccountView : UIView

@property(nonatomic,weak)id<LogoutAccountViewPickDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
