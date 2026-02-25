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

@interface WatchLocalVC ()<UIScrollViewDelegate>{

    __weak IBOutlet UIButton            *btnManager;
    __weak IBOutlet NSLayoutConstraint  *titleView_H;
    __weak IBOutlet UILabel             *titleLabel;

    
    __weak IBOutlet UIButton    *btnShop;
    __weak IBOutlet UIButton    *btnMyFace;
    __weak IBOutlet UIView      *lb_0;
    __weak IBOutlet UIView      *lb_1;
    BOOL                        isMyFace;
    
    
    UIScrollView                *mScrollView;
    DialShopView                *dialShopView;
    WatchOwn                    *watchOwn;
    NSArray                     *mWatchsOfDevice;
    BOOL                        isNeedPayment;
}
@property(strong,nonatomic)NSMutableArray   *dataArray;
@end

@implementation WatchLocalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    titleLabel.text = kJL_TXT("表盘");
    
    [self selectMyWatch:NO];
    [self setupUI];
    [self addNote];
}


- (IBAction)btn_isManager:(id)sender {
    WatchHistoryVC *vc = [[WatchHistoryVC alloc] init];
    vc.modalPresentationStyle = 0;
    [self presentViewController:vc animated:YES completion:nil];
}

//选择【表盘商城】
- (IBAction)btnWatchShop:(id)sender {
    [self selectMyWatch:NO];
}

//选择【我的表盘】
- (IBAction)btnMyWatch:(id)sender {
    [self selectMyWatch:YES];
}

-(void)selectMyWatch:(BOOL)is{
    float sW = [DFUITools screen_2_W];
    float sH = [DFUITools screen_2_H];
    
    if (is == NO && isMyFace == YES) {
        [self enableShopUI];
        isMyFace = NO;
        [mScrollView scrollRectToVisible:CGRectMake(0, 0, sW, sH-kJL_HeightNavBar-50) animated:YES];
    }
    if (is == YES && isMyFace == NO) {
        [self enableWatchUI];
        isMyFace = YES;
        [mScrollView scrollRectToVisible:CGRectMake(sW, 0, sW, sH-kJL_HeightNavBar-50) animated:YES];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float sW = [DFUITools screen_2_W];

    int currentPostion = scrollView.contentOffset.x;
    if (currentPostion < sW) {
        [self enableShopUI];
    }else{
        [self enableWatchUI];
    }
}


-(void)enableShopUI{
    [btnShop setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnMyFace setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    lb_0.hidden = NO;
    lb_1.hidden = YES;
    isMyFace = NO;
    btnManager.hidden = NO;
}

-(void)enableWatchUI{
    [btnShop setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btnMyFace setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    lb_0.hidden = YES;
    lb_1.hidden = NO;
    isMyFace = YES;
    btnManager.hidden = NO;
}

-(void)enableFreeOnlyWatchUI{
    btnShop.hidden = YES;
    btnMyFace.hidden = YES;
    lb_0.hidden = YES;
    lb_1.hidden = YES;
    isMyFace = NO;
    
    btnManager.hidden = YES;
}


-(void)setupUI{
    float sW = [DFUITools screen_2_W];
    float sH = [DFUITools screen_2_H];
    titleView_H.constant = kJL_HeightNavBar;
    
    [btnShop setTitle:kJL_TXT("表盘商城") forState:UIControlStateNormal];
    [btnMyFace setTitle:kJL_TXT("我的表盘") forState:UIControlStateNormal];

    
    mScrollView = [[UIScrollView alloc] init];
    mScrollView.frame = CGRectMake(0, kJL_HeightNavBar+50, sW, sH-kJL_HeightNavBar-50);
    mScrollView.showsHorizontalScrollIndicator = NO;
    //mScrollView.contentSize = CGSizeMake(sW*2, mScrollView.frame.size.height);
    mScrollView.pagingEnabled = YES;
    mScrollView.delegate = self;
    [self.view addSubview:mScrollView];
}


-(void)loadWatchForPayment:(BOOL)isPayment{
    float sW = [DFUITools screen_2_W];
    float sH = [DFUITools screen_2_H];

    isNeedPayment = isPayment;
    
    if(isNeedPayment == YES){
        mScrollView.frame = CGRectMake(0, kJL_HeightNavBar+50, sW, sH-kJL_HeightNavBar-50);
        mScrollView.contentSize = CGSizeMake(sW*2, mScrollView.frame.size.height);
        
        /*--- 表盘商城 ---*/
        CGRect rt = CGRectMake(0, 0, sW, mScrollView.frame.size.height);
        dialShopView = [[DialShopView alloc] initByFrame:rt IsPayment:YES];
        [mScrollView addSubview:dialShopView];
        
        /*--- 我的表盘 ---*/
        watchOwn = [[WatchOwn alloc] initByFrame:CGRectMake(sW, 0, sW, mScrollView.frame.size.height)];
        watchOwn.mWatchUiType = WatchUITypeDevice;
        watchOwn.superVC = self;
        [mScrollView addSubview:watchOwn];

    }else{
        mScrollView.frame = CGRectMake(0, kJL_HeightNavBar, sW, sH-kJL_HeightNavBar);
        mScrollView.contentSize = CGSizeMake(sW, mScrollView.frame.size.height);

        /*--- 旧版本表盘API获取，无付费信息的表盘 ---*/
        CGRect rt = CGRectMake(0, 0, sW, mScrollView.frame.size.height);
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

@end
