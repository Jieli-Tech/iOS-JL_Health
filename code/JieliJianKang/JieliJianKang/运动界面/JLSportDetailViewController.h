//
//  JLSportDetailViewController.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/8.
//

#import <UIKit/UIKit.h>
#import "SportVC.h"

NS_ASSUME_NONNULL_BEGIN

@class JLOutdoorSportThumbnailViewController;

@interface JLSportDetailViewController : UIViewController

@property (strong, nonatomic) JLWearSyncInfoModel *wearSyncInfoModel;

/// 0x00 无运动
/// 0x01 户外跑步
/// 0x02 室内跑步
@property (assign, nonatomic) uint8_t sportType;
@property (assign, nonatomic) BOOL needStartAnimation;

@property (nonatomic, weak) JLOutdoorSportThumbnailViewController *outdoorSportThumbnailViewController;

@end

NS_ASSUME_NONNULL_END
