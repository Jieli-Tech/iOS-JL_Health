//
//  MyHealthVC.m
//  JieliJianKang
//
//  Created by EzioChan on 2022/11/2.
//

#import "MyHealthVC.h"
#import "HealthFuncView.h"

@interface MyHealthVC ()<JL_WatchProtocol>{
    __weak IBOutlet UIView   *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel  *titleName;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    HealthFuncView *funcView;
}

@end

@implementation MyHealthVC

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
    subTitleView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("健康");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, kJL_HeightStatusBar+20);
    
    funcView = [[HealthFuncView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:funcView];
    [funcView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(kJL_HeightNavBar);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
  
}

-(void)requireDataFromDevice{
    JLWearable *w = [JLWearable sharedInstance];
    [w w_addDelegate:self];
    
    [w w_InquireDeviceFuncWith:JL_WATCH_SETTING_SEDENTARY_REMIND|JL_WATCH_SETTING_CONTINUOUS_HEARTRATE_MEASUREMENT|JL_WATCH_SETTING_EXERCISE_HEARTRATE_REMINDER|JL_WATCH_SETTING_AUTOMATIC_PRESSURE_DETECTION|JL_WATCH_SETTING_SLEEP_DETECTION|JL_WATCH_SETTING_FALL_DETECTION withEntity:kJL_BLE_EntityM];
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
