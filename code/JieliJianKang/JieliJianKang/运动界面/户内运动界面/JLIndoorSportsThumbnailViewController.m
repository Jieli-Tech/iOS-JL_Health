//
//  JLIndoorSportsThumbnailViewController.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/8.
//

#import "JLIndoorSportsThumbnailViewController.h"
#import "JLSportDetailViewController.h"
#import "JLPingTransition.h"

@interface JLIndoorSportsThumbnailViewController () <UINavigationControllerDelegate, LanguagePtl>

@end

@implementation JLIndoorSportsThumbnailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[LanguageCls share] add:self];
    
    self.startLabel.text = kJL_TXT("开始");
    
    self.startBtnView.userInteractionEnabled = YES;
    self.startBtnView.layer.cornerRadius = self.startBtnView.width / 2;
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
        if ([pf.mobile isEqual:kStoreIAP_MOBILE]||
            [pf.email isEqual:kStoreIAP_MOBILE]) {
            isOk = YES;
        }
        if (kJL_BLE_EntityM) {
            isOk = YES;
        }
        
        if (isOk == YES) {
            JLDeviceConfigModel *model = [[JLDeviceConfig share] deviceGetConfigWithUUID:kJL_BLE_EntityM.mUUID];
            if (!model.healthFunc.spSportModel.spIndoor) {
                [DFUITools showText:kJL_TXT("设备不支持") onView:JLApplicationDelegate.window.rootViewController.view delay:1.5f];
                return;
            }
            
            [[JLWearSync share] w_requireSportInfoWith:kJL_BLE_EntityM Block:^(JLWearSyncInfoModel *infoModel) {
                if ((infoModel.sportID > 0) && (infoModel.sportType != WatchSportType_NonExercise) && ![JLApplicationDelegate.navigationController.viewControllers containsObject:JLApplicationDelegate.sportDetailVC]) {
                    [self startSportWithWearSyncInfoModel:infoModel withNeedStartAnimation:NO];
                } else {
                    [self startSportWithWearSyncInfoModel:nil withNeedStartAnimation:YES];
                }
            }];
        } else {
            [DFUITools showText:kJL_TXT("请先连接设备！") onView:JLApplicationDelegate.window.rootViewController.view delay:1.5f];
        }
    };
}

#pragma mark - Private Method

- (void)startSportWithWearSyncInfoModel:(JLWearSyncInfoModel *)model withNeedStartAnimation:(BOOL)needStartAnimation {
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
        if (model.sportType == WatchSportType_OutDoor) {
            vc.sportType = WatchSportType_OutDoor;
            vc.outdoorSportThumbnailViewController = JLApplicationDelegate.outdoorSportThumbnailVC;
        } else {
            vc.sportType = WatchSportType_InDoor;
        }
    } else {
        vc.sportType = WatchSportType_InDoor;
    }
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
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
    self.startLabel.text = kJL_TXT("开始");
}

@end
