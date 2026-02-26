//
//  AppDelegate.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/2/18.
//

#import <UIKit/UIKit.h>
#import <JL_BLEKit/JL_BLEKit.h>
#import <DFUnits/DFUnits.h>
#import "JLTabBarController.h"

typedef enum : NSUInteger {
    TenAuthorizationStatusAuthorized,
    TenAuthorizationStatusNotDetermined,
    TenAuthorizationStatusRestricted,
    TenAuthorizationStatusDenied
} TenAuthorizationStatus;

@class SportVC, JLSportDetailViewController, JLOutdoorSportThumbnailViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) JLTabBarController *tabBarController;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (weak, nonatomic) SportVC *sportVC;
@property (weak, nonatomic) JLSportDetailViewController *sportDetailVC;
@property (weak, nonatomic) JLOutdoorSportThumbnailViewController *outdoorSportThumbnailVC;

/**
 *  检测当前是否有运动
 */
- (void)checkCurrentSport;


@end

