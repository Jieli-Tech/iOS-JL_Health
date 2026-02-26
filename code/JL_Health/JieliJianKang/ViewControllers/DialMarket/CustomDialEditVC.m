//
//  CustomDialEditVC.m
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/24.
//

#import "CustomDialEditVC.h"
#import "HQImageEditViewController.h"
#import "AIDialXFManager.h"
#import "JLUI_Effect.h"

@interface CustomDialEditVC ()<HQImageEditViewControllerDelegate>{
    UIImageView *centerImgv;
    UIButton *editBtn;
    JLDialInfoExtentedModel *mDialInfo;
}

@end

@implementation CustomDialEditVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [JLColor colorWithString:@"#F6F7F8"];
    
    self.title = kJL_TXT("当前表盘");
    centerImgv = [UIImageView new];
    centerImgv.image = _model.image;
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
    
    JLModel_Flash *flashModel = kJL_BLE_CmdManager.mFlashManager.flashInfo;
    
    [editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@176);
        make.height.equalTo(@40);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(centerImgv.mas_bottom).offset(50);
    }];
    
    [centerImgv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.navigateView.mas_bottom).offset(48);
        make.width.equalTo(@(flashModel.mScreenWidth/2));
        make.height.equalTo(@(flashModel.mScreenHeight/2));
    }];
    centerImgv.layer.masksToBounds = true;
    
    [self addNote];
    [self initData];
}

-(void)editBtnAction{
    UIImage *image = _model.originImage == nil ? _model.image:_model.originImage;
    JLModel_Flash *model = kJL_BLE_CmdManager.mFlashManager.flashInfo;
    HQImageEditViewController *vc = [[HQImageEditViewController alloc] init];
    vc.originImage = image;
    vc.delegate = self;
    vc.maskViewAnimation = YES;
    vc.editViewSize = CGSizeMake(model.mScreenWidth/2, model.mScreenHeight/2);
    vc.model = mDialInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)initData{
    
    mDialInfo = [[JL_RunSDK sharedMe] dialInfoExtentedModel];
    if ([[JL_RunSDK sharedMe] configModel].exportFunc.spDialInfoExtend) {
        JLModel_Flash *flashModel = [kJL_BLE_CmdManager outputDeviceModel].flashInfo;
        if(mDialInfo.shape == 0x01){//圆
            centerImgv.layer.cornerRadius = flashModel.mScreenWidth/2/2;//取设备屏幕的圆角半径
        }else if (mDialInfo.shape == 0x02){//矩形
            centerImgv.layer.cornerRadius = 0;
        }else if (mDialInfo.shape == 0x03){//圆角矩形
            centerImgv.layer.cornerRadius = mDialInfo.radius/2;
        }
    }
    centerImgv.layer.masksToBounds = true;

}

//MARK: - handle crop Image

- (void)editController:(HQImageEditViewController *)vc finishiEditShotImage:(UIImage *)image originSizeImage:(UIImage *)originSizeImage {
    
    [vc.navigationController popViewControllerAnimated:true];
    
    [JLUI_Effect startLoadingView:kJL_TXT("添加照片...") Delay:60*8];
    centerImgv.image = image;
    [[NSFileManager defaultManager] removeItemAtPath:self.model.filePath error:nil];
    [self installDial:image orImage:originSizeImage];
    
}

- (void)editControllerDidClickCancel:(HQImageEditViewController *)vc {
    [vc.navigationController popViewControllerAnimated:true];
}


-(void)installDial:(UIImage *)image orImage:(UIImage *)orImage{
    [JLUI_Effect startLoadingView:kJL_TXT("添加照片...") Delay:60*8];
    [[AIDialXFManager share] installDialToDevice:image WithType:0 originSizeImage:orImage completion:^(float progress, DialOperateType success) {
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
