//
//  CustomWatchVC.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/4/12.
//

#import "CustomWatchVC.h"
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"
#import "WatchMarket.h"
#import "PhotoView.h"
#import "HQImageEditViewController.h"
#import "AIDialXFManager.h"


@interface CustomWatchVC ()<PhotoDelegate,
                            UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate,HQImageEditViewControllerDelegate>
{
    __weak IBOutlet NSLayoutConstraint *titleView_H;
    __weak IBOutlet UIButton *btnAdd;
    __weak IBOutlet UIButton *btnReset;
    __weak IBOutlet UIImageView *subImageView;
    __weak IBOutlet UILabel *titleName;
    PhotoView       *mPhotoView;
    UIImagePickerController *imagePickerController;
    JLDialInfoExtentedModel *mDialInfo;
}
@property(nonatomic,strong)NSString*watchBinName;
@end

@implementation CustomWatchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupUI];
    [self addNote];
    
    [self initData];
    
}

-(void)initData{
 
    mDialInfo = [[JL_RunSDK sharedMe] dialInfoExtentedModel];

}

-(void)setupUI{
    float sW = [UIScreen mainScreen].bounds.size.width;
    float sH = [UIScreen mainScreen].bounds.size.height;
    titleView_H.constant = kJL_HeightNavBar;
    
    titleName.text = kJL_TXT("当前表盘");
    [btnAdd setTitle:kJL_TXT("添加照片") forState:UIControlStateNormal];
    [btnReset setTitle:kJL_TXT("恢复默认") forState:UIControlStateNormal];
    btnAdd.layer.cornerRadius = 20.0;
    btnReset.layer.cornerRadius = 20.0;
    
    mPhotoView = [[PhotoView alloc] initWithFrame:CGRectMake(0, 0, sW, sH)];
    mPhotoView.delegate = self;
    mPhotoView.hidden = YES;
    [self.view addSubview:mPhotoView];
    
    NSData *iconData = [WatchMarket getDataOfWatchIcon:self.watchName];
    if (iconData.length == 0) {
        subImageView.image = [UIImage imageNamed:@"watch_img_06"];
    } else {
        subImageView.image = [UIImage imageWithData:iconData];
    }
}

- (void)setWatchName:(NSString *)watchName {
    _watchName = watchName;
    
    if ([watchName isEqual:@"WATCH"]) {
        self.watchBinName = @"BGP_W000";
    } else {
        NSString *txt = [watchName stringByReplacingOccurrencesOfString:@"WATCH" withString:@""];
        NSInteger strLen = txt.length;
        if (strLen == 1) self.watchBinName = [NSString stringWithFormat:@"BGP_W00%@", txt];
        if (strLen == 2) self.watchBinName = [NSString stringWithFormat:@"BGP_W0%@", txt];
        if (strLen == 3) self.watchBinName = [NSString stringWithFormat:@"BGP_W%@", txt];
    }
}

- (IBAction)btn_back:(id)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)btnAddPicture:(id)sender {
    mPhotoView.hidden = NO;
}

- (IBAction)btnRecovery:(id)sender {
    [[DialBaseViewModel shared] resetDialBackgroud:self.watchName :^(BOOL status) {
        [JL_Tools mainTask:^{
            NSString *txt = kJL_TXT("已恢复默认");
            if (!status) txt = kJL_TXT("恢复失败");
            [DFUITools showText:txt onView:self.view delay:1.0];
        }];
    }];
}

#pragma mark 头像拍照
- (void)takePhoto {
    mPhotoView.hidden = YES;
    [self makePickerImage:UIImagePickerControllerSourceTypeCamera];
}

#pragma mark 头像从相册选取
-(void)takePicture{
    mPhotoView.hidden = YES;
    [self makePickerImage:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}

-(void)makePickerImage:(UIImagePickerControllerSourceType)type{
    imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.sourceType = type;
    if (type == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    }
    imagePickerController.delegate = self;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - - - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:NO completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (image == nil){
            return;
        }
        JLModel_Flash *model = kJL_BLE_CmdManager.mFlashManager.flashInfo;
        HQImageEditViewController *vc = [[HQImageEditViewController alloc] init];
        vc.originImage = image;
        vc.delegate = self;
        vc.maskViewAnimation = YES;
        vc.editViewSize = CGSizeMake(model.mScreenWidth/2, model.mScreenHeight/2);
        vc.model = strongSelf->mDialInfo;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }];
}

//MARK: - handle crop Image

- (void)editController:(HQImageEditViewController *)vc finishiEditShotImage:(UIImage *)image originSizeImage:(UIImage *)originSizeImage {
    
    [vc dismissViewControllerAnimated:YES completion:nil];
    
    [JLUI_Effect startLoadingView:kJL_TXT("添加照片...") Delay:60*8];
    [self installDial:image orImage:originSizeImage];
    
}

- (void)editControllerDidClickCancel:(HQImageEditViewController *)vc {
    [vc dismissViewControllerAnimated:YES completion:nil];
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
            [JLUI_Effect setLoadingText:[NSString stringWithFormat:@"%@:%.0f%%",kJL_TXT("添加进度"),progress]];
        }
        if (success == DialOperateTypeSuccess) {
            [JLUI_Effect setLoadingText:kJL_TXT("添加完成") Delay:0.5];
        }
    }];
}


-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline || tp == JLDeviceChangeTypeBleOFF) {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}

@end
