//
//  MyTotalView.m
//  JieliJianKang
//
//  Created by 李放 on 2022/5/9.
//

#import "DialShopView.h"
//#import "DialModel.h"

#import "JLPhoneUISetting.h"
//#import "DialCustomView.h"
#import "WatchMarket.h"
#import "WatchOwn.h"



@interface DialShopView(){
    UIScrollView *scrollView;
    
    //WatchLocalView  *watchLocalView;
    //DialCustomView  *dialCustomView;
    
    WatchOwn *watchFreeView;
    WatchOwn *watchPayView;
    
    WatchOwn *watchNoPaymentView;
    
    float wacthView_H;
    CGFloat width;
    CGFloat height;
}
@end

@implementation DialShopView

- (instancetype)initByFrame:(CGRect)frame IsPayment:(BOOL)isPayment{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.frame = frame;
        
        wacthView_H = 370;
        
        width = [UIScreen mainScreen].bounds.size.width;
        height = [UIScreen mainScreen].bounds.size.height;
        
        if (scrollView == nil) {
            scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height-kJL_HeightNavBar-20)];
            [self addSubview:scrollView];
        }
        scrollView.backgroundColor = kDF_RGBA(255, 255, 255, 1.0);
        scrollView.showsVerticalScrollIndicator = NO;
        
        if (isPayment) {
            [self setupWatchFreeAndPay];
        } else {
            [self setupWatchNoPayment];
        }
    }
    return self;
}




-(void)setupWatchFreeAndPay{
    watchFreeView = [[WatchOwn alloc] initByFrame:CGRectMake(0, 0, width, wacthView_H)];
    watchFreeView.mWatchUiType = WatchUITypeFree;
    watchFreeView.mSubTitleText = kJL_TXT("免费表盘");
    watchFreeView.mMoreBtnText  = kJL_TXT("更多>");
    
    watchPayView = [[WatchOwn alloc] initByFrame:CGRectMake(0, watchFreeView.frame.size.height, width, wacthView_H)];
    watchPayView.mWatchUiType = WatchUITypePay;
    watchPayView.mSubTitleText = kJL_TXT("付费表盘");
    watchPayView.mMoreBtnText  = kJL_TXT("更多>");

    [scrollView addSubview:watchFreeView];
    [scrollView addSubview:watchPayView];
    scrollView.contentSize = CGSizeMake(width, wacthView_H*2.0+20);
}


-(void)setupWatchNoPayment{
    watchNoPaymentView = [[WatchOwn alloc] initByFrame:CGRectMake(0, 0, width, height-kJL_HeightNavBar-20)];
    watchNoPaymentView.mWatchUiType = WatchUITypeNoPayment;
    [scrollView addSubview:watchNoPaymentView];
    scrollView.contentSize = CGSizeMake(width, height-kJL_HeightNavBar-20);
}




-(void)setSuperVC:(UIViewController *)superVC{
    watchFreeView.superVC = superVC;
    watchPayView.superVC = superVC;
    watchNoPaymentView.superVC = superVC;
    _superVC = superVC;
}




-(void)loadServerWatchIsPayment:(BOOL)isPayment SuperVC:(UIViewController *)superVC{
    if (isPayment) {
        NSArray *watchsOfFree = [[WatchMarket sharedMe] watchListFree];
        NSArray *watchsOfPay = [[WatchMarket sharedMe] watchListPay];
        
        if (watchsOfFree.count <= 3) {
            watchFreeView.frame = CGRectMake(0, 0, width, wacthView_H/2.0+20.0);
        }else{
            watchFreeView.frame = CGRectMake(0, 0, width, wacthView_H);
        }
        
        if (watchsOfPay.count <= 3) {
            watchPayView.frame = CGRectMake(0, watchFreeView.frame.size.height, width, wacthView_H/2.0+20.0);
        }else{
            watchPayView.frame = CGRectMake(0, watchFreeView.frame.size.height, width, wacthView_H);
        }
        [watchFreeView reloadMyWatchForFree:6];
        [watchPayView reloadMyWatchForPay:6];
    }else{
        [watchNoPaymentView reloadMyWatchForNoPayment];
    }
    [self setSuperVC:superVC];
}



@end
