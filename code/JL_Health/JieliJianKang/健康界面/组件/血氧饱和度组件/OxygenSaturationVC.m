//
//  OxygenSaturationVC.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/30.
//

#import "OxygenSaturationVC.h"
#import "SelectTitleBar.h"
#import "DateLabelView.h"
#import "OxygenRefView.h"
#import "JL_RunSDK.h"
#import "OxygenDataView.h"
#import "EcDateSelectView.h"
#import "BloodOxygenChartView.h"
#import "JLSqliteOxyhemoglobinSaturation.h"

@interface OxygenSaturationVC ()<BloodOxygenChartDelegate,SelectActionDelegate,DateLabelViewDelegate,EcDtSltDelegate,UIScrollViewDelegate>{
    UIView *titleBarView;
    OxygenRefView *refview;
    OxygenRefView *oDataView;
    DateLabelView *dateView;
    SelectTitleBar *selectBar;
    BloodOxygenChartView *histograms;
    UIScrollView *scView;
    UIButton *backBtn;
    UILabel *titleLab;
    UIButton *dayBtn;
    UIView *customView;
    OxygenDataView *dataView;
    EcDateSelectView *ecDtSltv;
    
    DateType dtype;
    NSDate *nowDate;
    
}

@end

@implementation OxygenSaturationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    scView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    scView.backgroundColor = kDF_RGBA(246, 247, 248, 1);
    scView.delegate = self;
    scView.showsVerticalScrollIndicator = false;
    [self.view addSubview:scView];
    [scView setContentOffset:CGPointMake(0, 0)];
    [scView setContentSize:CGSizeMake(width, 550+kJL_HeightNavBar+167)];
    
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
    titleLab.text = kJL_TXT("血氧饱和度");
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLab];
    
    dayBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-40-14, kJL_HeightNavBar-40, 40, 40)];
    [dayBtn addTarget:self action:@selector(dayBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [dayBtn setImage:[UIImage imageNamed:@"icon_calender_nol"] forState:UIControlStateNormal];
    [self.view addSubview:dayBtn];
    
    histograms = [[BloodOxygenChartView alloc] initWithFrame:CGRectMake(0, -kJL_HeightNavBar, width, 524+kJL_HeightNavBar)];
    histograms.delegate = self;
    [scView addSubview:histograms];
  
    
    selectBar = [[SelectTitleBar alloc] initWithFrame:CGRectMake(16, kJL_HeightNavBar+20, width-32, 34)];
    selectBar.selectColor = [UIColor redColor];
    selectBar.delegate = self;
    [self.view addSubview:selectBar];
    
    float mHeight =  titleBarView.frame.size.height-kJL_HeightStatusBar;
    dateView = [[DateLabelView alloc] initWithFrame:CGRectMake(16, mHeight, width-32,210)];
    dateView.delegate = self;
    [scView addSubview:dateView];
    
    customView = [[UIView alloc] initWithFrame:CGRectMake(0, 500, width, 312)];
    customView.backgroundColor = kDF_RGBA(246, 247, 248, 1);
    customView.layer.cornerRadius = 20;
    customView.layer.masksToBounds = YES;
    [scView addSubview:customView];
    
    dataView = [[OxygenDataView alloc] initWithFrame:CGRectMake(20, 24, width-40, 80)];
    [customView addSubview:dataView];

    ecDtSltv = [[EcDateSelectView alloc] initWithFrame:CGRectMake(0, 0, width, [UIScreen mainScreen].bounds.size.height)];
    ecDtSltv.delegate = self;
    ecDtSltv.hidden = YES;
    [self.view addSubview:ecDtSltv];

    nowDate = [NSDate new];
    dtype = DateType_Day;
    [histograms setByType:dtype date:nowDate];
//    [self testData1];
}

-(void)backBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)dayBtnAction{
    ecDtSltv.hidden = NO;
}

//MARK: 日历选择回调
-(void)ecDidDateSelected:(NSDate *)date{
    nowDate = date;
    ecDtSltv.hidden = YES;
    [histograms setByType:dtype date:nowDate];
}

//MARK: ECHistogramPlus delegate
- (void)BloodOxygenChartEcpoint:(ECPoint *)point{
    switch (dtype) {
        case DateType_Day:{
            NSString *labelTxt = [NSString stringWithFormat:@"%@-%@",point.date.toHHmm,[NSDate dateWithTimeInterval:60*5 sinceDate:point.date].toHHmm];
            
            [dateView setTitleLab:point.date.standardDate SecondLabel:labelTxt];
            [self dateLabDataP:point.maxY];
        }break;
        case DateType_Week:{
            StartAndEndDate *dates = nowDate.thisWeek;
            [dateView setTitleLab:[NSString stringWithFormat:@"%@-%@",dates.start.toYYYYMMdd2,dates.end.toYYYYMMdd2] SecondLabel:point.date.toMMdd3];
            [self dateLabDataS:[NSString stringWithFormat:@"%d%%-%d%%",(int)point.minY,(int)point.maxY]];
            [dataView oxyMyMaxValue:point.maxY];
            [dataView oxyMyMinValue:point.minY];
        }break;
        case DateType_Month:{
            StartAndEndDate *dates = nowDate.thisMonth;
            [dateView setTitleLab:[NSString stringWithFormat:@"%@-%@",dates.start.toYYYYMMdd2,dates.end.toYYYYMMdd2] SecondLabel:point.date.toMMdd3];
            [self dateLabDataS:[NSString stringWithFormat:@"%d%%-%d%%",(int)point.minY,(int)point.maxY]];
            [dataView oxyMyMaxValue:point.maxY];
            [dataView oxyMyMinValue:point.minY];
        }break;
        case DateType_Year:{
            StartAndEndDate *dates = nowDate.thisYear;
            [dateView setTitleLab:[NSString stringWithFormat:@"%@-%@",dates.start.toYYYYMMdd2,dates.end.toYYYYMMdd2] SecondLabel:point.date.toMMdd3];
            [self dateLabDataS:[NSString stringWithFormat:@"%d%%-%d%%",(int)point.minY,(int)point.maxY]];
            [dataView oxyMyMaxValue:point.maxY];
            [dataView oxyMyMinValue:point.minY];
        }break;
        default:
            break;
    }
}

-(void)bloodOxygenChartcheckLastDay{
    [JLSqliteOxyhemoglobinSaturation s_checkoutTheLastDataWithResult:^(JL_Chart_OxyhemoglobinSaturation * _Nonnull chart) {
        if (chart) {
            int count = (int)chart.bloodOxyganlist.lastObject.bloodOxygans.count;
            NSDate *newDate = [NSDate dateWithTimeInterval:chart.interval*60*count sinceDate:chart.bloodOxyganlist.lastObject.startDate];
            [self->dataView oxyLastTime:newDate Value:[chart.bloodOxyganlist.lastObject.bloodOxygans.lastObject intValue]];
            [self->dataView oxyMaxValue:(int)chart.maxValue minValue:(int)chart.minValue];
        }else{
            [self->dataView oxyLastTime:[NSDate new] Value:0];
            [self->dataView oxyMaxValue:0 minValue:0];
        }
    }];
}

//MARK: select delegate
-(void)barDidSelectIndex:(NSInteger)index{
    dtype = index;
    if (dtype>DateType_Week) {
        [dayBtn setHidden:YES];
    }else{
        if (dtype == DateType_Week) {
            ecDtSltv.isWeek = true;
        }else{
            ecDtSltv.isWeek = false;
        }
        [dayBtn setHidden:NO];
    }
    [histograms setByType:dtype date:nowDate];
    [self updateDateRightBtnStatus];
    
}
//MARK: Date Label delegate
-(void)dateLabelViewNextBtnAction{
    switch (dtype) {
        case DateType_Day:{
            nowDate = nowDate.next;
            
        }break;
        case DateType_Week:{
            nowDate = nowDate.nextWeek;
            
        }break;
        case DateType_Month:{
            nowDate = nowDate.nextMonth;
            
        }break;
        case DateType_Year:{
            nowDate = nowDate.nextYear;
            
        }break;
        default:
            break;
    }
    [self updateDateRightBtnStatus];
    [histograms setByType:dtype date:nowDate];
}

-(void)dateLabelViewPreviousBtnAction{
    switch (dtype) {
        case DateType_Day:{
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
    [self updateDateRightBtnStatus];
    [histograms setByType:dtype date:nowDate];
}

-(void)updateDateRightBtnStatus{
    switch (dtype) {
        case DateType_Day:{
            dateView.rightBtn.hidden = !nowDate.beforeNow_0;
        }break;
        case DateType_Week:{
            dateView.rightBtn.hidden = !nowDate.beforeThisWeek_0;
        }break;
        case DateType_Month:{
            dateView.rightBtn.hidden = !nowDate.beforeThisMonth_0;
        }break;
        case DateType_Year:{
            dateView.rightBtn.hidden = !nowDate.beforeThisYear_0;
        }break;
        default:
            break;
    }
}


-(void)dateLabDataP:(int)percent{
    // 属性文本生成器
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    NSString *targetStatus;
    NSString *stepStr;
    if (percent == 0){
        targetStatus = @"- -";
        stepStr = [NSString stringWithFormat:@"%@",targetStatus];
    }else{
        targetStatus = [NSString stringWithFormat:@"%d%@",percent,@"%"];
        stepStr = [NSString stringWithFormat:@"%@%@",targetStatus,kJL_TXT("平均")];
    }
     
    textContainer.text = stepStr;
    
    // 整体设置属性
    textContainer.linesSpacing = 2;
    textContainer.paragraphSpacing = 5;
    textContainer.textAlignment = kCTTextAlignmentCenter;
    // 文字样式
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [stepStr rangeOfString:[NSString stringWithFormat:@"%@",targetStatus]];
    
    textStorage.font = [UIFont fontWithName:@"PingFangSC-Medium" size:30];
    textStorage.textColor = kDF_RGBA(255, 255, 255, 1);
    [textContainer addTextStorage:textStorage];

    // 文字样式
    TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
    textStorage2.range = [stepStr rangeOfString:kJL_TXT("平均")];
    textStorage2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    textStorage2.textColor = kDF_RGBA(255, 255, 255, 0.7);
    [textContainer addTextStorage:textStorage2];
    
    [dateView setTextWithContainer:textContainer];
}

-(void)dateLabDataS:(NSString *)persents{
    NSString *stepStr = [NSString stringWithFormat:@"%@",persents];
    NSString *range = persents;
    if ([persents isEqualToString:@"0%-0%"]){
        stepStr = [NSString stringWithFormat:@"- -"];
        range = stepStr;
    }
    // 属性文本生成器
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    textContainer.text = stepStr;
    
    // 整体设置属性
    textContainer.linesSpacing = 2;
    textContainer.paragraphSpacing = 5;
    textContainer.textAlignment = kCTTextAlignmentCenter;
    // 文字样式
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [stepStr rangeOfString:[NSString stringWithFormat:@"%@",range]];
    textStorage.font = [UIFont fontWithName:@"PingFangSC-Medium" size:30];
    textStorage.textColor = kDF_RGBA(255, 255, 255, 1);
    [textContainer addTextStorage:textStorage];
    
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



//MARK: TEST DATA
//
//-(void)testData1{
//    histogram.presetNum = 24*2;//一天24小时，半小时测一下
//    histogram.timeLabArray = @[@"00:00",@"06:00",@"12:00",@"18:00",@"00:00"];
//    NSMutableArray *array = [NSMutableArray new];
//    NSMutableArray *carray = [NSMutableArray new];
//    for (int i = 0; i<24*2; i++) {
//        int x = arc4random()%15+85;
//        ECPoint *point0 = [ECPoint make:i max:x min:85];
//        UIColor *color;
//        if (x>90) {
//            color = kDF_RGBA(138, 202, 146, 1);
//        }else{
//            color = kDF_RGBA(255, 187, 42, 1);
//        }
//        [carray addObject:color];
//        [array addObject:point0];
//    }
//    histogram.cellColors = carray;
//    histogram.dataArray = array;
//    [histogram setNeedsDisplay];
//    [dataView oxyLastTime:[NSDate new] Value:95];
//    [dataView oxyMaxValue:85 minValue:95];
//    [self DateLabTestData:99];
//
//}
//-(void)testData2{
//    histogram.presetNum = 7;//一周七天
//    histogram.timeLabArray = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
//    NSMutableArray *array = [NSMutableArray new];
//    NSMutableArray *carray = [NSMutableArray new];
//    for (int i = 0; i<7; i++) {
//        int x = arc4random()%15+85;
//        ECPoint *point0 = [ECPoint make:i max:x min:85];
//        UIColor *color;
//        if (x>90) {
//            color = kDF_RGBA(138, 202, 146, 1);
//        }else{
//            color = kDF_RGBA(255, 187, 42, 1);
//        }
//        [carray addObject:color];
//        [array addObject:point0];
//    }
//    histogram.cellColors = carray;
//    histogram.dataArray = array;
//    [histogram setNeedsDisplay];
//
//    [dataView oxyLastTime:[NSDate new] Value:95];
//    [dataView oxyMaxValue:85 minValue:95];
//    [self DateLabTestData:99];
//}


//-(void)DateLabTestData:(int)percent{
//    [dateView setTitleLab:@"2021年2月22日-2021年3月3日" SecondLabel:@"13:00-13:30"];
//
//    // 属性文本生成器
//    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
//    NSString *stepStr = [NSString stringWithFormat:@"%d%@%@",percent,@"%",kJL_TXT("平均")];
//    textContainer.text = stepStr;
//
//    // 整体设置属性
//    textContainer.linesSpacing = 2;
//    textContainer.paragraphSpacing = 5;
//    textContainer.textAlignment = kCTTextAlignmentCenter;
//    // 文字样式
//    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
//    textStorage.range = [stepStr rangeOfString:[NSString stringWithFormat:@"%d%@",percent,@"%"]];
//    textStorage.font = [UIFont fontWithName:@"PingFangSC-Medium" size:30];
//    textStorage.textColor = kDF_RGBA(255, 255, 255, 1);
//    [textContainer addTextStorage:textStorage];
//
//    // 文字样式
//    TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
//    textStorage2.range = [stepStr rangeOfString:kJL_TXT("平均")];
//    textStorage2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
//    textStorage2.textColor = kDF_RGBA(255, 255, 255, 0.7);
//    [textContainer addTextStorage:textStorage2];
//
//    [dateView setTextWithContainer:textContainer];
//}



@end
