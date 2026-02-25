//
//  JLSportMapViewController.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/12.
//

#import <UIKit/UIKit.h>
#import "JLSqliteSportLocation.h"

NS_ASSUME_NONNULL_BEGIN

@interface JLSportMapViewController : UIViewController

@property (assign, nonatomic) double sportID;
@property (assign, nonatomic) CGFloat sportTime;
@property (assign, nonatomic) UInt16 calories;
@property (assign, nonatomic) UInt16 speed;
@property (assign, nonatomic) Boolean isPauseSport;
//@property (strong, nonatomic) NSMutableArray<JL_SportLocation *> *sportLocationArr;

- (void)initMapView;

@end

NS_ASSUME_NONNULL_END
