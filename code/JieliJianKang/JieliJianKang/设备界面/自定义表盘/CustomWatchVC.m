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


@interface CustomWatchVC ()<PhotoDelegate,
                            UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate>
{
    __weak IBOutlet NSLayoutConstraint *titleView_H;
    __weak IBOutlet UIButton *btnAdd;
    __weak IBOutlet UIButton *btnReset;
    __weak IBOutlet UIImageView *subImageView;
    __weak IBOutlet UILabel *titleName;
    PhotoView       *mPhotoView;
    
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
    float sW = [DFUITools screen_2_W];
    float sH = [DFUITools screen_2_H];
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
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark 头像从相册选取
-(void)takePicture{
    mPhotoView.hidden = YES;
    
    //创建UIImagePickerController实例
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - - - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [JLUI_Effect startLoadingView:kJL_TXT("添加照片...") Delay:60*8];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"图片分辨率 ---> w:%.1f h:%.1f",image.size.width,image.size.height);
 
    JLModel_Device *model = [kJL_BLE_CmdManager outputDeviceModel];
    uint16_t dev_W = model.flashInfo.mScreenWidth;
    uint16_t dev_H = model.flashInfo.mScreenHeight;
    if (dev_W == 0) dev_W = 240;
    if (dev_H == 0) dev_H = 240;
    
    NSData *imageData = [BitmapTool resizeImage:image andResizeTo:CGSizeMake(dev_W, dev_H)];
    [self changeImageToBin:imageData];
    
    NSMutableArray *customList = [kJL_DIAL_CACHE getWatchCustomList];
    if ([customList containsObject:self.watchBinName]) {
        [self replaceCustomWatch];//更新自定义图片
    } else {
        [self addCustomWatch];//增加自定义图片
    }
}


-(void)changeImageToBin:(NSData*)imageData{
    NSString *bmpPath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:@"ios_test.bmp"];
    NSString *binPath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:self.watchBinName];
    
    [JL_Tools removePath:bmpPath];
    [JL_Tools removePath:binPath];
    
    [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:@"ios_test.bmp"];
    [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:self.watchBinName];

    UIImage *image = [UIImage imageWithData:imageData];
    int width = image.size.width;
    int height = image.size.height;
    NSLog(@"压缩分辨率 ---> w:%df h:%df",width,height);
    
    NSData *bitmap = [BitmapTool convert_B_G_R_A_BytesFromImage:image];
    [JL_Tools writeData:bitmap fillFile:bmpPath];
    
    JLModel_Device *model = [kJL_BLE_CmdManager outputDeviceModel];
    
    if (model.sdkType == JL_SDKType701xWATCH) {
        /*--- BR28压缩算法 ---*/
        br28_btm_to_res_path((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
        NSLog(@"--->Br28 BIN【%@】is OK!", self.watchBinName);
    }else{
        /*--- BR23压缩算法 ---*/
        br23_btm_to_res_path((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
        NSLog(@"--->Br23 BIN【%@】is OK!", self.watchBinName);
    }
}

- (void)addCustomWatch {
    NSString *wName = [NSString stringWithFormat:@"/%@", self.watchBinName];
    NSString *binPath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:self.watchBinName];

    NSData *pathData = [NSData dataWithContentsOfFile:binPath];
    NSLog(@"-->添加自定义表盘的大小:%lld",(long long)pathData.length);
    
    [DialManager addFile:wName Content:pathData Result:^(DialOperateType type, float progress) {
        if (type == DialOperateTypeNoSpace) {
            [JLUI_Effect setLoadingText:kJL_TXT("空间不足") Delay:0.5];
        }
        if (type == DialOperateTypeFail) {
            [JLUI_Effect setLoadingText:kJL_TXT("添加失败") Delay:0.5];
        }
        if (type == DialOperateTypeDoing) {
            [JLUI_Effect setLoadingText:[NSString stringWithFormat:@"%@:%.1f%%",kJL_TXT("添加进度"),progress*100.0f]];
        }
        if (type == DialOperateTypeSuccess) {
            [JLUI_Effect setLoadingText:kJL_TXT("添加完成") Delay:0.5];
            /*--- 更新缓存 ---*/
            [kJL_DIAL_CACHE addWatchCustomListObject:self.watchBinName];
            [self activeCustomWatch];//设置自定义表盘
        }
    }];
}

- (void)replaceCustomWatch {
    NSString *wName = [NSString stringWithFormat:@"/%@",self.watchBinName];
    NSString *binPath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:self.watchBinName];

    NSData *pathData = [NSData dataWithContentsOfFile:binPath];
    NSLog(@"-->跟新自定义表盘的大小:%lld",(long long)pathData.length);
    
    [DialManager repaceFile:wName Content:pathData
                     Result:^(DialOperateType type, float progress)
    {
        if (type == DialOperateTypeNoSpace) {
            [JLUI_Effect setLoadingText:kJL_TXT("空间不足") Delay:0.5];
        }
        
        if (type == DialOperateTypeDoing) {
            NSString *txt = [NSString stringWithFormat:@"%@:%.1f%%",kJL_TXT("更新进度"),progress*100.0f];
            [JLUI_Effect setLoadingText:txt];
        }
        
        if (type == DialOperateTypeFail) {
            [JLUI_Effect setLoadingText:kJL_TXT("更新失败") Delay:0.5];
        }
        
        if (type == DialOperateTypeSuccess) {
            [JLUI_Effect setLoadingText:kJL_TXT("更新完成") Delay:0.5];
            [self activeCustomWatch];//设置自定义表盘
        }
    }];
}

- (void)activeCustomWatch {
    NSString *wName = [NSString stringWithFormat:@"/%@",self.watchBinName];
    [kJL_BLE_CmdManager.mFlashManager cmdWatchFlashPath:wName Flag:JL_DialSettingActivateCustomDial
                            Result:^(uint8_t flag, uint32_t size,
                                     NSString * _Nullable path,
                                     NSString * _Nullable describe) {
        [JL_Tools mainTask:^{
            [DFUITools showText:(flag != 0) ? kJL_TXT("设置失败") : kJL_TXT("设置成功") onView:self.view delay:1.0];
        }];
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
