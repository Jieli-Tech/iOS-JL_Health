//
//  DeleteView.h
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

@protocol DeleteViewDelegate <NSObject>

-(void)didCancelAction:(UIButton *)btn;
-(void)didDeleteAction:(UIButton *)btn;

@end


@interface DeleteView : UIView
@property (nonatomic,assign)  int type; // 0:常用联系人 1：扫描设备
@property (strong, nonatomic) UILabel *titleLab;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *deleteBtn;
@property (assign, nonatomic) id <DeleteViewDelegate> delegate;

@end
