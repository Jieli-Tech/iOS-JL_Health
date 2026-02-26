//
//  DialDetailVC.m
//  JieliJianKang
//
//  Created by 李放 on 2022/5/10.
//

#import "DialDetailVC.h"
#import "DialUICache.h"

#import "StoreIAPManager.h"
#import "JLUI_Effect.h"
#import "UIImageView+WebCache.h"
#import "JLWatchHttp.h"
#import "WatchMarket.h"
#import "WatchOwn.h"


@interface DialDetailVC (){
    UIScrollView *scrollView;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    __weak IBOutlet UILabel *titleName;
    UIImageView *topImv;                //表盘图片
    UILabel *mNameLabel;                //表盘名字
    UILabel *mPriceLabel;               //表盘价格
    UIView  *fenGenView;
    UILabel *dialIntroductionLabel;     //表盘简介
    UIButton *purchasesBtn;             //购买按钮
//    UILabel  *btnLabel;                 //按钮Text
    
    CAGradientLayer *gradientLayer;
        
    int                 stepCode; //0:购买 1:下载 2:传输 3:使用
    BOOL                isEnableOperate;//是否可操作
}

@end

@implementation DialDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    stepCode = 0;
    isEnableOperate = YES;
    
    [self initUI];
    [self addNote];
}

-(void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    titleHeight.constant = kJL_HeightNavBar;
    if (scrollView == nil) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kJL_HeightNavBar+40, width, height-kJL_HeightNavBar-40)];
        [self.view  addSubview:scrollView];
    }
    
    scrollView.backgroundColor = kDF_RGBA(255, 255, 255, 1.0);
    
    UIImageView *watchBg = [UIImageView new];
    watchBg.bounds = CGRectMake(0, 0, 254.0, 254.0);
    watchBg.center = CGPointMake(width/2.0, 254.0/2.0);
    watchBg.image = [UIImage imageNamed:@"img_watch_254"];
    watchBg.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:watchBg];
    
    topImv = [UIImageView new];
    topImv.bounds = CGRectMake(0, 0, 148, 148);
    topImv.center = CGPointMake(watchBg.frame.size.width/2.0, watchBg.frame.size.height/2.0);
    [topImv sd_setImageWithURL:[NSURL URLWithString:_dialModel.iconUrl] placeholderImage:[UIImage imageNamed:@"watch_img_06"]];
    topImv.contentMode = UIViewContentModeScaleAspectFit;
    [watchBg addSubview:topImv];
    
    mNameLabel = [[UILabel alloc] init];
    mNameLabel.frame = CGRectMake(width/2-150/2,watchBg.frame.origin.y+watchBg.frame.size.height+20,150,28);
    mNameLabel.numberOfLines = 1;
    mNameLabel.textAlignment = NSTextAlignmentCenter;
    mNameLabel.font =  [UIFont fontWithName:@"PingFangSC-Medium" size:20];
    mNameLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [scrollView addSubview:mNameLabel];
    
    mPriceLabel = [[UILabel alloc] init];
    mPriceLabel.frame = CGRectMake(width/2-120/2,mNameLabel.frame.origin.y+mNameLabel.frame.size.height+8,120,21);
    mPriceLabel.numberOfLines = 1;
    mPriceLabel.textAlignment = NSTextAlignmentCenter;
    mPriceLabel.font =  [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    mPriceLabel.textColor = kDF_RGBA(85, 140, 255, 1.0);
    [scrollView addSubview:mPriceLabel];
    
    if(self.dialModel.mPrice == 0.0f){
        mPriceLabel.text = [NSString stringWithFormat:@"%@",kJL_TXT("免费")];
    }else if(self.dialModel.mPrice != 0.0f){
        mPriceLabel.text = [NSString stringWithFormat:@"%@ %d",kJL_TXT("杰币"),(int)self.dialModel.mPrice];

        if (self.dialModel.mPrice < 1.0f) {
            mPriceLabel.text = [NSString stringWithFormat:@"%@ 1",kJL_TXT("杰币")];
        }
    }
    
    fenGenView = [[UIView alloc] init];
    fenGenView.frame = CGRectMake(24,mPriceLabel.frame.origin.y+mPriceLabel.frame.size.height+48,width-48,1);
    fenGenView.backgroundColor = kDF_RGBA(234, 234, 234, 1.0);
    [scrollView addSubview:fenGenView];
    
    dialIntroductionLabel = [[UILabel alloc] init];
    dialIntroductionLabel.frame = CGRectMake(24,fenGenView.frame.origin.y+fenGenView.frame.size.height+31,width-48,100);
    dialIntroductionLabel.numberOfLines = 5;
    dialIntroductionLabel.font =  [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    dialIntroductionLabel.textColor = kDF_RGBA(75, 75, 75, 1.0);
    [scrollView addSubview:dialIntroductionLabel];
    
    

    
    
    
    CGRect pRect = CGRectMake(24, dialIntroductionLabel.frame.origin.y+dialIntroductionLabel.frame.size.height+64, width-48, 48);
    purchasesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    purchasesBtn.frame = pRect;
//    purchasesBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
//    [purchasesBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [purchasesBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    purchasesBtn.layer.shadowColor = [UIColor clearColor].CGColor;
    purchasesBtn.layer.shadowOffset = CGSizeMake(0,1);
    purchasesBtn.layer.shadowOpacity = 1;
    purchasesBtn.layer.shadowRadius = 8;
    purchasesBtn.layer.borderWidth = 0.5;
    purchasesBtn.layer.borderColor = [UIColor clearColor].CGColor;
    purchasesBtn.layer.cornerRadius = 24;
    purchasesBtn.layer.masksToBounds = YES;
    [purchasesBtn setBackgroundColor:[UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0]];
    [purchasesBtn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:purchasesBtn];
    
    
//    btnLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width-48, 48)];
//    btnLabel.textColor = [UIColor whiteColor];
//    btnLabel.textAlignment = NSTextAlignmentCenter;
//    btnLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
//    [purchasesBtn addSubview:btnLabel];
    
    
    titleName.text = self.dialModel.watchName;
    mNameLabel.text = self.dialModel.watchName;
    dialIntroductionLabel.text = self.dialModel.dialIntroduce;
    
    scrollView.contentSize = CGSizeMake(width, 40+254+20+28+8+21+48+1+31+100+64+48);
    
    
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, purchasesBtn.frame.size.width, purchasesBtn.frame.size.height);
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 0);
    [gradientLayer setColors:@[(id)kDF_RGBA(128, 91, 235, 1.0),(id)[kDF_RGBA(209, 192, 246, 1.0) CGColor]]];//渐变数组
    gradientLayer.locations = @[@(1.0),@(1.0)];//渐变点
    [purchasesBtn.layer addSublayer:gradientLayer];
    
    
    
    
    if(self.dialModel.mPrice == 0.0f){
        [purchasesBtn setTitle:kJL_TXT("使用") forState:UIControlStateNormal];
        //btnLabel.text = kJL_TXT("使用");
    }else if(self.dialModel.mPrice != 0.0f){
        [purchasesBtn setTitle:kJL_TXT("购买") forState:UIControlStateNormal];
        //btnLabel.text = btnLabel.text = kJL_TXT("使用");
    }
}

#pragma mark 购买/使用
-(void)btnAction{
    
    if (isEnableOperate == NO) {
        return;
    }

    if (stepCode == 0) {
        isEnableOperate = NO;
        
        /*--- 支付流程 ---*/
        NSString *productID = self.dialModel.dict[@"productId"];
        NSString *shopID    = self.dialModel.dict[@"id"];
        NSLog(@"--->Please pay for it：%@",productID);
        
        /*--- 免费表盘 ---*/
        if (self.dialModel.mPrice == 0.0f) {
            [JLUI_Effect startLoadingView:kJL_TXT("下载中") Delay:60.0*10];
            [JLWatchHttp payForFreeDialShopID:shopID Result:^(NSDictionary * _Nonnull info) {
                [JL_Tools mainTask:^{
                    if (![info[@"data"] isEqual:[NSNull null]] && info ) {
                        BOOL isPay = [info[@"data"] boolValue];
                        if (isPay == YES) {
                            /*--- 刷新服务器 ---*/
                            [[WatchMarket sharedMe] searchAllWatchResult:^{
                                /*--- 下载表盘 ---*/
                                [self downloadWatch:self.dialModel.dict];
                            }];
                        }else{
                            UIWindow *win = [DFUITools getWindow];
                            [DFUITools showText:kJL_TXT("下载失败") onView:win delay:1.0];
                            [self setUIEndWithText:kJL_TXT("下载")];
                        }
                        [JLUI_Effect removeLoadingView];
                    }else{
                        [JLUI_Effect removeLoadingView];
                        [self setUIEndWithText:kJL_TXT("下载")];
                    }
                }];
            }];
            return;
        }
        
        
        /*--- 付费表盘 ---*/
        [JLUI_Effect startLoadingView:kJL_TXT("支付中") Delay:60.0*10];
        [[StoreIAPManager shareSIAPManager] startPurchWithID:productID
                                              completeHandle:^(SIAPPurchType type,
                                                               NSString *_Nonnull data){
            if (type == SIAPPurchVerSuccess) {
                [JL_Tools mainTask:^{
                    [JLUI_Effect setLoadingText:kJL_TXT("支付成功，等待支付结果...")];
                }];
                
                NSLog(@"Receipt ---> %@ [%@]",data, productID);
                
                BOOL isSanBox = NO;
                
                /*--- 审核测试 ---*/
                UserProfile *pf = [[User_Http shareInstance] userPfInfo];
                if ([pf.mobile isEqual:kStoreIAP_MOBILE]||
                    [pf.email isEqual:kStoreIAP_MOBILE]) {
                    isSanBox = YES;
                }
                
                [JLWatchHttp verifyReceipt:data isSandBox:isSanBox ShopID:shopID
                                    Result:^(NSDictionary * _Nonnull info) {
                    [JL_Tools mainTask:^{
                        NSLog(@"info ---> %@",info);

                        int code = [info[@"code"] intValue];
                        if (code == 0) {
                            
                            /*--- 刷新服务器 ---*/
                            [[WatchMarket sharedMe] searchAllWatchResult:^{
                                /*--- 下载表盘 ---*/
                                [self downloadWatch:self.dialModel.dict];
                            }];
 
                        }else{
                            //NSString *txt = [self massageOfCode:code];
                            self->isEnableOperate = YES;
                            UIWindow *win = [DFUITools getWindow];
                            [DFUITools showText:kJL_TXT("购买失败") onView:win delay:1.0];
                        }
                        [JLUI_Effect removeLoadingView];
                    }];
                }];
            }
            
            if (type != SIAPPurchasing & type != SIAPPurchSuccess) {
                self->isEnableOperate = YES;
                [JLUI_Effect removeLoadingView];
            }
        }];
    }
    
    if (stepCode == 1) {
        /*--- 下载表盘 ---*/
        [self downloadWatch:self.dialModel.dict];
    }
    
    if (stepCode == 2) {
        /*--- 传输表盘 ---*/
        [self onFatsAddResource:self.dialModel.dict];
    }
    
    if (stepCode == 3) {
        UIWindow *win = [DFUITools getWindow];

        /*--- 审核测试 ---*/
        UserProfile *pf = [[User_Http shareInstance] userPfInfo];
        if ([pf.mobile isEqual:kStoreIAP_MOBILE]||
            [pf.email isEqual:kStoreIAP_MOBILE]) {
            [DFUITools showText:@"已购买" onView:win delay:1.0];
            [JL_Tools post:kUI_WATCH_OWN_OPERATION Object:nil];
            return;
        }
        
        /*--- 使用表盘 ---*/
        [self setWatchFace:self.dialModel.dict];
    }
}


#pragma mark - 增加表盘
-(void)downloadWatch:(NSDictionary*)infoDict{
    UIWindow *win = [DFUITools getWindow];
    
    /*--- 审核测试 ---*/
    UserProfile *pf = [[User_Http shareInstance] userPfInfo];
    if ([pf.mobile isEqual:kStoreIAP_MOBILE]||
        [pf.email isEqual:kStoreIAP_MOBILE]) {
        [DFUITools showText:@"已购买" onView:win delay:1.0];
        [JL_Tools post:kUI_WATCH_OWN_OPERATION Object:nil];
        return;
    }
    
    stepCode = 1;
    isEnableOperate = NO;
        
    
    NSString *name = [infoDict[@"name"] uppercaseString];
    NSString *version = infoDict[@"version"];
    NSString *id_str = infoDict[@"id"];
    
    
    /*--- 8-6. 查询表盘下载链接，并下载表盘 ---*/
    [JLWatchHttp getDialDownloadUrlWithID:id_str Result:^(NSDictionary * _Nonnull info) {
        
        if (![info[@"data"] isEqual:[NSNull null]] && info) {
            NSString *url = info[@"data"][@"url"];
            
            NSString *path = [DialUICache getUpgradeFileName:name Version:version];
            if (path == nil) {
                path = [DialUICache listUpgradeFileName:name Version:version];
                NSLog(@"Add-->%@ %@ Url:%@",name,version,url);
                
                [JL_Tools mainTask:^{
                    [self setTaskProgress:0.0 Text:kJL_TXT("下载")];
                }];

                [[User_Http shareInstance] downloadUrl:url Path:path Result:^(float progress, JLHTTP_Result result) {
                    [JL_Tools mainTask:^{
                        if (result == JLHTTP_ResultDownload) {
                            /*--- 下载文件中 ---*/
                            [self setTaskProgress:progress Text:kJL_TXT("下载")];
                        }
                        if (result == JLHTTP_ResultSuccess) {
                            /*--- 添加表盘 ---*/
                            [self onFatsAddResource:infoDict];
                        }
                        if (result == JLHTTP_ResultFail) {
                            [JL_Tools removePath:path];
                            NSLog(@"-->删除下载失败的表盘：%@ %@",name,version);
                            [DFUITools showText:kJL_TXT("服务器开小差") onView:win delay:1.0];
                            
                            [self setUIEndWithText:kJL_TXT("下载")];
                        }
                    }];
                }];
            }else{
                [JL_Tools mainTask:^{
                    /*--- 添加表盘 ---*/
                    [self onFatsAddResource:infoDict];
                }];
            }
        }else{
            [JL_Tools mainTask:^{
                [self setUIEndWithText:kJL_TXT("下载")];
            }];
            NSLog(@"Err: Watch Url null");
        }
    }];
}


-(void)onFatsAddResource:(NSDictionary*)infoDict{
    stepCode = 2;
    self->isEnableOperate = NO;
    [self setTaskProgress:0.0 Text:kJL_TXT("添加进度")];
    
    
    NSString *name = [infoDict[@"name"] uppercaseString];
    NSString *version = infoDict[@"version"];
    
    NSString *wName = [NSString stringWithFormat:@"/%@",name];
    NSString *path = [DialUICache getUpgradeFileName:name Version:version];
    NSData *pathData = [NSData dataWithContentsOfFile:path];
    NSLog(@"-->添加表盘的大小:%lld",(long long)pathData.length);
    
    UIWindow *win = [DFUITools getWindow];
    
    if (pathData == 0) {
        NSLog(@"--->Add 表盘文件是空的。");
        [DFUITools showText:kJL_TXT("更新失败") onView:win delay:1.0];
        [self setUIEndWithText:kJL_TXT("添加表盘")];
        return;
    }
    
    [DialManager addFile:wName Content:pathData
                  Result:^(DialOperateType type, float progress)
    {
        if (type == DialOperateTypeCmdFail) {
            [DFUITools showText:kJL_TXT("添加失败") onView:win delay:1.0];
            [self setUIEndWithText:kJL_TXT("添加表盘")];
        }
        
        if (type == DialOperateTypeNoSpace) {
            [DFUITools showText:kJL_TXT("空间不足") onView:win delay:1.0];
            [self setUIEndWithText:kJL_TXT("添加表盘")];
        }
        if (type == DialOperateTypeFail) {
            [DFUITools showText:kJL_TXT("添加失败") onView:win delay:1.0];
            [self setUIEndWithText:kJL_TXT("添加表盘")];
        }
        if (type == DialOperateTypeDoing) {
            [self setTaskProgress:progress Text:kJL_TXT("添加进度")];
        }
        if (type == DialOperateTypeSuccess) {
            [DFUITools showText:kJL_TXT("添加完成") onView:win delay:1.0];
            [self setUIEndWithText:kJL_TXT("使用")];
            self->stepCode = 3;
            
            /*--- 更新缓存 ---*/
            [kJL_DIAL_CACHE addWatchListObject:name];
            [kJL_DIAL_CACHE addVersion:version toWatch:name];
            
            [JL_Tools post:kUI_WATCH_OWN_OPERATION Object:nil];
        }
    }];
}


-(void)setWatchFace:(NSDictionary*)infoDict{
    stepCode = 3;

    NSString *name = [infoDict[@"name"] uppercaseString];
    NSString *path = [NSString stringWithFormat:@"/%@",name];
    
    [kJL_BLE_CmdManager.mFlashManager cmdWatchFlashPath:path Flag:JL_DialSettingSetDial
                            Result:^(uint8_t flag, uint32_t size,
                                     NSString * _Nullable path,
                                     NSString * _Nullable describe) {
        [JL_Tools mainTask:^{
            if (flag == 0) {
                [kJL_DIAL_CACHE setCurrrentWatchName:name];
                UIWindow *win = [DFUITools getWindow];
                [DFUITools showText:kJL_TXT("设置成功") onView:win delay:1.0];
                [JL_Tools post:kUI_WATCH_OWN_OPERATION Object:nil];
            }
        }];
    }];
}


-(void)setTaskProgress:(float)progress Text:(NSString*)text{
    gradientLayer.locations = @[@(progress),@(progress)];//渐变点
    NSString *txt = [NSString stringWithFormat:@"%@... %.0f%%",text,progress*100.0f];
    [self->purchasesBtn setTitle:txt forState:UIControlStateNormal];
}

-(void)setUIEndWithText:(NSString*)text{
    [purchasesBtn setTitle:text forState:UIControlStateNormal];
    gradientLayer.locations = @[@(1.0),@(1.0)];
    isEnableOperate = YES;
}


-(NSString*)massageOfCode:(int)code{
    switch (code) {
        case -10044:
            return @"缺少必要参数";
            break;
        case -10045:
            return @"苹果服务器样子账单失败，请检查提交参数.";
            break;
        case -10046:
            return @"苹果服务器样子账单失败，请检查提交参数.";
            break;
        case -10047:
            return @"应用BundleID错误.";
            break;
        case -10048:
            return @"支付产品错误，一次只能创建一次.";
            break;
        case -10049:
            return @"产品ID错误.";
            break;
        case -10050:
            return @"当前账单未支付成功.";
            break;
        case -10051:
            return @"当前账单已经验证过，无法重复验证.";
            break;
        default:
            break;
    }
    return @"";
}


- (IBAction)backAction:(UIButton *)sender {
    if (isEnableOperate == NO) {
        return;
    }
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
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}
@end
