//
//  BtCallViewController.m
//  JieliJianKang
//
//  Created by EzioChan on 2022/5/12.
//

#import "BtCallViewController.h"
#import "Masonry.h"
#import "UIImage+GIF.h"
#import <WebKit/WebKit.h>


@interface BtCallViewController ()<WKUIDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headTitleHeight;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *secondTitleLab;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UIButton *toSettingBtn;
@property (strong, nonatomic) UIView *tipsView;
@property (nonatomic,strong)UIImageView *settingConfigView;
@property (nonatomic,strong)WKWebView *webView;
@end

@implementation BtCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.headTitleHeight.constant = kJL_HeightNavBar+10;
    self.titleLab.text = kJL_TXT("手表蓝牙通话");
    self.secondTitleLab.text = kJL_TXT("手表蓝牙通话设置");
    self.contentLab.text = kJL_TXT("手表蓝牙通话设置提示信息");
    [self.toSettingBtn setTitle:kJL_TXT("去设置") forState:UIControlStateNormal];
    self.toSettingBtn.layer.cornerRadius = 24.0;
    self.tipsView = [UIView new];
    [self.view addSubview:self.tipsView];
    [self.tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLab.mas_bottom).offset(30);
        make.bottom.equalTo(self.toSettingBtn.mas_top).offset(-40);
        make.left.equalTo(self.view.mas_left).offset(50);
        make.right.equalTo(self.view.mas_right).offset(-50);
    }];
    
 
    self.settingConfigView = [UIImageView new];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"settingConfig" ofType:@"gif"];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    self.settingConfigView.image = [UIImage sd_animatedGIFWithData:imageData];
    self.settingConfigView.contentMode = UIViewContentModeScaleAspectFit;
    [self.tipsView addSubview:self.settingConfigView];
    [self.settingConfigView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.tipsView);
    }];
    
    [self addNote];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
}



- (IBAction)backBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)toSettingBtnAction:(id)sender {

//    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    uint8_t byte[] = {0x41,0x70,0x70,0x2D,0x50,0x72,0x65,0x66,0x73,0x3A};
    NSData *data = [NSData dataWithBytes:byte length:10];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:str];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {

            }];
        }else{
            [[UIApplication sharedApplication] openURL:url];
        }
    }
//    [EcApplication gotoSystemSetting];
}

- (void)noteDeviceChange:(NSNotification*)note {
    JLDeviceChangeType type = [[note object] integerValue];
    if (type == JLDeviceChangeTypeInUseOffline || type == JLDeviceChangeTypeBleOFF) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

- (void)dealloc {
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

@end
