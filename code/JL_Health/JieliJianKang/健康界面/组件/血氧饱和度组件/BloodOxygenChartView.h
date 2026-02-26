//
//  BloodOxygenChartView.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/22.
//

#import <UIKit/UIKit.h>
#import <CoreDraw/CoreDraw.h>
#import "SelectTitleBar.h"

@protocol BloodOxygenChartDelegate <NSObject>

-(void)BloodOxygenChartEcpoint:(ECPoint *_Nonnull)point;

-(void)bloodOxygenChartcheckLastDay;

@end

NS_ASSUME_NONNULL_BEGIN

@interface BloodOxygenChartView : UIView

@property(nonatomic,weak)id<BloodOxygenChartDelegate> delegate;

-(void)setByType:(DateType)type date:(NSDate *)date;

-(void)beType:(DateType)index;

@end

NS_ASSUME_NONNULL_END
