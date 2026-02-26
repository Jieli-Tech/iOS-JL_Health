//
//  MessageNoticeVC.m
//  JieliJianKang
//
//  Created by 李放 on 2021/5/25.
//

#import "MessageNoticeVC.h"
#import "JL_RunSDK.h"

#define TONGZHI  @"TONGZHI"
#define WEIXIN   @"WEIXIN"
#define QQ       @"QQ"
#define XINXI    @"XINXI"
#define QITA     @"QITA"

@interface MessageNoticeVC (){
    
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    UIView *view1;
    UIView *view2;
    UIView *weixinView;   //微信的View
    UIView *qqView;       //QQ的View
    UIView *xinxiView;    //信息的View
    UIView *view3;
}

@end

@implementation MessageNoticeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self addNote];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    
    float sw = [UIScreen mainScreen].bounds.size.width;
    //float sh = [UIScreen mainScreen].bounds.size.height;
    titleHeight.constant = kJL_HeightNavBar;
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("消息通知");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    CGFloat height = kJL_HeightNavBar;
    
    view1 = [[UIView alloc] initWithFrame:CGRectMake(0, height+8, sw, 60)];
    [self.view addSubview:view1];
    view1.backgroundColor = [UIColor whiteColor];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(16,19,sw-60,21);
    label1.numberOfLines = 0;
    [view1 addSubview:label1];
    label1.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label1.text =  kJL_TXT("通知");
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UISwitch *swtich = [[UISwitch alloc] initWithFrame:CGRectMake(sw-50-12, view1.frame.size.height/2-15, 50, 30)];
    swtich.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    swtich.on = YES;
    int v1 = [[[NSUserDefaults standardUserDefaults] valueForKey:TONGZHI] intValue];
    if (v1 == 0) {
        swtich.on = NO;
    }
    [swtich addTarget:self action:@selector(tongzhiAlert:) forControlEvents:UIControlEventValueChanged];
    [view1 addSubview:swtich];
    
    view2 = [[UIView alloc] initWithFrame:CGRectMake(0, view1.frame.origin.y+view1.frame.size.height+8, sw, 180)];
    [self.view addSubview:view2];
    view2.backgroundColor = [UIColor whiteColor];
    
    weixinView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, 60)];
    [view2 addSubview:weixinView];
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.frame = CGRectMake(16,19,sw-60,21);
    label2.numberOfLines = 0;
    [weixinView addSubview:label2];
    label2.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label2.text =  kJL_TXT("微信");
    label2.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UISwitch *swtich2 = [[UISwitch alloc] initWithFrame:CGRectMake(sw-50-12, view1.frame.size.height/2-15, 50, 30)];
    swtich2.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    swtich2.on = YES;
    int v2 = [[[NSUserDefaults standardUserDefaults] valueForKey:WEIXIN] intValue];
    if (v2 == 0) {
        swtich2.on = NO;
    }
    [swtich2 addTarget:self action:@selector(weixinAlert:) forControlEvents:UIControlEventValueChanged];
    [weixinView addSubview:swtich2];
    
    UIView *fenge1 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sw-32, 1)];
    [weixinView addSubview:fenge1];
    fenge1.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    qqView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, sw, 60)];
    [view2 addSubview:qqView];
    
    UILabel *label3 = [[UILabel alloc] init];
    label3.frame = CGRectMake(16,19,sw-60,21);
    label3.numberOfLines = 0;
    [qqView addSubview:label3];
    label3.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label3.text =  kJL_TXT("QQ");
    label3.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UISwitch *swtich3 = [[UISwitch alloc] initWithFrame:CGRectMake(sw-50-12, view1.frame.size.height/2-15, 50, 30)];
    swtich3.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    swtich3.on = YES;
    int v3 = [[[NSUserDefaults standardUserDefaults] valueForKey:QQ] intValue];
    if (v3 == 0) {
        swtich3.on = NO;
    }
    [swtich3 addTarget:self action:@selector(qqAlert:) forControlEvents:UIControlEventValueChanged];
    [qqView addSubview:swtich3];
    
    UIView *fenge2 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sw-32, 1)];
    [qqView addSubview:fenge2];
    fenge2.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    xinxiView = [[UIView alloc] initWithFrame:CGRectMake(0, 120, sw, 60)];
    [view2 addSubview:xinxiView];
    
    UILabel *label4 = [[UILabel alloc] init];
    label4.frame = CGRectMake(16,19,sw-60,21);
    label4.numberOfLines = 0;
    [xinxiView addSubview:label4];
    label4.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label4.text =  kJL_TXT("信息");
    label4.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UISwitch *swtich4 = [[UISwitch alloc] initWithFrame:CGRectMake(sw-50-12, view1.frame.size.height/2-15, 50, 30)];
    swtich4.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    swtich4.on = YES;
    int v4 = [[[NSUserDefaults standardUserDefaults] valueForKey:XINXI] intValue];
    if (v4 == 0) {
        swtich4.on = NO;
    }
    [swtich4 addTarget:self action:@selector(xinxiAlert:) forControlEvents:UIControlEventValueChanged];
    [xinxiView addSubview:swtich4];
    
    view3 = [[UIView alloc] initWithFrame:CGRectMake(0, view2.frame.origin.y+view2.frame.size.height+8, sw, 60)];
    [self.view addSubview:view3];
    view3.backgroundColor = [UIColor whiteColor];
    
    UILabel *label5 = [[UILabel alloc] init];
    label5.frame = CGRectMake(16,19,sw-60,21);
    label5.numberOfLines = 0;
    [view3 addSubview:label5];
    label5.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label5.text =  kJL_TXT("其他");
    label5.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UISwitch *swtich5 = [[UISwitch alloc] initWithFrame:CGRectMake(sw-50-12, view3.frame.size.height/2-15, 50, 30)];
    swtich5.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    swtich5.on = YES;
    int v5 = [[[NSUserDefaults standardUserDefaults] valueForKey:QITA] intValue];
    if (v5 == 0) {
        swtich5.on = NO;
    }
    [swtich5 addTarget:self action:@selector(qitaAlert:) forControlEvents:UIControlEventValueChanged];
    [view3 addSubview:swtich5];
}


#pragma mark 设置通知消息通知
-(void)tongzhiAlert:(UISwitch *)sender{
    int value = sender.on;
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",value] forKey:TONGZHI];
}

#pragma mark 设置微信消息通知
-(void)weixinAlert:(UISwitch *)sender{
    int value = sender.on;
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",value] forKey:WEIXIN];
}

#pragma mark 设置QQ消息通知
-(void)qqAlert:(UISwitch *)sender{
    int value = sender.on;
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",value] forKey:QQ];
}

#pragma mark 设置信息消息通知
-(void)xinxiAlert:(UISwitch *)sender{
    int value = sender.on;
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",value] forKey:XINXI];
}

#pragma mark 设置QQ消息通知
-(void)qitaAlert:(UISwitch *)sender{
    int value = sender.on;
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",value] forKey:QITA];
}


- (IBAction)backExit:(UIButton *)sender {
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
