//
//  RenameVC.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/4.
//

#import "RenameVC.h"
#import "JL_RunSDK.h"

@interface RenameVC ()<UITextFieldDelegate>{
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *saveBtn;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    
    UIView      *nameView;
    UITextField *nameTF;
    NSInteger sizeLength;
}

@end

@implementation RenameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    
    sizeLength = 20;
    titleHeight.constant = kJL_HeightNavBar;
    float sw = [UIScreen mainScreen].bounds.size.width;
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    [cancelBtn setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
    cancelBtn.frame  = CGRectMake(16, kJL_HeightStatusBar-5, 60, 44);
    
    CGFloat width = [self getWidthWithText:kJL_TXT("保存") height:44 font:18];
    saveBtn.frame  = CGRectMake(sw-16-width, kJL_HeightStatusBar-5, width, 44);
    [saveBtn setTitle:kJL_TXT("保存") forState:UIControlStateNormal];

    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+16);
    
    nameView = [[UIView alloc] initWithFrame:CGRectMake(0,subTitleView.frame.size.height+subTitleView.frame.origin.y+8,sw,50)];
    [self.view addSubview:nameView];
    nameView.backgroundColor = [UIColor whiteColor];
    
    nameTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 50/2-25/2, sw-32, 25)];
    nameTF.textAlignment = NSTextAlignmentLeft;
    nameTF.textColor = kDF_RGBA(36, 36, 36, 1.0);
    nameTF.tintColor = kDF_RGBA(180, 180, 180, 1.0);
    nameTF.font = [UIFont fontWithName:@"PingFangSC" size:14];
    nameTF.delegate = self;
    nameTF.tag =0;
    [nameView addSubview:nameTF];
    nameTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    nameTF.text = _txfdStr;
    
    if(self.type == 0){
        titleName.text = kJL_TXT("昵称");
        nameTF.placeholder = kJL_TXT("请输入昵称");
    }
    if(self.type == 1){
        titleName.text = kJL_TXT("名称");
        nameTF.placeholder = kJL_TXT("请输入闹钟名称");
    }
}

- (IBAction)cancelBtn:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveBtn:(UIButton *)sender {
    [nameTF endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if(nameTF.text.length == 0){
        [DFUITools showText:kJL_TXT("名字不能设置为空") onView:self.view delay:1.0];
        return;
    }
    
    NSData *data = [nameTF.text dataUsingEncoding:NSUTF8StringEncoding];

    if(data.length>sizeLength){
        [DFUITools showText:kJL_TXT("名字长度不能大于20字节") onView:self.view delay:1.0];
        return;
    }
    if ([_delegate respondsToSelector:@selector(didSelectBtnAction:WithText:)]) {
        [_delegate didSelectBtnAction:saveBtn WithText:nameTF.text];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [nameTF endEditing:YES];
    [self saveBtn:saveBtn];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/// 计算宽度
/// @param text 文字
/// @param height 高度
/// @param font 字体
- (CGFloat)getWidthWithText:(NSString *)text height:(CGFloat)height font:(CGFloat)font{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil];
    return rect.size.width;
}

@end
