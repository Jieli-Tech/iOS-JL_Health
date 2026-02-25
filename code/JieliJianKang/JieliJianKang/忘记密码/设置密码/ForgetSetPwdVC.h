//
//  ForgetSetPwdVC.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ForgetSetPwdVC : UIViewController

@property (strong, nonatomic) NSString *mobile; //手机号
@property (strong, nonatomic) NSString *code;   //验证码
@property (assign, nonatomic) JLUSER_WAY userWay;

@end

NS_ASSUME_NONNULL_END
