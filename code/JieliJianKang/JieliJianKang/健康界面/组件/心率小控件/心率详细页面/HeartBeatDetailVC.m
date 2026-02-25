//
//  HeartBeatDetailVC.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/26.
//

#import "HeartBeatDetailVC.h"
#import "SelectTitleBar.h"
#import "DateLabelView.h"
#import "HeartBeatDataView.h"
#import <CoreDraw/CoreDraw.h>
#import "JL_RunSDK.h"
#import "EcDateSelectView.h"
#import "DataOverRallPlanHeartRate.h"
#import "ContrastView.h"

typedef NS_ENUM(NSUInteger, HeartRateType) {
    HeartRateType_Range,
    HeartRateType_Resing,
};

@interface HeartBeatDetailVC ()<SelectActionDelegate,DateLabelViewDelegate,ECBrokenLineDelegate,EcDtSltDelegate,HeartBeatDataViewDelegate,UIScrollViewDelegate>{
    UIView *titleBarView;
    UIButton *backBtn;
    UILabel *titleLab;
    UIButton * dayBtn;
    SelectTitleBar *selectBar;
    DateLabelView *dateView;
    ECBrokenLine *brokenlineView;
    HeartBeatDataView *rangeView;
    HeartBeatDataView *restingHeartRateView;
    EcDateSelectView *ecDtSltv;
    

    DateType dType;
    NSDate *nowDate;
    HeartRateType hrt;

}

@end

@implementation HeartBeatDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = kDF_RGBA(246, 247, 248, 1);
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    UIScrollView *scView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    scView.delegate = self;
    scView.showsVerticalScrollIndicator = false;
    [self.view addSubview:scView];
    dType =     DateType_Day;
    
    titleBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, kJL_HeightNavBar+60)];
    titleBarView.backgroundColor = [JLColor colorWithString:@"#E96171"];
    titleBarView.alpha = 0;
    [self.view addSubview:titleBarView];
    
    backBtn = [[UIButton alloc] initWithFrame:CGRectMake(14, kJL_HeightNavBar-40, 40, 40)];
    [backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"icon_return_nol_white"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    
    titleLab = [[UILabel alloc] initWithFrame:CGRectMake(60, kJL_HeightNavBar-40, width-120, 40)];
    titleLab.textColor = kDF_RGBA(255, 255, 255, 1);
    titleLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    titleLab.text = kJL_TXT("心率");
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLab];
    
    dayBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-40-14, kJL_HeightNavBar-40, 40, 40)];
    [dayBtn addTarget:self action:@selector(dayBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [dayBtn setImage:[UIImage imageNamed:@"icon_calender_nol"] forState:UIControlStateNormal];
    [self.view addSubview:dayBtn];
    
    brokenlineView = [[ECBrokenLine alloc] initWithFrame:CGRectMake(0, -kJL_HeightNavBar, width, 550+kJL_HeightNavBar)];
    brokenlineView.startBgColor = [JLColor colorWithString:@"#E96171"];
    brokenlineView.endBgColor = [JLColor colorWithString:@"#EA4848"];
    brokenlineView.drawType = ECDrawBgc_TopToBottom;
    brokenlineView.ecTop = 260+kJL_HeightNavBar;
    brokenlineView.ecLeft = 20;
    brokenlineView.ecRight = 20;
    brokenlineView.ecBottom = 92;
    brokenlineView.maxValue = 200;
    brokenlineView.minValue = 40;
    brokenlineView.lineWidth = 1;
    brokenlineView.delegate = self;
    [scView addSubview:brokenlineView];
    
    selectBar = [[SelectTitleBar alloc] initWithFrame:CGRectMake(16, kJL_HeightNavBar+20, width-32, 34)];
    selectBar.selectColor = [UIColor redColor];
    selectBar.delegate = self;
    [self.view addSubview:selectBar];
    
    float mHeight = titleBarView.frame.size.height-kJL_HeightStatusBar;
    dateView = [[DateLabelView alloc] initWithFrame:CGRectMake(16, mHeight, width-32, 90)];
    dateView.delegate = self;
    [scView addSubview:dateView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 500, width, 380)];
    bottomView.backgroundColor = kDF_RGBA(246, 247, 248, 1);
    bottomView.layer.cornerRadius = 24;
    bottomView.layer.masksToBounds = YES;
    [scView addSubview:bottomView];
    
    rangeView = [[HeartBeatDataView alloc] initWithFrame:CGRectMake(24, 31, width-48, 60)];
    rangeView.tag = 0;
    rangeView.heartLab.text = kJL_TXT("心率范围");
    [rangeView hbMsgLabel:@"- -" Units:kJL_TXT("次/分钟")];
    rangeView.delegate = self;
    [bottomView addSubview:rangeView];
    
    restingHeartRateView = [[HeartBeatDataView alloc] initWithFrame:CGRectMake(24, 107, width-48, 60)];
    restingHeartRateView.delegate = self;
    restingHeartRateView.heartLab.text = kJL_TXT("静息心率");
    [restingHeartRateView hbMsgLabel:@"- -" Units:kJL_TXT("次/分钟")];
    restingHeartRateView.tag = 1;
    [bottomView addSubview:restingHeartRateView];
    
    [scView setContentSize:CGSizeMake(width, 550+kJL_HeightNavBar+167)];
    
    ecDtSltv = [[EcDateSelectView alloc] initWithFrame:CGRectMake(0, 0, width, [UIScreen mainScreen].bounds.size.height)];
    ecDtSltv.delegate = self;
    ecDtSltv.hidden = YES;
    [self.view addSubview:ecDtSltv];
    
    EcCap *eccap = [EcCap new];
    eccap.width = 1.5;
    eccap.radius = 4;
    eccap.borderColor = [UIColor whiteColor];
    eccap.fillColor = [UIColor orangeColor];
    brokenlineView.capType = eccap;
    
    hrt = HeartRateType_Range;
    [rangeView shadows:YES];
    nowDate = [NSDate new].toStartOfDate;
    [self checkOut];

}


-(void)backBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)dayBtnAction{
    ecDtSltv.hidden = NO;
}
#pragma mark 日期选择回调
-(void)ecDidDateSelected:(NSDate *)date{
    ecDtSltv.hidden = YES;
    nowDate = date;
    [self checkOut];
}

-(void)didSelected:(HeartBeatDataView *)hbdv{
    if (hbdv.tag == 0) {
        [restingHeartRateView shadows:NO];
        [brokenlineView removeLine];
        hrt = HeartRateType_Range;
    }else{
        [rangeView shadows:NO];
        if (dType ==     DateType_Day) {
            [DataOverRallPlanHeartRate heartRateDate:nowDate result:^(HeartRateModel * _Nonnull model) {
                if (model.res != 0) {
                    [self->brokenlineView addLineByColor:[UIColor greenColor] Num:model.res];
                }
            }];
        }
        hrt = HeartRateType_Resing;
    }
    [self checkOut];
}


//MARK:图表的代理回调
- (void)ecBrokenLine:(ECBrokenLine *)line dataValue:(NSInteger)value Index:(NSInteger)index{
    switch (dType) {
        case     DateType_Day:{
            [self dateLablRate:(int)value];
            NSTimeInterval t = [nowDate.toStartOfDate timeIntervalSince1970]+(index*60*5);
            NSDate *newData = [NSDate dateWithTimeIntervalSince1970:t];
            [dateView setSecondLab:newData.toHHmm];
            restingHeartRateView.heartLab.text = kJL_TXT("静息心率");
        }break;
            
        default:
            break;
    }
}

-(void)ecCapBrokenLine:(ECBrokenLine *)line dataValue:(ECPoint *)value Index:(NSInteger)index{
    [self ecHistogramPlus:line selectPoint:value];
}

-(void)ecHistogramPlus:(ECBrokenLine *)echp selectPoint:(ECPoint *)point{
    switch (dType) {
        case     DateType_Week:{
            [dateView setSecondLab:point.date.standardDate];
            NSString *hRate;
            if (point.maxY == 0 || point.minY == 0) {
                hRate = @"- -";
            }else{
                hRate = [NSString stringWithFormat:@"%d-%d",(int)point.minY,(int)point.maxY];
            }
            [self dateLabRateStr:hRate];
            restingHeartRateView.heartLab.text = kJL_TXT("静息心率");
            [self->rangeView hbMsgLabel:[NSString stringWithFormat:@"%d-%d",(int)point.minY,(int)point.maxY] Units:kJL_TXT("次/分钟")];
            [self->restingHeartRateView hbMsgLabel:[NSString stringWithFormat:@"%d",(int)point.resValue] Units:kJL_TXT("次/分钟")];
        }break;
        case     DateType_Month:{
            [dateView setSecondLab:point.date.toMMdd3];
            NSString *hRate;
            if (point.maxY == 0 || point.minY == 0) {
                hRate = @"- -";
            }else{
                hRate = [NSString stringWithFormat:@"%d-%d",(int)point.minY,(int)point.maxY];
            }
            [self dateLabRateStr:hRate];
            restingHeartRateView.heartLab.text = kJL_TXT("静息心率");
            [self->rangeView hbMsgLabel:[NSString stringWithFormat:@"%d-%d",(int)point.minY,(int)point.maxY] Units:kJL_TXT("次/分钟")];
            [self->restingHeartRateView hbMsgLabel:[NSString stringWithFormat:@"%d",(int)point.resValue] Units:kJL_TXT("次/分钟")];
        }break;
        case     DateType_Year:{
            [dateView setSecondLab:point.date.toMM];
            NSString *hRate;
            if (point.maxY == 0 || point.minY == 0) {
                hRate = @"- -";
            }else{
                hRate = [NSString stringWithFormat:@"%d-%d",(int)point.minY,(int)point.maxY];
            }
            [self dateLabRateStr:hRate];
            restingHeartRateView.heartLab.text = kJL_TXT("平均静息心率");
            [self->rangeView hbMsgLabel:[NSString stringWithFormat:@"%d-%d",(int)point.minY,(int)point.maxY] Units:kJL_TXT("次/分钟")];
            [self->restingHeartRateView hbMsgLabel:[NSString stringWithFormat:@"%d",(int)point.resValue] Units:kJL_TXT("次/分钟")];
        }break;
            
        default:
            break;
    }
}


//MARK:选中日期类型回调
-(void)barDidSelectIndex:(NSInteger)index{
    dType = index;
    if (dType>DateType_Week) {
        [dayBtn setHidden:YES];
    }else{
        if (dType == DateType_Week) {
            ecDtSltv.isWeek = true;
        }else{
            ecDtSltv.isWeek = false;
        }
        [dayBtn setHidden:NO];
    }
    [self checkOut];
}
//MARK:日期选择回调
-(void)dateLabelViewNextBtnAction{
    switch (dType) {
        case     DateType_Day:{
            nowDate = nowDate.next;
        }break;
        case     DateType_Week:{
            nowDate = nowDate.nextWeek;
        }break;
        case     DateType_Month:{
            nowDate = nowDate.nextMonth;
        }break;
        case     DateType_Year:{
            nowDate = nowDate.nextYear;
        }break;
        default:
            break;
    }
    [self checkOut];
}

-(void)dateLabelViewPreviousBtnAction{
    switch (dType) {
        case     DateType_Day:{
            nowDate = nowDate.before;
        }break;
        case     DateType_Week:{
            nowDate = nowDate.beforeWeek;
        }break;
        case     DateType_Month:{
            nowDate = nowDate.beforeMonth;
        }break;
        case     DateType_Year:{
            nowDate = nowDate.beforeYear;
        }break;
        default:
            break;
    }
    [self checkOut];
}


-(void)checkOut{
    switch (dType) {
        case     DateType_Day:{
            [DataOverRallPlanHeartRate heartRateDate:nowDate result:^(HeartRateModel * _Nonnull model) {
                self->brokenlineView.timeLabArray = @[@"00:00",@"06:00",@"12:00",@"18:00",@"00:00"];
                self->brokenlineView.dtNumber = 288;
                self->brokenlineView.lineType = BrokenLineType_Normal;
                self->brokenlineView.dataArray = model.pointArray;
                self->brokenlineView.pointColor = [UIColor greenColor];
                self->brokenlineView.bottomTextFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 10];
                [self->brokenlineView setNeedsDisplay];
                [self->dateView setTitleLab:self->nowDate.standardDate SecondLabel:@""];
                [self->rangeView hbMsgLabel:[NSString stringWithFormat:@"%d-%d",(int)model.min,(int)model.max] Units:kJL_TXT("次/分钟")];
                [self->restingHeartRateView hbMsgLabel:[NSString stringWithFormat:@"%d",(int)model.res] Units:kJL_TXT("次/分钟")];
                CGPoint P = [model.pointArray[0] CGPointValue];
                [self ecBrokenLine:self->brokenlineView dataValue:P.y Index:P.x];
            }];
            
        }break;
        case     DateType_Week:{
            StartAndEndDate *dates = nowDate.thisWeek;
            [DataOverRallPlanHeartRate heartRateWeekStart:dates.start toDate:dates.end result:^(NSArray<ECPoint *> * _Nonnull models) {
                self->brokenlineView.timeLabArray = @[kJL_TXT("我的周一"),kJL_TXT("我的周二"),kJL_TXT("我的周三"),kJL_TXT("我的周四"),kJL_TXT("我的周五"),kJL_TXT("我的周六"),kJL_TXT("我的周日")];
                self->brokenlineView.dtNumber = 7;
                if (self->hrt == HeartRateType_Range) {
                    self->brokenlineView.lineType = BrokenLineType_Histogram;
                    self->brokenlineView.dataArray = models;
                }else{
                    self->brokenlineView.lineType = BrokenLineType_CapNormal;
                    self->brokenlineView.dataCapArray = models;
                }
                self->brokenlineView.bottomTextFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 10];
                self->brokenlineView.cellColor = [UIColor whiteColor];
                [self->brokenlineView setPointTarget:0];
                self->brokenlineView.cellsWidth = 8;
                self->brokenlineView.pointColor = [UIColor whiteColor];
                [self->brokenlineView setNeedsDisplay];
                [self->dateView setTitleLab:[NSString stringWithFormat:@"%@-%@",dates.start.toYYYYMMdd2,dates.end.toYYYYMMdd2] SecondLabel:@""];
                [self ecHistogramPlus:self->brokenlineView selectPoint:models.firstObject];
            }];
        }break;
        case     DateType_Month:{
            StartAndEndDate *dates = nowDate.thisMonth;
            [DataOverRallPlanHeartRate heartRateMonthStart:dates.start toDate:dates.end result:^(NSArray<ECPoint *> * _Nonnull models) {
                self->brokenlineView.timeLabArray = self->nowDate.thisMonthDays;
                self->brokenlineView.dtNumber = self->nowDate.monthDayCount;
                self->brokenlineView.bottomTextFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 9];
                if (self->hrt == HeartRateType_Range) {
                    self->brokenlineView.lineType = BrokenLineType_Histogram;
                    self->brokenlineView.dataArray = models;
                }else{
                    self->brokenlineView.lineType = BrokenLineType_CapNormal;
                    self->brokenlineView.dataCapArray = models;
                }
                self->brokenlineView.cellColor = [UIColor whiteColor];
                [self->brokenlineView setPointTarget:0];
                self->brokenlineView.cellsWidth = 8;
                self->brokenlineView.pointColor = [UIColor whiteColor];
                [self->brokenlineView setNeedsDisplay];
                [self->dateView setTitleLab:[NSString stringWithFormat:@"%@-%@",dates.start.toYYYYMMdd2,dates.end.toYYYYMMdd2] SecondLabel:@""];
                [self ecHistogramPlus:self->brokenlineView selectPoint:models.firstObject];
            }];
        }break;
        case     DateType_Year:{
            StartAndEndDate *dates = nowDate.thisYear;
            [DataOverRallPlanHeartRate heartRateYearStart:dates.start toDate:dates.end result:^(NSArray<ECPoint *> * _Nonnull models) {
                self->brokenlineView.timeLabArray = self->nowDate.thisYearMonths;
                self->brokenlineView.dtNumber = 12;
                if (self->hrt == HeartRateType_Range) {
                    self->brokenlineView.lineType = BrokenLineType_Histogram;
                    self->brokenlineView.dataArray = models;
                }else{
                    self->brokenlineView.lineType = BrokenLineType_CapNormal;
                    self->brokenlineView.dataCapArray = models;
                }
                self->brokenlineView.cellColor = [UIColor whiteColor];
                [self->brokenlineView setPointTarget:0];
                self->brokenlineView.cellsWidth = 8;
                self->brokenlineView.pointColor = [UIColor whiteColor];
                self->brokenlineView.bottomTextFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 10];
                [self->brokenlineView setNeedsDisplay];
                [self->dateView setTitleLab:[NSString stringWithFormat:@"%@-%@",dates.start.toYYYYMMdd2,dates.end.toYYYYMMdd2] SecondLabel:@""];
                [self ecHistogramPlus:self->brokenlineView selectPoint:models.firstObject];
            }];
        }break;
        default:
            break;
    }
}


-(void)dateLablRate:(int)beat{

    NSString *beatStr;
    if (beat == 0) {
        beatStr = @"- -";
    }else{
        beatStr = [NSString stringWithFormat:@"%d",beat];
    }
    [self dateLabRateStr:beatStr];
}

-(void)dateLabRateStr:(NSString *)beatStr{
    // 属性文本生成器
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    NSString *stepStr = [NSString stringWithFormat:@"%@%@",beatStr,kJL_TXT("次/分钟")];
    textContainer.text = stepStr;
    
    // 整体设置属性
    textContainer.linesSpacing = 2;
    textContainer.paragraphSpacing = 5;
    textContainer.textAlignment = kCTTextAlignmentCenter;
    // 文字样式
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [stepStr rangeOfString:[NSString stringWithFormat:@"%@",beatStr]];
    textStorage.font = [UIFont fontWithName:@"PingFangSC-Medium" size:30];
    textStorage.textColor = kDF_RGBA(255, 255, 255, 1);
    [textContainer addTextStorage:textStorage];
    // 文字样式
    TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
    textStorage2.range = [stepStr rangeOfString:kJL_TXT("次/分钟")];
    textStorage2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    textStorage2.textColor = kDF_RGBA(255, 255, 255, 0.7);
    [textContainer addTextStorage:textStorage2];
    [dateView setTextWithContainer:textContainer];
}

//MARK: - scrollviewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float k = (scrollView.contentOffset.y+kJL_HeightStatusBar)/40.0;
    if (k<0) {
        k = 0.0f;
    }else if (k>1){
        k = 1.0f;
    }
    if (scrollView.contentOffset.y< -kJL_HeightStatusBar) {
        k = 1.0f;
    }
    titleBarView.alpha = k;
    
//    NSLog(@"scrollViewDidScroll:%f",scrollView.contentOffset.y);
}



////MARK:测试数据
//-(void)testData1{
//    NSMutableArray *tmp = [NSMutableArray new];
//    for (int i = 0; i<24*2; i++) {
//        if (i>10 && i<15) {
//
//            continue;
//        }
//        int k = arc4random()%200;
//        if (k<40) {
//            k = 40;
//        }
//
//        NSValue *v = [NSValue valueWithCGPoint:CGPointMake(i, k)];
//        [tmp addObject:v];
////        NSLog(@"x:%d,y:%d",i,k);
//    }
//    brokenlineView.timeLabArray = @[@"00:00",@"06:00",@"12:00",@"18:00",@"00:00"];
//    brokenlineView.dtNumber = 24*2;
//    brokenlineView.dataArray = tmp;
//    brokenlineView.isHistogram = NO;
//    [brokenlineView setNeedsDisplay];
//}

//-(void)testData2{
//    brokenlineView.dtNumber = 7;//一周七天
//    brokenlineView.isHistogram = YES;
//    brokenlineView.timeLabArray = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
//    NSMutableArray *array = [NSMutableArray new];
//    ECPoint *point0 = [ECPoint make:0 max:128 min:48];
//    [array addObject:point0];
//    ECPoint *point1 = [ECPoint make:1 max:160 min:46];
//    [array addObject:point1];
//    ECPoint *point2 = [ECPoint make:2 max:200 min:56];
//    [array addObject:point2];
//    ECPoint *point3 = [ECPoint make:3 max:180 min:60];
//    [array addObject:point3];
//    ECPoint *point4 = [ECPoint make:4 max:120 min:56];
//    [array addObject:point4];
//    ECPoint *point5 = [ECPoint make:5 max:220 min:46];
//    [array addObject:point5];
//    ECPoint *point6 = [ECPoint make:6 max:210 min:56];
//    [array addObject:point6];
//
//    brokenlineView.dataArray = array;
//    brokenlineView.cellsWidth = 8;
//    brokenlineView.cellColor = [UIColor whiteColor];
//
//    [brokenlineView setNeedsDisplay];
//}
//
//-(void)testData3{
//    brokenlineView.isHistogram = YES;
//    brokenlineView.dtNumber = 15;
//    brokenlineView.timeLabArray = @[@"1日",@"3日",@"5日",@"7日",@"8日",@"10日",@"12日",@"14日",@"17日",@"19日",
//                             @"21日",@"24日",@"26日",@"28日",@"30日"];
//    NSMutableArray *array = [NSMutableArray new];
//    ECPoint *point0 = [ECPoint make:0 max:120 min:40];
//    [array addObject:point0];
//    ECPoint *point1 = [ECPoint make:1 max:160 min:46];
//    [array addObject:point1];
//    ECPoint *point2 = [ECPoint make:2 max:200 min:56];
//    [array addObject:point2];
//    ECPoint *point3 = [ECPoint make:3 max:180 min:60];
//    [array addObject:point3];
//    ECPoint *point4 = [ECPoint make:4 max:120 min:56];
//    [array addObject:point4];
//    ECPoint *point5 = [ECPoint make:5 max:170 min:46];
//    [array addObject:point5];
//    ECPoint *point6 = [ECPoint make:6 max:170 min:56];
//    [array addObject:point6];
//
//    ECPoint *point7 = [ECPoint make:7 max:120 min:40];
//    [array addObject:point7];
//    ECPoint *point8 = [ECPoint make:8 max:160 min:46];
//    [array addObject:point8];
//    brokenlineView.dataArray = array;
//    brokenlineView.cellsWidth = 8;
//    brokenlineView.cellColor = [UIColor whiteColor];
//
//    [brokenlineView setNeedsDisplay];
//}
//
//-(void)testData4{
//    brokenlineView.dtNumber = 12;
//    brokenlineView.isHistogram = YES;
//    brokenlineView.timeLabArray = @[@"1月",@"2月",@"3月",@"4月",@"5月",@"6月",@"7月",@"8月",@"9月",@"10月",@"11月",@"12月"];
//    NSMutableArray *array = [NSMutableArray new];
//    ECPoint *point0 = [ECPoint make:0 max:120 min:40];
//    [array addObject:point0];
//    ECPoint *point1 = [ECPoint make:1 max:160 min:46];
//    [array addObject:point1];
//    ECPoint *point2 = [ECPoint make:2 max:170 min:56];
//    [array addObject:point2];
//    ECPoint *point3 = [ECPoint make:3 max:180 min:60];
//    [array addObject:point3];
//    ECPoint *point4 = [ECPoint make:4 max:120 min:56];
//    [array addObject:point4];
//    ECPoint *point5 = [ECPoint make:5 max:170 min:46];
//    [array addObject:point5];
//    ECPoint *point6 = [ECPoint make:6 max:170 min:56];
//    [array addObject:point6];
//
//    brokenlineView.dataArray = array;
//    brokenlineView.cellsWidth = 8;
//    brokenlineView.cellColor = [UIColor whiteColor];
//
//    [brokenlineView setNeedsDisplay];
//}




@end
