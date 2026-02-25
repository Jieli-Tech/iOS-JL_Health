//
//  WatchMoreVC.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2022/6/20.
//

#import "WatchMoreVC.h"
#import "JLPhoneUISetting.h"
#import "WatchMarket.h"
#import "JLUI_Effect.h"




@interface WatchMoreVC (){
    WatchUIType mWatchUiType;
    __weak IBOutlet UILabel *titlelabel;
    __weak IBOutlet NSLayoutConstraint *titlelabel_H;
    WatchOwn                    *watchOwn;

}

@end

@implementation WatchMoreVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //titlelabel.text = kJL_TXT("购买记录");
    [self setupUI];
    [self addNote];
}

-(void)setupUI{
    
    float sW = [DFUITools screen_2_W];
    float sH = [DFUITools screen_2_H];
    
    titlelabel_H.constant = kJL_HeightNavBar;
    
    /*--- 表盘 ---*/
    watchOwn = [[WatchOwn alloc] initByFrame:CGRectMake(0, kJL_HeightNavBar, sW, sH-kJL_HeightNavBar-10.0)];
    watchOwn.superVC = self;
    watchOwn.mSubTitleText = @"";
    watchOwn.mMoreBtnText  = @"";
    [self.view addSubview:watchOwn];
    
}

-(void)setWatchUiType:(WatchUIType)type{
    watchOwn.mWatchUiType = mWatchUiType;
    if (type == WatchUITypeFree) {
        titlelabel.text = kJL_TXT("免费表盘");
        [watchOwn reloadMyWatchForFree:-1];
    }
    if (type == WatchUITypePay) {
        titlelabel.text = kJL_TXT("付费表盘");
        [watchOwn reloadMyWatchForPay:-1];
    }
    mWatchUiType = type;
}


-(void)reflashUIData{
    if (mWatchUiType == WatchUITypeFree) [watchOwn reloadMyWatchForFree:-1];
    if (mWatchUiType == WatchUITypePay)  [watchOwn reloadMyWatchForPay:-1];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [[note object] intValue];
    if (tp == JLDeviceChangeTypeBleOFF ||
        tp == JLDeviceChangeTypeInUseOffline) {
        [JLUI_Effect removeLoadingView];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)addNote{
    [JL_Tools add:kUI_WATCH_OWN_OPERATION Action:@selector(reflashUIData) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:kUI_WATCH_OWN_OPERATION Own:self];
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

- (IBAction)btn_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
