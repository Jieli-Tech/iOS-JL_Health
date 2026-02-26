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
#import "CutImageViewController.h"
#import "AIDialXFManager.h"


@interface CustomWatchVC ()<PhotoDelegate,
                            UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate,CropImageDelegate>
{
    __weak IBOutlet NSLayoutConstraint *titleView_H;
    __weak IBOutlet UIButton *btnAdd;
    __weak IBOutlet UIButton *btnReset;
    __weak IBOutlet UIImageView *subImageView;
    __weak IBOutlet UILabel *titleName;
    PhotoView       *mPhotoView;
    UIImagePickerController *imagePickerController;
    
}
@property(nonatomic,strong)NSString*watchBinName;
@end

@implementation CustomWatchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupUI];
    [self addNote];
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
        subImageView.image = [UIImage imageNamed:@"watch_img_05"];
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
    [kJL_BLE_CmdManager.mFlashManager cmdWatchFlashPath:@"/null" Flag:JL_DialSettingActivateCustomDial
                            Result:^(uint8_t flag, uint32_t size,
                                     NSString * _Nullable path,
                                     NSString * _Nullable describe)
    {
        [JL_Tools mainTask:^{
            NSString *txt = kJL_TXT("已恢复默认");
            if (flag != 0) txt = kJL_TXT("恢复失败");
            [DFUITools showText:txt onView:self.view delay:1.0];
        }];
    }];
}

#pragma mark 头像拍照
- (void)takePhoto {
    mPhotoView.hidden = YES;
    
    //创建UIImagePickerController实例
    imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    imagePickerController.delegate = self;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark 头像从相册选取
-(void)takePicture{
    mPhotoView.hidden = YES;
    
    //创建UIImagePickerController实例
    imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.delegate = self;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - - - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:NO completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = image.size.height * (width/image.size.width);
        UIImage * orImage = [image resizeImageWithSize:CGSizeMake(width, height)];
        CutImageViewController * con = [[CutImageViewController alloc] initWithImage:orImage delegate:self];
        if (self.navigationController) {
            [self.navigationController pushViewController:con animated:YES];
        }else{
            con.modalPresentationStyle = 0;
            [self presentViewController:con animated:NO completion:nil];
        }
    }];
}

//MARK: - handle crop Image
-(void)cropImageDidFinishedWithImage:(UIImage *)image{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
    [JLUI_Effect startLoadingView:kJL_TXT("添加照片...") Delay:60*8];
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
