//
//  PhotoView.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/4.
//

#import "PhotoView.h"
#import "JL_RunSDK.h"

@interface PhotoView()<LanguagePtl>{
    UIView *bgView;
    UIView *view1; //拍照和从相册中获取
    UIView *viewCancel; //取消
    
    UIButton *photoBtn;  //拍照
    UIButton *selectBtn; //从相册选取
    UIButton *cancelBtn; //取消
    float sw;
    float sh;
}

@end
@implementation PhotoView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        sw = frame.size.width;
        sh = frame.size.height;
        [[LanguageCls share] add:self];
        [self initUI];
    }
    return self;
}

-(void)initUI{
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self addSubview:bgView];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.2;
    
    view1 = [[UIView alloc] initWithFrame:CGRectMake(16, sh-102-120, sw-32, 120)];
    [self addSubview:view1];
    view1.backgroundColor    = kDF_RGBA(255, 255, 255, 1);
    view1.layer.shadowColor  = kDF_RGBA(205, 230, 251, 0.4).CGColor;
    view1.layer.shadowOffset = CGSizeMake(0,1);
    view1.layer.shadowOpacity= 1;
    view1.layer.shadowRadius = 10;
    view1.layer.cornerRadius = 16;
    
    photoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,sw-32,60)];
    [photoBtn addTarget:self action:@selector(takePhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    [photoBtn setTitle:kJL_TXT("拍照") forState:UIControlStateNormal];
    [photoBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:18]];
    [photoBtn setTitleColor:kDF_RGBA(0, 0, 0, 1.0) forState:UIControlStateNormal];
    [view1 addSubview:photoBtn];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 59, sw-32, 1)];
    [view1 addSubview:view2];
    view2.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,60,sw-32,60)];
    [selectBtn addTarget:self action:@selector(takePictureAction:) forControlEvents:UIControlEventTouchUpInside];
    [selectBtn setTitle:kJL_TXT("从相册中选取") forState:UIControlStateNormal];
    [selectBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:18]];
    [selectBtn setTitleColor:kDF_RGBA(0, 0, 0, 1.0) forState:UIControlStateNormal];
    [view1 addSubview:selectBtn];
    
    viewCancel = [[UIView alloc] initWithFrame:CGRectMake(16, sh-34-60, sw-32, 60)];
    [self addSubview:viewCancel];
    viewCancel.backgroundColor = kDF_RGBA(255, 255, 255, 1);
    viewCancel.layer.shadowColor = kDF_RGBA(205, 230, 251, 0.4).CGColor;
    viewCancel.layer.shadowOffset = CGSizeMake(0,1);
    viewCancel.layer.shadowOpacity = 1;
    viewCancel.layer.shadowRadius = 10;
    viewCancel.layer.cornerRadius = 16;
    
    cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,sw-32,60)];
    [cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:18]];
    [cancelBtn setTitleColor:kDF_RGBA(85, 140, 255, 1.0) forState:UIControlStateNormal];
    [viewCancel addSubview:cancelBtn];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.hidden = YES;
}

#pragma mark 拍照
-(void)takePhotoAction:(UIButton *)btn{
    if ([_delegate respondsToSelector:@selector(takePhoto)]) {
        [_delegate takePhoto];
    }
}

#pragma mark 从相册中选取
-(void)takePictureAction:(UIButton *)btn{
    if ([_delegate respondsToSelector:@selector(takePicture)]) {
        [_delegate takePicture];
    }
}

#pragma mark 取消
-(void)cancelAction:(UIButton *)btn{
    self.hidden = YES;
}

- (void)languageChange {
    [photoBtn setTitle:kJL_TXT("拍照") forState:UIControlStateNormal];
    [selectBtn setTitle:kJL_TXT("从相册中选取") forState:UIControlStateNormal];
    [cancelBtn setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
}

@end
