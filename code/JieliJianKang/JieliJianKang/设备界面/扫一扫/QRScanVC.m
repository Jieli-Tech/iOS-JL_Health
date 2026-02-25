//
//  QRScanVC.m
//  JieliJianKang
//
//  Created by 李放 on 2021/4/1.
//

#import "QRScanVC.h"
#import "JL_RunSDK.h"
#import "HMScannerBorder.h"
#import "HMScannerMaskView.h"
#import "HMScanner.h"
#import "ScanConnectDeviceVC.h"
#import "AddDeviceVC.h"

/// 控件间距
#define kControlMargin  27.0
/// 相册图片最大尺寸
#define kImageMaxSize   CGSizeMake(1000, 1000)

@interface QRScanVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    /// 名片字符串
    NSString *cardName;
    /// 头像图片
    UIImage *avatar;
    
    /// 扫描框
    HMScannerBorder *scannerBorder;
    /// 扫描器
    HMScanner *scanner;
    /// 提示标签
    DFLabel *tipLabel;
    
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UIButton *backBtn;
        
    float sw;
    float sh;
}

@end

@implementation QRScanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (instancetype)initWithCardName:(NSString *)cardName avatar:(UIImage *)avatar completion:(void (^)(NSString *))completion {
    self = [super init];
    if (self) {
        cardName = cardName;
        avatar = avatar;
    }
    return self;
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(161, 162, 163, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    sw = [DFUITools screen_2_W];
    sh = [DFUITools screen_2_H];
    
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    subTitleView.backgroundColor = kDF_RGBA(161, 162, 163, 1.0);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("扫描二维码");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    [self prepareScanerBorder];
    [self prepareOtherControls];
    
    // 实例化扫描器
    scanner = [HMScanner scanerWithView:self.view scanFrame:scannerBorder.frame completion:^(NSString *stringValue) {
        NSLog(@"QR Scan ---> %@",stringValue);
     
        /*--- 已连接，则不触发扫描 ---*/
        if (kJL_BLE_EntityM) {
            return;
        }
        
        if (stringValue.length > 0) {
            NSData *scanData = [stringValue dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary*scanDict = [DFTools jsonWithData:scanData];
            
            NSString *edrText = scanDict[@"edrAddr"];
            NSString *nameText= scanDict[@"name"];

            if (edrText.length  == 0 ||
                nameText.length == 0) {
                [DFUITools showText:kJL_TXT("无效二维码") onView:self.view delay:1.0];
                return;
            }
            
            ScanConnectDeviceVC *vc = [[ScanConnectDeviceVC alloc] init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [vc setScanDict:scanDict];
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
            
        }else{
            [DFUITools showText:kJL_TXT("无效二维码") onView:self.view delay:1.0];
        }
    }];
    [scannerBorder startScannerAnimating];
    [scanner startScan];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *)resizeImage:(UIImage *)image {
    
    if (image.size.width < kImageMaxSize.width && image.size.height < kImageMaxSize.height) {
        return image;
    }
    
    CGFloat xScale = kImageMaxSize.width / image.size.width;
    CGFloat yScale = kImageMaxSize.height / image.size.height;
    CGFloat scale = MIN(xScale, yScale);
    CGSize size = CGSizeMake(image.size.width * scale, image.size.height * scale);
    
    UIGraphicsBeginImageContext(size);
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

- (void)prepareOtherControls {
    
    // 1> 提示标签
    tipLabel = [[DFLabel alloc] init];
    tipLabel.labelType = DFLeftRight;
    tipLabel.textAlignment = NSTextAlignmentLeft;
    tipLabel.text = kJL_TXT("将设备二维码放入方框中，即可自动扫描");
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    
    [tipLabel sizeToFit];
    if ([kJL_GET isEqualToString:@"en-GB"] || [kJL_GET isEqualToString:@"zh-Hans"]) {
        tipLabel.center = CGPointMake(scannerBorder.center.x, CGRectGetMaxY(scannerBorder.frame) + kControlMargin);
    }else{
        tipLabel.center = CGPointMake(scannerBorder.center.x+20, CGRectGetMaxY(scannerBorder.frame) + kControlMargin);
        tipLabel.bounds = CGRectMake(0, 0, 2*self.view.frame.size.width/3, 20);
    }
    
    [self.view addSubview:tipLabel];
    
    UIButton * flashBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    flashBtn.frame = CGRectMake(0, 0, 44, 44);
    flashBtn.center=CGPointMake(scannerBorder.center.x, tipLabel.frame.origin.y+tipLabel.frame.size.height+127);
    [flashBtn setBackgroundImage:[UIImage imageNamed:@"icon_light_nol"] forState:UIControlStateNormal];
    [flashBtn setBackgroundImage:[UIImage imageNamed:@"icon_light_sel"] forState:UIControlStateSelected];
    flashBtn.contentMode=UIViewContentModeScaleAspectFit;
    [flashBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    flashBtn.tag = 1;
    [self.view addSubview:flashBtn];
    
    UIButton * shoudongPeiBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    if ([kJL_GET isEqualToString:@"en-GB"] || [kJL_GET isEqualToString:@"zh-Hans"]) {
        shoudongPeiBtn.frame = CGRectMake(sw/2-150/2, flashBtn.frame.origin.y+flashBtn.frame.size.height+27, 150, 20);
    }else{
        shoudongPeiBtn.frame = CGRectMake(10, flashBtn.frame.origin.y+flashBtn.frame.size.height+27, sw-10, 20);
    }
    [shoudongPeiBtn setTitle:kJL_TXT("手动配对设备") forState:UIControlStateNormal];
    [shoudongPeiBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:14]];
    [shoudongPeiBtn setTitleColor:kDF_RGBA(85, 140, 255, 1.0) forState:UIControlStateNormal];
    shoudongPeiBtn.contentMode=UIViewContentModeScaleAspectFit;
    [shoudongPeiBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    shoudongPeiBtn.tag = 2;
    [self.view addSubview:shoudongPeiBtn];
}

// 准备扫描框和从图库中选择
- (void)prepareScanerBorder {
    
    CGFloat width = [DFUITools screen_2_W] - 68*2;
    scannerBorder = [[HMScannerBorder alloc] initWithFrame:CGRectMake([DFUITools screen_2_W]/2-width/2, kJL_HeightNavBar+120, width, width)];
    
    //scannerBorder.center = self.view.center;
    scannerBorder.tintColor = self.navigationController.navigationBar.tintColor;
    
    [self.view addSubview:scannerBorder];
    
    HMScannerMaskView *maskView = [HMScannerMaskView maskViewWithFrame:self.view.bounds cropRect:scannerBorder.frame];
    [self.view insertSubview:maskView atIndex:0];
    
    UIButton * tukuBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    tukuBtn.frame = CGRectMake(0, 0, 250, 21);
    tukuBtn.center=CGPointMake(scannerBorder.center.x, scannerBorder.frame.origin.y-32-21);
    [tukuBtn setTitle:kJL_TXT("从图库中选择") forState:UIControlStateNormal];
    [tukuBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:15]];
    [tukuBtn setTitleColor:kDF_RGBA(85, 140, 255, 1.0) forState:UIControlStateNormal];
    tukuBtn.contentMode=UIViewContentModeScaleAspectFit;
    [tukuBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    tukuBtn.tag = 0;
    [self.view addSubview:tukuBtn];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = [self resizeImage:info[UIImagePickerControllerOriginalImage]];
    
    // 扫描图像
    [HMScanner scaneImage:image completion:^(NSArray *values) {
        
        if (values.count > 0) {
            NSString *stringValue = values[0];
            NSData *scanData = [stringValue dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary*scanDict = [DFTools jsonWithData:scanData];
            
            NSString *edrText = scanDict[@"edrAddr"];
            NSString *nameText= scanDict[@"name"];

            if (edrText.length  == 0 ||
                nameText.length == 0) {
                [DFUITools showText:kJL_TXT("无效二维码") onView:self.view delay:1.0];
                return;
            }
            
            [self dismissViewControllerAnimated:NO completion:^{
                ScanConnectDeviceVC *vc = [[ScanConnectDeviceVC alloc] init];
                [vc setScanDict:scanDict];
                [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
            }];
        } else {
            self->tipLabel.text = @"没有识别到二维码，请选择其他照片";
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark-> 开关闪光灯
- (void)btnAction:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
        {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                tipLabel.text = @"无法访问相册";
                
                return;
            }
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            
            picker.view.backgroundColor = [UIColor whiteColor];
            picker.delegate = self;
            
            [self showDetailViewController:picker sender:nil];
        }
            break;
        case 1:
        {
            sender.selected = !sender.selected;
            if (sender.isSelected == YES) {
                //打开闪光灯
                AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                NSError *error = nil;
                
                if ([captureDevice hasTorch]) {
                    BOOL locked = [captureDevice lockForConfiguration:&error];
                    if (locked) {
                        captureDevice.torchMode = AVCaptureTorchModeOn;
                        [captureDevice unlockForConfiguration];
                    }
                }
            }else{
                //关闭闪光灯
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                if ([device hasTorch]) {
                    [device lockForConfiguration:nil];
                    [device setTorchMode: AVCaptureTorchModeOff];
                    [device unlockForConfiguration];
                }
            }
        }
            break;
        case 2:
        {
            [self.navigationController popViewControllerAnimated:YES];
            if (self.formRoot == 0) {
                AddDeviceVC *vc = [[AddDeviceVC alloc] init];
                [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        default:
            break;
    }
}


@end
