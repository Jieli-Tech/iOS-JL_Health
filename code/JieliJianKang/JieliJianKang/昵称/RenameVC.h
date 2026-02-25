//
//  RenameVC.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ReNameViewDelegate <NSObject>

-(void)didSelectBtnAction:(UIButton *)btn WithText:(NSString *)text;
@end

@interface RenameVC : UIViewController
@property (strong, nonatomic) NSString *txfdStr;
@property (assign,nonatomic) int type; // 0: 昵称 1：名称
@property (assign, nonatomic) id <ReNameViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
