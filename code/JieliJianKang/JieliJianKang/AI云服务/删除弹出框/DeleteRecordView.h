//
//  DeleteView.h
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

@protocol DeleteRecordViewDelegate <NSObject>

-(void)didCancelAllAction:(UIButton *)btn;
-(void)didDeleteAllAction:(UIButton *)btn;
-(void)didCancelAction:(UIButton *)btn;
-(void)didDeleteAction:(UIButton *)btn;

@end


@interface DeleteRecordView : UIView
@property (strong, nonatomic) UILabel *titleLab;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *deleteBtn;
@property(assign,nonatomic) int type;
@property (assign, nonatomic) id <DeleteRecordViewDelegate> delegate;

@end
