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
@property (assign, nonatomic) WatchSportType sportType;
@property (assign, nonatomic) BOOL needStartAnimation;

@property (nonatomic, weak) JLOutdoorSportThumbnailViewController *outdoorSportThumbnailViewController;

@end

NS_ASSUME_NONNULL_END
