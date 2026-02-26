//
//  JLStatementViewController.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/7/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JLStatementViewControllerDelegate <NSObject>

-(void)confirmCancelBtnAction;
-(void)confirmDidSelect:(int)index;
-(void)confirmConfirmBtnAction;

@end

@interface JLStatementViewController : UIViewController

@property (weak, nonatomic) id<JLStatementViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
