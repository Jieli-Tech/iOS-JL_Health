//
//  DeleteView.m

#import "DeleteView.h"

#define DeleteView_W      self.frame.size.width
#define DeleteView_H      self.frame.size.height

@interface DeleteView(){
    UITapGestureRecognizer *tapges;
    UIImageView *bgImgv;
    UIView *centerView;
    
    int mType;
}
@end
@implementation DeleteView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        [self initUI];
        [self adjustDark];
    }
    return self;
    
}

#pragma mark 适配暗黑模式
-(void)adjustDark{
    if (@available(iOS 13.0, *)) {
        UIColor *bgColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
            }
            else {
                return [UIColor colorWithRed:60/255.0 green:61/255.0 blue:74/255.0 alpha:1.0];
            }
        }];
        [centerView setBackgroundColor:bgColor];
    } else {
        // Fallback on earlier versions
        [centerView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
    }
}

-(void)initUI{
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, DeleteView_W, DeleteView_H)];
    //样式
    toolbar.barStyle = UIBarStyleBlackTranslucent;//半透明
    UITapGestureRecognizer *ttohLefttapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    [toolbar addGestureRecognizer:ttohLefttapGestureRecognizer];
    toolbar.userInteractionEnabled=YES;
    //透明度
    toolbar.alpha = 0.45f;
    [self addSubview:toolbar];
    
    //命令背景View
    centerView = [[UIView alloc] initWithFrame:CGRectMake(46,DeleteView_H/3,DeleteView_W-46*2,130)];
    centerView.backgroundColor = [UIColor whiteColor];
    centerView.alpha=1.0;
    centerView.layer.cornerRadius = 8;
    [self addSubview:centerView];
    
    //提示框名称
    _titleLab = [[UILabel alloc] init];
    _titleLab.frame = CGRectMake(centerView.frame.size.width/2-160/2,32,160,22);
    _titleLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    _titleLab.textColor = kDF_RGBA(36.0, 36.0, 36.0, 1.0);
    _titleLab.numberOfLines = 0;
    _titleLab.textAlignment = NSTextAlignmentCenter;
    [centerView addSubview:_titleLab];
    
    if (@available(iOS 13.0, *)) {
        UIColor *titleColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0];
            }
            else {
                return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7];
            }
        }];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("名 称") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: titleColor}];
        
        _titleLab.attributedText = string;
    } else {
        // Fallback on earlier versions
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("名 称") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0]}];
        
        _titleLab.attributedText = string;
    }
    
    UIView *view_1 = [[UIView alloc] init];
    view_1.frame = CGRectMake(0,83,centerView.frame.size.width,0.5);
    view_1.backgroundColor =  kDF_RGBA(242.0, 242.0, 242.0, 1.0);;
    [centerView addSubview:view_1];
    
    _cancelBtn = [[UIButton alloc] initWithFrame: CGRectMake(0,84,(centerView.frame.size.width-1)/2,47)];
    [_cancelBtn setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor colorWithRed:85/255.0 green:140/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_cancelBtn.titleLabel setFont:[UIFont fontWithName:@"PingFang SC" size: 16]];
    [_cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [centerView addSubview:_cancelBtn];
    
    UIView *view_2 = [[UIView alloc] init];
    view_2.frame = CGRectMake(_cancelBtn.frame.size.width,83,1,47);
    view_2.backgroundColor = kDF_RGBA(242.0, 242.0, 242.0, 1.0);;
    [centerView addSubview:view_2];
    
    
    _deleteBtn = [[UIButton alloc] initWithFrame: CGRectMake(_cancelBtn.frame.size.width+1,84,(centerView.frame.size.width-1)/2,47)];
    [_deleteBtn setTitle:kJL_TXT("删除") forState:UIControlStateNormal];
    [_deleteBtn setTitleColor:[UIColor colorWithRed:85/255.0 green:140/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_deleteBtn.titleLabel setFont:[UIFont fontWithName:@"PingFang SC" size: 16]];
    [_deleteBtn addTarget:self action:@selector(deleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [centerView addSubview:_deleteBtn];
}

-(void)setType:(int)type{
    mType = type;
    
    if(mType == 0){
        if([kJL_GET hasPrefix:@"zh"]){
            _titleLab.frame = CGRectMake(centerView.frame.size.width/2-160/2,32,160,22);
        }else{
            _titleLab.frame = CGRectMake(centerView.frame.size.width/2-300/2,32,300,22);
        }
        [_cancelBtn setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
        [_deleteBtn setTitle:kJL_TXT("删除") forState:UIControlStateNormal];
    }
    if(mType == 1){
        _titleLab.frame = CGRectMake(centerView.frame.size.width/2-247/2,20,247,44);
        [_cancelBtn setTitle:kJL_TXT("重试") forState:UIControlStateNormal];
        [_deleteBtn setTitle:kJL_TXT("暂不绑定") forState:UIControlStateNormal];
    }
}

-(void)dismissView{
    self.hidden = YES;
}

- (void)cancelBtnAction:(UIButton *)sender {
    self.hidden = YES;
    
    if ([_delegate respondsToSelector:@selector(didCancelAction:)]) {
        [_delegate didCancelAction:_cancelBtn];
    }
}

- (void)deleteBtnAction:(UIButton *)sender {
    self.hidden = YES;
    
    if ([_delegate respondsToSelector:@selector(didDeleteAction:)]) {
        [_delegate didDeleteAction:_deleteBtn];
    }
}

@end
