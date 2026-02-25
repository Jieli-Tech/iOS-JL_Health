//
//  WatchHistoryVC.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2022/5/13.
//

#import "WatchHistoryVC.h"
#import "JLUI_Effect.h"
#import "WatchOwn.h"


@interface WatchHistoryVC (){
    __weak IBOutlet UILabel             *titlelabel;
    __weak IBOutlet NSLayoutConstraint  *titlelabel_H;
    __weak IBOutlet UIImageView         *subImage;
    __weak IBOutlet UILabel             *subLabel;
    
    WatchOwn *watchOwn;
}

@end

@implementation WatchHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    titlelabel.text = kJL_TXT("购买记录");
    subLabel.text   = kJL_TXT("暂无购买记录");
    [self setupUI];
    [self addNote];
}

-(void)setupUI{
    
    float sW = [DFUITools screen_2_W];
    float sH = [DFUITools screen_2_H];
    
    titlelabel_H.constant = kJL_HeightNavBar;
    
    /*--- 我的表盘 ---*/
    watchOwn = [[WatchOwn alloc] initByFrame:CGRectMake(0, kJL_HeightNavBar, sW, sH-kJL_HeightNavBar-10.0)];
    watchOwn.mWatchUiType = WatchUITypeHistory;
    [self.view addSubview:watchOwn];
    
    [self reflashUIData];
}

-(void)reflashUIData{
    NSInteger count = [watchOwn reloadMyWatchInHistory];
    if (count > 0) {
        subImage.hidden = YES;
        subLabel.hidden = YES;
    }else{
        subImage.hidden = NO;
        subLabel.hidden = NO;
    }
}

- (IBAction)btn_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
