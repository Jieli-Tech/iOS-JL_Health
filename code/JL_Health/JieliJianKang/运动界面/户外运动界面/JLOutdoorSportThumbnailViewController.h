//
//  JLOutdoorSportThumbnailViewController.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/8.
//

#import <UIKit/UIKit.h>
#import "JLTapView.h"

NS_ASSUME_NONNULL_BEGIN

@interface JLOutdoorSportThumbnailViewController : UIViewController

@property (weak, nonatomic) IBOutlet JLTapView *startBtnView;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;

- (void)resetGpsViewIntensityManagerDelegate;

@end

NS_ASSUME_NONNULL_END
