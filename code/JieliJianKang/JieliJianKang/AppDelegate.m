//
//  AppDelegate.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/2/18.
//

#import "AppDelegate.h"
#import "JL_RunSDK.h"
#import "HealthVC.h"
#import "SportVC.h"
#import "DeviceSearchVC.h"
#import "MyVC.h"
#import "JL_RunSDK.h"
#import "LoginVC.h"
#import "OpenShowView.h"
#import "User_Http.h"
#import "NoNetView.h"
#import "RTCAlertSingle.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "JLStatementViewController.h"
#import "UserProfileVC.h"
#import "PrivacyPolicyVC.h"
#import "JLSportDetailViewController.h"
#import "FindPhoneView.h"

@interface AppDelegate () <LoginDelegate, JLStatementViewControllerDelegate,LanguagePtl> {
    LoginVC             *loginVC;
    FindPhoneView       *findView;
    NoNetView           *noNetView;
    UIViewController    *tempVC;
    NSArray             *arr_vc;
    UIViewController    *mainVC;
    JL_RunSDK           *bleSDK;
    UIAlertController *alertController;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (@available(iOS 15.0, *)) {
        [[UITableView appearance] setSectionHeaderTopPadding:0.0];
    }
    /*--- 设置屏幕常亮 ---*/
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    
    /*--- 记录NSLOG ---*/
    [JL_Tools openLogTextFile];

    NSLog(@"当前的语言:%@",[LanguageCls checkLanguage]);
    /*--- 检测当前语言 ---*/
    if ([kJL_GET hasPrefix:@"en-GB"]) {
        kJL_SET("en-GB");
    }else if ([kJL_GET hasPrefix:@"zh-Hans"]){
        kJL_SET("zh-Hans");
    }else if ([kJL_GET hasPrefix:@"ja"]){
        kJL_SET("ja");
    }else if ([kJL_GET hasPrefix:@"ko"]){
        kJL_SET("ko");
    }else if ([kJL_GET hasPrefix:@"fr"]){
        kJL_SET("fr");
    }else if ([kJL_GET hasPrefix:@"de"]){
        kJL_SET("de");
    }else if ([kJL_GET hasPrefix:@"it"]){
        kJL_SET("it");
    }else if ([kJL_GET hasPrefix:@"pt-PT"]){
        kJL_SET("pt-PT");
    }else if ([kJL_GET hasPrefix:@"es"]){
        kJL_SET("es");
    }else if ([kJL_GET hasPrefix:@"sv"]){
        kJL_SET("sv");
    }else if ([kJL_GET hasPrefix:@"pl"]){
        kJL_SET("pl");
    }else if ([kJL_GET hasPrefix:@"ru"]){
        kJL_SET("ru");
    }else if ([kJL_GET hasPrefix:@"tr"]){
        kJL_SET("tr");
    }else if ([kJL_GET hasPrefix:@"vi"]){
        kJL_SET("vi");
    }else if ([kJL_GET hasPrefix:@"he"]){
        kJL_SET("he");
    }else if ([kJL_GET hasPrefix:@"th"]){
        kJL_SET("th");
    }else if ([kJL_GET hasPrefix:@"ar"]){
        kJL_SET("ar");
    }else if ([kJL_GET hasPrefix:@"id"]){
        kJL_SET("id");
    }else if ([kJL_GET hasPrefix:@"ms"]){
        kJL_SET("ms");
    }else if ([kJL_GET hasPrefix:@"fa"]){
        kJL_SET("fa");
    }else{
        kJL_SET("auto");
    }
    
    [User_Http shareInstance];
    
    /*--- 网络监测 ---*/
    AFNetworkReachabilityManager *net = [AFNetworkReachabilityManager sharedManager];
    [net startMonitoring];
    
    /*--- 设置高德云SDK的apiKey ---*/
    [AMapServices sharedServices].apiKey = @"a815e58ecb9ce231ccd730a5c503ff2d";
    
    /*--- 初始化UI ---*/
    [self setupUI];
    
    /*--- 开启动画 ---*/
    [OpenShowView startOpenAnimation];
    
    /*--- 运行SDK ---*/
    [JL_RunSDK sharedMe];
    
    [self addNote];
    [self createDir];
    [[LanguageCls share] add:self];
    
    [JL_Tools add:@"kUI_SHOW_EDR_VIEW" Action:@selector(showConnectEdrView) Own:self];
    [JL_Tools add:kJL_BLE_M_EDR_CHANGE Action:@selector(noteEdrChange:) Own:self];
    
    [[SDImageCache sharedImageCache]clearMemory];
    [[SDImageCache sharedImageCache]clearDisk];
    NSString *watchFacePath = [DFFile findPath:NSLibraryDirectory MiddlePath:@"JL_WATCH_FACE" File:nil];
    [DFFile removePath:watchFacePath];
    
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"程序进入后台");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ENTER_BACKGROUND" object:nil userInfo:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"程序进入前台");
    if(!kJL_BLE_EntityM){
        [self reconnectToDevice];
    }
    [self checkCurrentSport];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BECOME_ACTIVE" object:nil userInfo:nil];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"程序即将销毁");
}

#pragma mark - 运动功能

/**
 *  检测当前是否有运动
 */
- (void)checkCurrentSport {
//    return;
    if (JLApplicationDelegate.sportDetailVC == nil && kJL_BLE_EntityM) {
        // 检索手表是否有运动进行中
        __weak typeof(self) weakSelf = self;
        [[JLWearSync share] w_requireSportInfoWith:kJL_BLE_EntityM Block:^(JLWearSyncInfoModel *infoModel) {
            [weakSelf pushSportDetailViewControllerWithWearSyncInfoModel:infoModel];
        }];
    }
}

-(void)checkConnectEdr{
    if(kJL_BLE_EntityM){
        if ([JL_RunSDK isConnectEdr:kJL_BLE_EntityM.mEdr]) {
            if (alertController) {
                [alertController dismissViewControllerAnimated:true completion:nil];
            }
        }else{
//            if (!alertController) {
                [self showConnectEdrView];
//            }
        }
    }else{
        if (alertController) {
            [DFAction delay:1 Task:^{
                [self->alertController dismissViewControllerAnimated:true completion:nil];
            }];
        }
    }
}



- (void)pushSportDetailViewControllerWithWearSyncInfoModel:(JLWearSyncInfoModel *)infoModel {
    if ((infoModel.sportID > 0) && (infoModel.sportType != WatchSportType_NonExercise) && ![JLApplicationDelegate.navigationController.viewControllers containsObject:JLApplicationDelegate.sportDetailVC]) {
        JLSportDetailViewController *vc = [[JLSportDetailViewController alloc] init];
        vc.wearSyncInfoModel = infoModel;
        JLApplicationDelegate.sportDetailVC = vc;
        vc.needStartAnimation = NO;
        if (infoModel.sportType == WatchSportType_OutDoor) {
            vc.sportType = WatchSportType_OutDoor;
            vc.outdoorSportThumbnailViewController = self.outdoorSportThumbnailVC;
        } else {
            vc.sportType = WatchSportType_InDoor;
        }
        if (![JLApplicationDelegate.navigationController.viewControllers containsObject:JLApplicationDelegate.sportDetailVC]) {
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - 创建文件夹
- (void)createDir {
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dataFilePath = [docsdir stringByAppendingPathComponent:@"music"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:dataFilePath isDirectory:&isDir];
    
    if (!(isDir && existed)) {
        // 在Document目录下创建一个archiver目录
        [fileManager createDirectoryAtPath:dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - 网络监测
- (void)actionNetStatus:(AFNetworkReachabilityStatus)status {
    if (status == AFNetworkReachabilityStatusNotReachable) {
        if(noNetView){
            noNetView.hidden = NO;
        }
    }
    if (status == AFNetworkReachabilityStatusUnknown) {
        if(noNetView){
            noNetView.hidden = NO;
        }
    }
    if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        if(noNetView){
            noNetView.hidden = YES;
        }
    }
    if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        if(noNetView){
            noNetView.hidden = YES;
        }
    }
}

- (void)noteNetworkStatus:(NSNotification*)note {
    AFNetworkReachabilityManager *net = note.object;
    NSLog(@"---> Network Status: %ld",(long)net.networkReachabilityStatus);
    [self actionNetStatus:net.networkReachabilityStatus];
}

- (void)setupUI {
    self.window =[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSString *accessToken = [JL_Tools getUserByKey:@"accessToken"];
    NSString *statement = [JL_Tools getUserByKey:@"statement"];
    if (accessToken.length > 0) {
        [self initData];
    }else if(statement.length>0){
        [self initLoginUI];
    }else {
        JLStatementViewController *statementVC = [[JLStatementViewController alloc] init];
        statementVC.delegate = self;
        self.window.rootViewController = statementVC;
        tempVC =[[UIViewController alloc] init];
        tempVC = statementVC;
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
    }
    if (findView == nil) {
        findView = [[FindPhoneView alloc] init];
        findView.hidden = YES;
    }
}

- (void)initLoginUI {
    self.tabBarController = nil;
    self.navigationController = nil;
    
    [JL_Tools mainTask:^{
        self->loginVC =[[LoginVC alloc] init];
        self->loginVC.delegate = self;
        self.window.rootViewController = self->loginVC;
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
    }];
}

-(void)loginAction:(NSString*)mobile {
    [self initData];
    NSLog(@"登录后回连设备...");
    [self reconnectToDevice];
    /*--- 审核测试 ---*/
    [JL_Tools delay:1.0 Task:^{
        [JL_Tools post:@"FOR_IOS_REVIEW" Object:mobile];
    }];
}

-(void)reconnectToDevice{
    
    NSString *accessToken = [JL_Tools getUserByKey:@"accessToken"];
    if (accessToken.length > 0) {
        NSLog(@"已登录回连设备...");
        [JL_Tools delay:0.2 Task:^{
            if (kJL_BLE_Multiple.bleManagerState == CBManagerStatePoweredOn){
                [JL_Tools post:@"kUI_RECONNECT_TO_DEVICE" Object:nil];
            }
        }];
    }
}


- (void)initData {
    mainVC = [self prepareViewControllers];
    
    noNetView = [[NoNetView alloc] initWithFrame:CGRectMake(0, 0, [DFUITools screen_2_W], [DFUITools screen_2_H])];
    [mainVC.view addSubview:noNetView];
    noNetView.hidden = YES;
    
    [RTCAlertSingle sharedInstance];
    
    // 获取用户信息
    [[User_Http shareInstance] requestGetUserConfigInfo:nil];

    self.window.rootViewController = mainVC;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
}

- (UIViewController *)prepareViewControllers {
    HealthVC *vc_1 = [HealthVC new];
    SportVC *vc_2 = [[SportVC alloc] initWithNibName:NSStringFromClass([SportVC class]) bundle:nil];
    self.sportVC = vc_2;
    DeviceSearchVC *vc_3 = [DeviceSearchVC new];
    MyVC *vc_4 = [MyVC new];

    UINavigationController *nvc_1 = [[UINavigationController alloc] initWithRootViewController:vc_1];
    UINavigationController *nvc_2 = [[UINavigationController alloc] initWithRootViewController:vc_2];
    UINavigationController *nvc_3 = [[UINavigationController alloc] initWithRootViewController:vc_3];
    UINavigationController *nvc_4 = [[UINavigationController alloc] initWithRootViewController:vc_4];
    
    arr_vc  = @[nvc_1, nvc_2, nvc_3, nvc_4];
    NSArray *arr_txt = @[kJL_TXT("健康"), kJL_TXT("运动"), kJL_TXT("设备"), kJL_TXT("我的")];
    NSArray *arr_img = @[@"tab_icon_health_nol", @"tab_icon_sports_nol", @"tab_icon_watch_nol", @"tab_icon_settle_nol"];
    NSArray *arr_img_sel = @[@"tab_icon_health_sel", @"tab_icon_sports_sel", @"tab_icon_watch_sel", @"tab_icon_settle_sel"];
    
    for (int i = 0 ; i < arr_vc.count; i++) {
        UINavigationController *nvc = arr_vc[i];
        /*--- TabBarItem的名字 ---*/
        nvc.tabBarItem.title = arr_txt[i];
        nvc.tabBarItem.tag = i;
        /*--- 使用原图片作为底部的TabBarItem ---*/
        UIImage *image     = [UIImage imageNamed:arr_img[i]];
        UIImage *image_sel = [UIImage imageNamed:arr_img_sel[i]];
        nvc.tabBarItem.image         = [self imageAlwaysOriginal:image];
        nvc.tabBarItem.selectedImage = [self imageAlwaysOriginal:image_sel];
        
        /*--- 隐藏底部 ---*/
        [nvc.tabBarController.tabBar setHidden:NO];
        
        /*--- 同时支持又滑返回功能的解决办法(隐藏顶部) ---*/
        nvc.navigationBarHidden = NO;
        nvc.navigationBar.hidden = YES;
    }
    
    JLTabBarController *tabBarVC  = [[JLTabBarController alloc] init];
    self.tabBarController = tabBarVC;
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        appearance.backgroundColor = [UIColor whiteColor];
        appearance.shadowColor = [UIColor clearColor];
        tabBarVC.tabBar.standardAppearance = appearance;
        if (@available(iOS 15.0, *)) {
            tabBarVC.tabBar.scrollEdgeAppearance = appearance;
        }
    }
    
    UINavigationController *main_nvc = [[UINavigationController alloc] initWithRootViewController:tabBarVC];
    self.navigationController = main_nvc;
    [self.navigationController.navigationBar setHidden:YES];
    tabBarVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    tabBarVC.tabBar.tintColor     = kDF_RGBA(128, 91, 235, 1);
    tabBarVC.tabBar.barTintColor  = [UIColor whiteColor];
    tabBarVC.viewControllers      = arr_vc;
    [tabBarVC setSelectedIndex:2];//跳至设备界面

    return main_nvc;
}


- (UIImage *)imageAlwaysOriginal:(UIImage *)image{
    UIImage *img = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

#pragma mark 监听token为空的情况
-(void)handleTokenISNull{
    if(kJL_BLE_EntityM){
        [kJL_BLE_Multiple disconnectEntity:kJL_BLE_EntityM Result:^(JL_EntityM_Status status) {
        }];
    }
    
    JLStatementViewController *statementVC = [[JLStatementViewController alloc] init];
    statementVC.delegate = self;
    self.window.rootViewController = statementVC;
    tempVC =[[UIViewController alloc] init];
    tempVC = statementVC;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [JL_Tools removeUserByKey:@"accessToken"];
}

- (void)addNote {
    [JL_Tools add:@"TOKEN_IS_NULL" Action:@selector(handleTokenISNull) Own:self];
    [JL_Tools add:@"LOGOUT" Action:@selector(initLoginUI) Own:self];
    [JL_Tools add:@"ENTER_MAIN_VC" Action:@selector(initData) Own:self];
    [JL_Tools add:AFNetworkingReachabilityDidChangeNotification Action:@selector(noteNetworkStatus:) Own:self];
    //监听查找手机的通知
    [JL_Tools add:kJL_MANAGER_FIND_PHONE Action:@selector(recivedVoiceNote:) Own:self];
}

- (void)dealloc {
    [JL_Tools remove:nil Own:self];
}

-(void)recivedVoiceNote:(NSNotification*)note{
   
    NSDictionary *noteDict = [note object];
    NSDictionary *dict = noteDict[kJL_MANAGER_KEY_OBJECT];
    if ([dict[@"op"] intValue] != 1) {
        return;
    }
    if (findView.hidden == YES) {
        findView.hidden = NO;
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        [win addSubview:findView];
        [findView startVoice];
    }
    
}

#pragma mark - JLStatementViewControllerDelegate

- (void)confirmCancelBtnAction {
    exit(0);
}

- (void)confirmConfirmBtnAction {
    [JL_Tools setUser:@"statement" forKey:@"statement"];
    [self initLoginUI];
}

- (void)confirmDidSelect:(int)index {
    if(index == 0){
        UserProfileVC *vc = [[UserProfileVC alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [tempVC presentViewController:vc animated:YES completion:nil];
    }
    if(index == 1){
        PrivacyPolicyVC *vc = [[PrivacyPolicyVC alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [tempVC presentViewController:vc animated:YES completion:nil];
    }
}

- (void)languageChange {
    NSArray *arr_txt = @[kJL_TXT("健康"), kJL_TXT("运动"), kJL_TXT("设备"), kJL_TXT("我的")];
    NSArray *arr_img = @[@"tab_icon_health_nol", @"tab_icon_sports_nol", @"tab_icon_watch_nol", @"tab_icon_settle_nol"];
    NSArray *arr_img_sel = @[@"tab_icon_health_sel", @"tab_icon_sports_sel", @"tab_icon_watch_sel", @"tab_icon_settle_sel"];
    
    for (int i = 0 ; i < arr_vc.count; i++) {
        UINavigationController *nvc = arr_vc[i];
        /*--- TabBarItem的名字 ---*/
        nvc.tabBarItem.title = arr_txt[i];
        
        /*--- 使用原图片作为底部的TabBarItem ---*/
        UIImage *image     = [UIImage imageNamed:arr_img[i]];
        UIImage *image_sel = [UIImage imageNamed:arr_img_sel[i]];
        nvc.tabBarItem.image         = [self imageAlwaysOriginal:image];
        nvc.tabBarItem.selectedImage = [self imageAlwaysOriginal:image_sel];
    }
}

#pragma - 经典蓝牙变化
-(void)noteEdrChange:(NSNotification*)note{
    if (bleSDK.mBleEntityM == nil) return;
    
    NSDictionary *dict = note.object;
    NSString *edr = dict[@"ADDRESS"];
    if (dict == nil || ![edr isEqual:bleSDK.mBleEntityM.mEdr]) {
        NSLog(@"---> 经典蓝牙没有对应当前设备.");
    }
}

#pragma - jingdian

#pragma - 经典蓝牙提示
-(void)showConnectEdrView{
    if (alertController) {
        [alertController dismissViewControllerAnimated:true completion:nil];
    }
    NSString *text;
    if([kJL_GET hasPrefix:@"zh"]){
        text = @"先在手机\"设置\"->\"蓝牙\"中选择您的设备进行连接。";
    }else{
        text = @"First, select your device in the phone \" Settings \"->\" Bluetooth \"";
    }
    alertController = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *endAction = [UIAlertAction actionWithTitle:kJL_TXT("好的") style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:endAction];
    [mainVC presentViewController:alertController animated:YES completion:nil];
    
}




-(TenAuthorizationStatus)bluetoothStatus {
    TenAuthorizationStatus status;
    switch ([CBPeripheralManager authorizationStatus]) {
        case CBPeripheralManagerAuthorizationStatusAuthorized:
            status = TenAuthorizationStatusAuthorized;
            break;
        case CBPeripheralManagerAuthorizationStatusNotDetermined:
            status = TenAuthorizationStatusNotDetermined;
            break;
        case CBPeripheralManagerAuthorizationStatusRestricted:
            status = TenAuthorizationStatusRestricted;
            break;
        default:
            status = TenAuthorizationStatusDenied;
            break;
    }
    return status;
}


@end


