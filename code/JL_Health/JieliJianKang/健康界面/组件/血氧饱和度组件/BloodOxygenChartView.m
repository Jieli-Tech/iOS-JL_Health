//
//  BloodOxygenChartView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/22.
//

#import "BloodOxygenChartView.h"
#import "OxygenRefView.h"
#import "DataOverrallPlanBloodOxygen.h"

@interface BloodOxygenChartView()<ECHPlusDelegate>{
    NSMutableArray *hstArray;
}

@end

@implementation BloodOxygenChartView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        hstArray = [NSMutableArray new];
        for (int i = 0; i<4; i++) {
            ECHistogramPlus *histogram = [[ECHistogramPlus alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            
            histogram.presetNum = 24*2;//一天24小时，半小时测一下
            histogram.timeLabArray = @[@"00:00",@"06:00",@"12:00",@"18:00",@"00:00"];
            histogram.ecTop = 258+kJL_HeightNavBar;
            histogram.ecBottom = 80;
            histogram.units = @"%";
            histogram.delegatePlus = self;
            histogram.maxValue = 100;
            histogram.minValue = 85;
            histogram.lineClearance = 5;
            histogram.cellsWidth = 4;
            histogram.tag = i;
            [histogram setGradientLayer:[JLColor colorWithString:@"#E96171"] endColor:[JLColor colorWithString:@"#EA4848"]];
            histogram.drawType = ECDrawBgc_TopToBottom;
            [self addSubview:histogram];
            if (i == 0) {
                OxygenRefView *oDataView = [[OxygenRefView alloc] initWithFrame:CGRectMake(16, histogram.frame.size.height-60, self.frame.size.width-32, 20)];
                [histogram addSubview:oDataView];
            }else{
                histogram.hidden = YES;
            }
            [hstArray addObject:histogram];
        }
        ECHistogramPlus *his = hstArray[2];
        his.bottomTextFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 9];
        
    }
    return self;
}

-(void)setByType:(DateType)type date:(NSDate *)date{
    
    for (int i = 0; i<4; i++) {
        ECHistogramPlus *his = self->hstArray[i];
        if (i == (type)){
            his.hidden = NO;
        }else{
            his.hidden = YES;
        }
    }
    switch (type) {
        
        case DateType_Day:{
            [DataOverrallPlanBloodOxygen bloodOxygenByDate:date Result:^(BloodOxygenModel * _Nonnull model) {
                ECHistogramPlus *his = self->hstArray[0];
                his.presetNum = model.pointArray.count;
                his.timeLabArray = @[@"00:00",@"06:00",@"12:00",@"18:00",@"00:00"];
                his.dataArray = model.pointArray;
                his.cellColors = model.colors;
                [his setPointTarget:0];
                [his setNeedsDisplay];
                if ([self->_delegate respondsToSelector:@selector(BloodOxygenChartEcpoint:)]) {
                    [self->_delegate BloodOxygenChartEcpoint:model.pointArray.firstObject];
                }
            }];
            if ([_delegate respondsToSelector:@selector(bloodOxygenChartcheckLastDay)]) {
                [_delegate bloodOxygenChartcheckLastDay];
            }
            
        }break;
        case DateType_Week:{
            StartAndEndDate *dates = date.thisWeek;
            [DataOverrallPlanBloodOxygen bloodOxygenWeekStart:dates.start to:dates.end Result:^(BloodOxygenModel * _Nonnull model) {
                ECHistogramPlus *his = self->hstArray[1];
                his.presetNum = model.pointArray.count;
                his.timeLabArray = @[kJL_TXT("我的周一"),kJL_TXT("我的周二"),kJL_TXT("我的周三"),kJL_TXT("我的周四"),kJL_TXT("我的周五"),kJL_TXT("我的周六"),kJL_TXT("我的周日")];
                his.dataArray = model.pointArray;
                his.cellColors = model.colors;
                his.cellSelectedColor = [JLColor colorWithString:@"#FFC962"];
                [his setPointTarget:0];
                [his setNeedsDisplay];
                if ([self->_delegate respondsToSelector:@selector(BloodOxygenChartEcpoint:)]) {
                    [self->_delegate BloodOxygenChartEcpoint:model.pointArray.firstObject];
                }
            }];
        }break;
        case DateType_Month:{
            StartAndEndDate *dates = date.thisMonth;
            [DataOverrallPlanBloodOxygen bloodOxygenMonthStart:dates.start to:dates.end Result:^(BloodOxygenModel * _Nonnull model) {
                ECHistogramPlus *his = self->hstArray[2];
                his.presetNum = model.pointArray.count;
                his.timeLabArray = date.thisMonthDays;
                his.dataArray = model.pointArray;
                his.cellColors = model.colors;
                his.cellSelectedColor = [JLColor colorWithString:@"#FFC962"];
                [his setPointTarget:0];
                [his setNeedsDisplay];
                if ([self->_delegate respondsToSelector:@selector(BloodOxygenChartEcpoint:)]) {
                    [self->_delegate BloodOxygenChartEcpoint:model.pointArray.firstObject];
                }
            }];
        }break;
        case DateType_Year:{
            StartAndEndDate *dates = date.thisYear;
            [DataOverrallPlanBloodOxygen bloodOxygenYearStart:dates.start toDate:dates.end result:^(BloodOxygenModel * _Nonnull model) {
                ECHistogramPlus *his = self->hstArray[3];
                his.presetNum = model.pointArray.count;
                his.timeLabArray = date.thisYearMonths;
                his.dataArray = model.pointArray;
                his.cellColors = model.colors;
                his.cellSelectedColor = [JLColor colorWithString:@"#FFC962"];
                [his setPointTarget:0];
                [his setNeedsDisplay];
                if ([self->_delegate respondsToSelector:@selector(BloodOxygenChartEcpoint:)]) {
                    [self->_delegate BloodOxygenChartEcpoint:model.pointArray.firstObject];
                }
            }];
        }break;
        default:
            break;
    }
}

-(void)beType:(DateType)index{
    for (int i = 0; i<4; i++) {
        ECHistogramPlus *his = self->hstArray[i];
        if (i == (index)){
            his.hidden = NO;
        }else{
            his.hidden = YES;
        }
    }
}

- (void)ecHistogramPlus:(nonnull ECHistogramPlus *)echp selectPoint:(nonnull ECPoint *)point {
    if ([_delegate respondsToSelector:@selector(BloodOxygenChartEcpoint:)]) {
        [_delegate BloodOxygenChartEcpoint:point];
    }
}


@end
