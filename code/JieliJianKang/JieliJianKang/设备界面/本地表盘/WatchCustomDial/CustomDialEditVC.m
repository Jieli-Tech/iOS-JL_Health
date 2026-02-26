//
//  CustomDialEditVC.m
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/24.
//

#import "CustomDialEditVC.h"
#import "CutImageViewController.h"
#import "AIDialXFManager.h"
#import "JLUI_Effect.h"

@interface CustomDialEditVC ()<CropImageDelegate>{
    UIImageView *centerImgv;
    UIButton *editBtn;
}

@end

@implementation CustomDialEditVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [JLColor colorWithString:@"#F6F7F8"];
    
    self.title = kJL_TXT("当前表盘");
    centerImgv = [UIImageView new];
    centerImgv.image = _model.image;
    centerImgv.layer.masksToBounds = true;
    centerImgv.layer.cornerRadius = 170.0/2.0;
    [self.view addSubview:centerImgv];
    
    editBtn = [UIButton new];
    [editBtn setTitle:kJL_TXT("重新裁剪") forState:UIControlStateNormal];
    [editBtn setBackgroundColor:[JLColor colorWithString:@"#EDEDED"]];
    [editBtn setTitleColor:[JLColor colorWithString:@"#558CFF"] forState:UIControlStateNormal];
    editBtn.layer.cornerRadius = 20;
    editBtn.layer.masksToBounds = true;
    editBtn.titleLabel.font = FontMedium(15);
    
    [editBtn addTarget:self action:@selector(editBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editBtn];
    
    [editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@176);
        make.height.equalTo(@40);
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY).offset(50);
    }];
    
    [centerImgv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(editBtn.mas_top).offset(-48);
        make.width.height.equalTo(@170);
    }];
    
    [self addNote];
}

-(void)editBtnAction{
    UIImage *image = centerImgv.image;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = image.size.height * (width/image.size.width);
    UIImage * orImage = [image resizeImageWithSize:CGSizeMake(width, height)];
    CutImageViewController * con = [[CutImageViewController alloc] initWithImage:orImage delegate:self];
    [self.navigationController pushViewController:con animated:YES];
}

//MARK: - handle crop Image
-(void)cropImageDidFinishedWithImage:(UIImage *)image{
    
    [JLUI_Effect startLoadingView:kJL_TXT("添加照片...") Delay:60*8];
    centerImgv.image = image;
    [[NSFileManager defaultManager] removeItemAtPath:self.model.filePath error:nil];
    [self installDial:image];

}

-(void)installDial:(UIImage *)image{
    [JLUI_Effect startLoadingView:kJL_TXT("添加照片...") Delay:60*8];
    [[AIDialXFManager share] installDialToDevice:image WithType:0 completion:^(float progress, DialOperateType success) {
        if (success == DialOperateTypeNoSpace) {
            [JLUI_Effect setLoadingText:kJL_TXT("空间不足") Delay:0.5];
        }
        if (success == DialOperateTypeFail) {
            [JLUI_Effect setLoadingText:kJL_TXT("添加失败") Delay:0.5];
        }
        if (success == DialOperateTypeDoing) {
            [JLUI_Effect setLoadingText:[NSString stringWithFormat:@"%@:%.1f%%",kJL_TXT("更新表盘..."),progress]];
        }
        if (success == DialOperateTypeSuccess) {
            [JLUI_Effect setLoadingText:kJL_TXT("添加完成") Delay:0.5];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline || tp == JLDeviceChangeTypeBleOFF) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}

@end
