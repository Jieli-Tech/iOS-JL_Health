//
//  DeviceMoreVC.m
//  JieliJianKang
//
//  Created by 李放 on 2021/7/21.
//

#import "DeviceMoreVC.h"
#import "MessageNoticeVC.h"
#import "SensorSettingsVC.h"
#import "TaiWanVC.h"
#import "MoreSettingView.h"


#define BT_WEATHER              @"BT_WEATHER"

@interface DeviceMoreVC ()<JL_WatchProtocol>{
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    
    MoreSettingView *moreView;

}

@end

@implementation DeviceMoreVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self addNote];
}

-(void)viewWillAppear:(BOOL)animated{
    [self requireDataFromDevice];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    float sw = [DFUITools screen_2_W];

    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("更多");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    moreView = [[MoreSettingView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:moreView];
    [moreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(kJL_HeightNavBar);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
}

-(void)requireDataFromDevice{
    JLWearable *w = [JLWearable sharedInstance];
    [w w_addDelegate:self];
    
    [w w_InquireDeviceFuncWith:JL_WATCH_SETTING_LIFTWRIST_DETECTION|JL_WATCH_SETTING_BLUETOOTH_DISCONECTED_REMINDER withEntity:kJL_BLE_EntityM];
}


- (IBAction)actionExit:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)removeNote{
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

-(void)dealloc{
    [self removeNote];
}

@end
