//
//  WatchLocalVC.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/1.
//

#import "WatchLocalVC.h"
#import "WatchCell.h"
#import "JLUI_Effect.h"

#import "WatchMarket.h"
#import "MJRefresh.h"
#import "WatchLocalModel.h"

#import "WatchOwn.h"
#import "DialShopView.h"
#import "DialModel.h"
#import "WatchHistoryVC.h"
#import "WatchDialTitleView.h"
#import "WatchCustomDial/CustomDialView.h"
#import "CutImageViewController.h"
#import "AIDialXFManager.h"

@interface WatchLocalVC ()<UIScrollViewDelegate,PhotoDelegate,UIImagePickerControllerDelegate,
UINavigationControllerDelegate,CropImageDelegate>{

    __weak IBOutlet UIButton            *btnManager;
    __weak IBOutlet NSLayoutConstraint  *titleView_H;
    __weak IBOutlet UILabel             *titleLabel;

    
    WatchDialTitleView          *titleBarView;
    
    UIScrollView                *mScrollView;
    DialShopView                *dialShopView;
    WatchOwn                    *watchOwn;
    CustomDialView              *customView;
    UIImagePickerController     *imagePickerController;
    
    NSArray                     *mWatchsOfDevice;
    BOOL                        isNeedPayment;
}
@property(strong,nonatomic)NSMutableArray   *dataArray;
@end

@implementation WatchLocalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    titleLabel.text = kJL_TXT("表盘");
    
    [self setupUI];
    [self addNote];
}


- (IBAction)btn_isManager:(id)sender {
    WatchHistoryVC *vc = [[WatchHistoryVC alloc] init];
    vc.modalPresentationStyle = 0;
    [self presentViewController:vc animated:YES completion:nil];
}




-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float sW = [UIScreen mainScreen].bounds.size.width;
    int currentPostion = scrollView.contentOffset.x;
    if (currentPostion < sW) {
        [titleBarView handleBtnClick:0];
    }else if(currentPostion >= sW*2){
        [titleBarView handleBtnClick:2];
    }else{
        [titleBarView handleBtnClick:1];
    }
}



-(void)enableFreeOnlyWatchUI{
    
    [titleBarView setHidden:true];
    btnManager.hidden = YES;
}


-(void)setupUI{
    float sW = [UIScreen mainScreen].bounds.size.width;
    float sH = [UIScreen mainScreen].bounds.size.height;
    titleView_H.constant = kJL_HeightNavBar;
    
   
    titleBarView = [[WatchDialTitleView alloc] initWithFrame:CGRectMake(57, kJL_HeightNavBar+4, sW-57*2, 35)];
    __block typeof(self) weakSelf = self;
    titleBarView.callback = ^(int index) {
        float sW = [UIScreen mainScreen].bounds.size.width;
        float sH = [UIScreen mainScreen].bounds.size.height;
        [weakSelf->mScrollView scrollRectToVisible:CGRectMake(sW*index, 0, sW, sH-kJL_HeightNavBar-50) animated:YES];
        [weakSelf->btnManager setHidden:false];
    };
    [self.view addSubview:titleBarView];
    

    mScrollView = [[UIScrollView alloc] init];
    mScrollView.frame = CGRectMake(0, kJL_HeightNavBar+50, sW, sH-kJL_HeightNavBar-50);
    mScrollView.showsHorizontalScrollIndicator = NO;
    //mScrollView.contentSize = CGSizeMake(sW*2, mScrollView.frame.size.height);
    mScrollView.pagingEnabled = YES;
    mScrollView.delegate = self;
    [self.view addSubview:mScrollView];
    
    _mPhotoView = [[PhotoView alloc] initWithFrame:CGRectMake(0, 0, sW, sH)];
    _mPhotoView.delegate = self;
    _mPhotoView.hidden = YES;
    [self.view addSubview:_mPhotoView];
    
}


-(void)loadWatchForPayment:(BOOL)isPayment{
    float sW = [UIScreen mainScreen].bounds.size.width;
    float sH = [UIScreen mainScreen].bounds.size.height;

    isNeedPayment = isPayment;
    
    if(isNeedPayment == YES){
        mScrollView.frame = CGRectMake(0, kJL_HeightNavBar+50, sW, sH-kJL_HeightNavBar-50);
        mScrollView.contentSize = CGSizeMake(sW*3, mScrollView.frame.size.height);
        
        /*--- 表盘商城 ---*/
        CGRect rt = CGRectMake(10.0, 0, sW-20.0, mScrollView.frame.size.height);
        dialShopView = [[DialShopView alloc] initByFrame:rt IsPayment:YES];
        [mScrollView addSubview:dialShopView];
        
        /*--- 我的表盘 ---*/
        watchOwn = [[WatchOwn alloc] initByFrame:CGRectMake(sW, 0, sW, mScrollView.frame.size.height)];
        watchOwn.mWatchUiType = WatchUITypeDevice;
        watchOwn.superVC = self;
        [mScrollView addSubview:watchOwn];
        
        //自定义
        customView = [[CustomDialView alloc] initWithFrame:CGRectMake(sW*2, 0, sW, mScrollView.frame.size.height)];
        customView.superVC = self;
        [mScrollView addSubview:customView];
        

    }else{
        mScrollView.frame = CGRectMake(0, kJL_HeightNavBar, sW, sH-kJL_HeightNavBar);
        mScrollView.contentSize = CGSizeMake(sW, mScrollView.frame.size.height);

        /*--- 旧版本表盘API获取，无付费信息的表盘 ---*/
        CGRect rt = CGRectMake(10.0, 0, sW-20.0, mScrollView.frame.size.height);
        dialShopView = [[DialShopView alloc] initByFrame:rt IsPayment:NO];
        [mScrollView addSubview:dialShopView];
        
        /*--- 隐藏选择按钮 ---*/
        [self enableFreeOnlyWatchUI];
    }
    
    [self reflashUIData];
}


-(void)reflashUIData{
    /*--- 表盘商城 ---*/
    [dialShopView loadServerWatchIsPayment:isNeedPayment SuperVC:self];

    
    /*--- 我的表盘 ---*/
    [watchOwn reloadMyWatchInDevice];
}


- (IBAction)btn_back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [[note object] intValue];
    if (tp == JLDeviceChangeTypeBleOFF ||
        tp == JLDeviceChangeTypeInUseOffline) {
        [JLUI_Effect removeLoadingView];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


//-(void)moreWatchVC:(NSNotification*)note{
//    WatchUIType type = [[note object] intValue];
//    if (type == WatchUITypeFree) {
//        
//    }
//    if (type == WatchUITypePay) {
//        
//    }
//}

-(void)addNote{
    [JL_Tools add:kUI_WATCH_OWN_OPERATION Action:@selector(reflashUIData) Own:self];
    //[JL_Tools add:kUI_WATCH_OWN_MORE Action:@selector(moreWatchVC:) Own:self];
    
//    [JL_Tools add:@"kUI_PAY_OK" Action:@selector(reflashUIData) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:kUI_WATCH_OWN_OPERATION Own:self];
    //[JL_Tools remove:kUI_WATCH_OWN_MORE Own:self];
//    [JL_Tools remove:@"kUI_PAY_OK" Own:self];
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

//MARK: - photoView delegate

/// 拍照
- (void)takePhoto {
    _mPhotoView.hidden = YES;
    
    //创建UIImagePickerController实例
    imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    imagePickerController.delegate = self;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

/// 从相册选取
-(void)takePicture{
    _mPhotoView.hidden = YES;
    
    //创建UIImagePickerController实例
    imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.delegate = self;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = image.size.height * (width/image.size.width);
        UIImage * orImage = [image resizeImageWithSize:CGSizeMake(width, height)];
        CutImageViewController * con = [[CutImageViewController alloc] initWithImage:orImage delegate:self];
        [self.navigationController pushViewController:con animated:YES];
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
            [JL_Tools post:kUI_INSTALL_DIAL_SUCCESS Object:nil];
        }
    }];
}

@end
