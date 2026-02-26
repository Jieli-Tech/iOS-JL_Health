//
//  JLOutdoorSportThumbnailViewController.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/8.
//

#import "JLOutdoorSportThumbnailViewController.h"
#import "JLSportDetailViewController.h"
#import "JLPingTransition.h"
#import "JLGPSView.h"
#import "Masonry.h"
#import "JLSportLocationPermissionView.h"
#import <DFUnits/DFUnits.h>

@interface JLOutdoorSportThumbnailViewController () <MAMapViewDelegate, JLSportLocationPermissionViewDelegate, UINavigationControllerDelegate, LanguagePtl>

@property (strong, nonatomic) MAMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *gpsContainerView;
@property (strong, nonatomic) JLGPSView *gpsView;
@property (strong, nonatomic) JLSportLocationPermissionView *sportLocationPermissionView;

@end

@implementation JLOutdoorSportThumbnailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[LanguageCls share] add:self];
    
    self.gpsView = [JLGPSView gpsView];
    [self.gpsContainerView addSubview:self.gpsView];
    [self.gpsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    self.startLabel.text = kJL_TXT("开始");
    
    //设置高德地图
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-self.tabBarController.tabBar.height)];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.showsCompass = NO;
    self.mapView.userInteractionEnabled = NO;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.zoomLevel = 13;
    [self setMapViewLanguage];
    
    [self.view bringSubviewToFront:self.startBtnView];
    self.startBtnView.userInteractionEnabled = YES;
    self.startBtnView.layer.cornerRadius = self.startBtnView.width / 2;
    self.gpsContainerView.layer.cornerRadius = self.gpsContainerView.height / 2;
    
    self.view.userInteractionEnabled = YES;
    self.startBtnView.userInteractionEnabled = YES;
    self.startBtnView.layer.backgroundColor = [UIColor colorWithRed:128/255.0 green:91/255.0 blue:235/255.0 alpha:1.0].CGColor;
    self.startBtnView.layer.shadowColor = [UIColor colorWithRed:128/255.0 green:91/255.0 blue:235/255.0 alpha:0.47].CGColor;
    self.startBtnView.layer.shadowOffset = CGSizeMake(0,0);
    self.startBtnView.layer.shadowOpacity = 1;
    self.startBtnView.layer.shadowRadius = 12;
    self.startBtnView.tapBlock = ^{
        
        BOOL isOk = NO;
        
        /*--- 审核测试 ---*/
        UserProfile *pf = [[User_Http shareInstance] userPfInfo];
        if ([pf.mobile isEqual:kStoreIAP_MOBILE] ||
            [pf.email isEqual:kStoreIAP_MOBILE]) {
            isOk = YES;
        }
        if (kJL_BLE_EntityM) {
            isOk = YES;
        }
        
        if (isOk == YES) {
            JLDeviceConfigModel *model = [[JLDeviceConfig share] deviceGetConfigWithUUID:kJL_BLE_EntityM.mUUID];
            if (!model.healthFunc.spSportModel.spOutdoor) {
                [DFUITools showText:kJL_TXT("设备不支持") onView:JLApplicationDelegate.window.rootViewController.view delay:1.5f];
                return;
            }
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            switch (status) {
                case kCLAuthorizationStatusNotDetermined:
                case kCLAuthorizationStatusRestricted:
                case kCLAuthorizationStatusDenied: {
                    JLSportLocationPermissionView *sportLocationPermissionView = [JLSportLocationPermissionView sportLocationPermissionView];
                    sportLocationPermissionView.delegate = self;
                    self.sportLocationPermissionView = sportLocationPermissionView;
                    [JLApplicationDelegate.window.rootViewController.view addSubview:sportLocationPermissionView];
                }
                    break;
                case kCLAuthorizationStatusAuthorizedAlways:
                case kCLAuthorizationStatusAuthorizedWhenInUse: {
                    [self continueStartBtnFunction];
                }
                    break;
            }
        } else {
            [DFUITools showText:kJL_TXT("请先连接设备！") onView:JLApplicationDelegate.window.rootViewController.view delay:1.5f];
        }
    };
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.gpsView resetIntensityManagerDelegate];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    JLApplicationDelegate.navigationController.delegate = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Method

- (void)resetGpsViewIntensityManagerDelegate {
    [self.gpsView resetIntensityManagerDelegate];
}

#pragma mark - Private Method

- (void)startSportWithWearSyncInfoModel:(JLWearSyncInfoModel *)model  withNeedStartAnimation:(BOOL)needStartAnimation {
    JLSportDetailViewController *vc = [[JLSportDetailViewController alloc] init];
    JLApplicationDelegate.sportDetailVC = vc;
    vc.needStartAnimation = needStartAnimation;
    if (needStartAnimation) {
        JLApplicationDelegate.navigationController.delegate = self;
    } else {
        JLApplicationDelegate.navigationController.delegate = nil;
    }
    if (model) {
        vc.wearSyncInfoModel = model;
        if (model.sportType == 0x01) {
            vc.sportType = 0x01;
            vc.outdoorSportThumbnailViewController = self;
        } else {
            vc.sportType = 0x02;
        }
    } else {
        vc.sportType = 0x01;
        vc.outdoorSportThumbnailViewController = self;
    }
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
}

- (void)applicationBecomeActive {
    if (self.mapView.userLocation.updating && self.mapView.userLocation.location) {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    }
}

#pragma mark - JLSportLocationPermissionViewDelegate

- (void)cancelBtnFunction {
    [self.sportLocationPermissionView removeFromSuperview];
}

- (void)continueStartBtnFunction {
    [self.sportLocationPermissionView removeFromSuperview];
    
    BOOL isOk = NO;
    
    /*--- 审核测试 ---*/
    UserProfile *pf = [[User_Http shareInstance] userPfInfo];
    if ([pf.mobile isEqual:kStoreIAP_MOBILE]||
        [pf.email isEqual:kStoreIAP_MOBILE]) {
        isOk = YES;
    }
    
    if (kJL_BLE_EntityM) {
        isOk = YES;
    }
    
    
    if (isOk == YES) {
        [[JLWearSync share] w_requireSportInfoWith:kJL_BLE_EntityM Block:^(JLWearSyncInfoModel *infoModel) {
            if ((infoModel.sportID > 0) && (infoModel.sportType != 0x00) && ![JLApplicationDelegate.navigationController.viewControllers containsObject:JLApplicationDelegate.sportDetailVC]) {
                [self startSportWithWearSyncInfoModel:infoModel withNeedStartAnimation:NO];
            } else {
                [self startSportWithWearSyncInfoModel:nil withNeedStartAnimation:YES];
            }
        }];
    } else {
        [DFUITools showText:kJL_TXT("请先连接设备！") onView:JLApplicationDelegate.window.rootViewController.view delay:1.5f];
    }
}

- (void)settingBtnFunction {
    [self.sportLocationPermissionView removeFromSuperview];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary dictionary] completionHandler:nil];
}

#pragma mark - MAMapViewDelegate

- (void)mapViewRequireLocationAuth:(CLLocationManager *)locationManager {
    [locationManager requestAlwaysAuthorization];
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush) {
        JLPingTransition *pingTransition = [JLPingTransition new];
        return pingTransition;
    } else {
        return nil;
    }
}

#pragma mark - LanguagePtl

- (void)languageChange {
    [self setMapViewLanguage];
    self.startLabel.text = kJL_TXT("开始");
}

- (void)setMapViewLanguage {
    if ([[LanguageCls checkLanguage] isEqualToString:@"en-GB"] || [[LanguageCls checkLanguage] isEqualToString:@""]) {
        [self.mapView setMapLanguage:@(1)];
    } else {
        [self.mapView setMapLanguage:@(0)];
    }
}

@end

