//
//  SleepDetailViewController.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/29.
//

#import "SleepDetailViewController.h"
#import "JL_RunSDK.h"
#import "SelectTitleBar.h"
#import "DateLabelView.h"
#import <CoreDraw/CoreDraw.h>
#import "SleepDataView.h"
#import "ContrastView.h"
#import "EcDateSelectView.h"
#import "DataOverallPlanTools.h"
#import "ContrastNapView.h"
#import "JLSqliteSleep.h"



@interface SleepDetailViewController ()<SelectActionDelegate,DateLabelViewDelegate,ContrastDelegate,EcDtSltDelegate,ECDiagramDeleagte,UIScrollViewDelegate>{
    UIView *titleBarView;
    UIButton *backBtn;
    UILabel *titleLab;
    UIButton *dayBtn;
    UIScrollView *scView;
    SelectTitleBar *selectView;
    DateLabelView *dateView;
    ECBlockDiagram *diagramView;
    UIView *customView;
    SleepDataView *sDataView;
    ContrastView *contrastView;
    ContrastNapView *napView;
    EcDateSelectView *ecDtSltv;
    DateType    dType;
    
    NSDate *nowDate;
}

@end

@implementation SleepDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;

    dType =     DateType_Day;
    scView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    scView.backgroundColor = kDF_RGBA(246, 247, 248, 1);
    scView.delegate = self;
    scView.showsVerticalScrollIndicator = false;
    [self.view addSubview:scView];
    
    
    titleBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, kJL_HeightNavBar+60)];
    titleBarView.backgroundColor = [JLColor colorWithString:@"#7D85DD"];
    titleBarView.alpha = 0;
    [self.view addSubview:titleBarView];
    
    backBtn = [[UIButton alloc] initWithFrame:CGRectMake(14, kJL_HeightNavBar-40, 40, 40)];
    [backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"icon_return_nol_white"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    
    titleLab = [[UILabel alloc] initWithFrame:CGRectMake(60, kJL_HeightNavBar-40, width-120, 40)];
    titleLab.textColor = kDF_RGBA(255, 255, 255, 1);
    titleLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    titleLab.text = kJL_TXT("睡眠");
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLab];
    
    dayBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-40-14, kJL_HeightNavBar-40, 40, 40)];
    [dayBtn addTarget:self action:@selector(dayBtnAction) forControlEvents:UIControlEventTouchUpInside];
    dayBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [dayBtn setImage:[UIImage imageNamed:@"icon_calender_nol"] forState:UIControlStateNormal];
    [self.view addSubview:dayBtn];
    
    diagramView = [[ECBlockDiagram alloc] initWithFrame:CGRectMake(0,-kJL_HeightNavBar, width, 567+kJL_HeightNavBar)];
    diagramView.eColor = [JLColor colorWithString:@"#3642D6"];
    diagramView.drawType = ECDrawBgc_TopToBottom;
    diagramView.ecTop = 218+kJL_HeightNavBar;
    diagramView.ecBottom = 56;
    diagramView.delegate = self;
    diagramView.beginImage = [UIImage imageNamed:@"icon_night_nol"];
    diagramView.endImage = [UIImage imageNamed:@"icon_day_nol"];
    diagramView.textArray = @[kJL_TXT("深睡"),kJL_TXT("浅睡"),kJL_TXT("快速眼动"),kJL_TXT("清醒")];
    [scView addSubview:diagramView];
    
    selectView = [[SelectTitleBar alloc] initWithFrame:CGRectMake(16, kJL_HeightNavBar+20, width-32, 34)];
    [selectView setSelectColor:[UIColor blueColor]];
    selectView.delegate = self;
    [self.view addSubview:selectView];
    
    float mHeight =  titleBarView.frame.size.height-kJL_HeightStatusBar;
    dateView = [[DateLabelView alloc] initWithFrame:CGRectMake(16, mHeight, width-32, 90)];
    dateView.delegate = self;
    [scView addSubview:dateView];
    
    customView = [[UIView alloc] initWithFrame:CGRectMake(0, 530, width, 900)];
    customView.backgroundColor = kDF_RGBA(246, 247, 248, 1);
    customView.layer.cornerRadius = 24;
    [scView addSubview:customView];
    
    sDataView = [[SleepDataView alloc] initWithFrame:CGRectMake(16, 26, width-32, 210)];
    sDataView.type = SleepDataType_Day;
    [customView addSubview:sDataView];
    
    contrastView = [[ContrastView alloc] initWithFrame:CGRectMake(16, 252, width-32, 75*6)];
    contrastView.delegate = self;
    [customView addSubview:contrastView];
    
    napView = [[ContrastNapView alloc] initWithFrame:CGRectMake(16, 252+contrastView.frame.size.height+16, width-32, 75*3)];
    [customView addSubview:napView];
    
    
    ecDtSltv = [[EcDateSelectView alloc] initWithFrame:CGRectMake(0, 0, width, [UIScreen mainScreen].bounds.size.height)];
    ecDtSltv.delegate = self;
    ecDtSltv.hidden = YES;
    [self.view addSubview:ecDtSltv];

    [scView setContentSize:CGSizeMake(width, diagramView.frame.size.height+contrastView.frame.size.height+dateView.frame.size.height+kJL_HeightTabBar)];
    
    [[SyncDataManager share] syncSleepData:kJL_BLE_EntityM with:^(JLWearSyncHealthSleepChart * _Nullable chart) {
        self->nowDate = [NSDate date];
        [self checkoutAndFull];
        
    }];
    nowDate = [NSDate date];
    [self checkoutAndFull];
    [self->scView setContentOffset:CGPointMake(0, 0) animated:true];

}


-(void)backBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)dayBtnAction{
    ecDtSltv.hidden = NO;
}
//MARK:日历选择回调
-(void)ecDidDateSelected:(NSDate *)date{
    nowDate = date;
    ecDtSltv.hidden = YES;
    [self checkoutAndFull];
}
//MARK:selectBar delegate
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
    [self checkoutAndFull];
    
}

//MARK:Date label delegate
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
    [self checkoutAndFull];
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
            NSLog(@"%@",nowDate.toYYYYMMdd);
        }break;
        default:
            break;
    }
    [self checkoutAndFull];
}

-(void)updateDateRightBtnStatus{
    switch (dType) {
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

//MARK:contrast Delegate
-(void)contrastViewDidSelect:(NSInteger)index{
    
}

//MARK: - 图形回调
-(void)ecDiagramdidSelect:(ECSleepDuration *)duration number:(NSInteger)num{
    [self setUpTime:duration.duration];
    if (dType ==     DateType_Year){
        [dateView setSecondLab:duration.date.toYYYYMM];
    }else{
        [dateView setSecondLab:duration.date.toMMdd3];
    }
}
//MARK: -数据库查询数据
-(void)checkoutAndFull{
    [self updateDateRightBtnStatus];
    switch (dType) {
        case     DateType_Day:{
            [DataOverallPlanTools sleepDataByDate:nowDate result:^(SleepDataFormatModel * _Nonnull model) {
                self->diagramView.dataArray = model.pointsArray;
                self->diagramView.isHistogram = model.isHistogram;
                self->diagramView.bottomTextFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 10];
                [self->diagramView setNeedsDisplay];
                [self->dateView setTitleLab:self->nowDate.standardDate SecondLabel:@""];
                [self DateLabel:model];
                self->sDataView.type = SleepDataType_Day;
            }];
        }break;
        case     DateType_Week:{
            StartAndEndDate *dates = nowDate.thisWeek;
            [DataOverallPlanTools sleepDataWeekFrom:dates.start To:dates.end result:^(SleepDataFormatModel * _Nonnull model) {
                self->diagramView.dataArray2 = model.durationArray;
                self->diagramView.isHistogram = model.isHistogram;
                self->diagramView.cellWidth = 12;
                self->diagramView.groupArray = @[kJL_TXT("我的周一"),kJL_TXT("我的周二"),kJL_TXT("我的周三"),kJL_TXT("我的周四"),kJL_TXT("我的周五"),kJL_TXT("我的周六"),kJL_TXT("我的周日")];
                self->diagramView.bottomTextFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 10];
                [self->diagramView setNeedsDisplay];
                [self->dateView setTitleLab:[NSString stringWithFormat:@"%@-%@",dates.start.toYYYYMMdd2,dates.end.toYYYYMMdd2] SecondLabel:@""];
                [self DateLabel:model];
                self->sDataView.type = SleepDataType_Other;
            }];
        }break;
        case     DateType_Month:{
            StartAndEndDate *dates = nowDate.thisMonth;
            [DataOverallPlanTools sleepDataMonthFrom:dates.start To:dates.end result:^(SleepDataFormatModel * _Nonnull model) {
                self->diagramView.dataArray2 = model.durationArray;
                self->diagramView.isHistogram = model.isHistogram;
                self->diagramView.cellWidth = 10;
                self->diagramView.bottomTextFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 10];
                self->diagramView.groupArray = self->nowDate.thisMonthDays;
                [self->diagramView setNeedsDisplay];
                [self->dateView setTitleLab:[NSString stringWithFormat:@"%@",dates.start.toYYYYMM] SecondLabel:@""];
                [self DateLabel:model];
                self->sDataView.type = SleepDataType_Other;
            }];
        }break;
        case     DateType_Year:{
            StartAndEndDate *dates = nowDate.thisYear;
            [DataOverallPlanTools sleepDataYearFrom:dates.start To:dates.end result:^(SleepDataFormatModel * _Nonnull model) {
                self->diagramView.dataArray2 = model.durationArray;
                self->diagramView.isHistogram = model.isHistogram;
                self->diagramView.cellWidth = 10;
                self->diagramView.bottomTextFont = [UIFont fontWithName:@"PingFangSC-Regular" size: 10];
                self->diagramView.groupArray = dates.start.thisYearMonths;
                [self->diagramView setNeedsDisplay];
                [self->dateView setTitleLab:[NSString stringWithFormat:@"%@-%@",dates.start.toYYYYMM,dates.end.toYYYYMM] SecondLabel:@""];
                [self DateLabel:model];
                self->sDataView.type = SleepDataType_Other;
            }];
        }break;
        default:
            break;
    }
}


-(void)DateLabel:(SleepDataFormatModel *)model{
    NSInteger length = model.detail.nightTime*60;
    [self setUpTime:length];
    
    int hour = (int)length/3600;
    int minute = length%3600/60;
    NSArray *arr = [ContrastData makeDataByType:dType
                                        allTime:hour
                                      WithMin:minute
                           WithDeepPercentage:[NSString stringWithFormat:@"%.0f%%",(float)model.detail.deep*60/(float)length*100]
                        WithShallowPercentage:[NSString stringWithFormat:@"%.0f%%",(float)model.detail.shallow*60/(float)length*100]
                                      WithRem:[NSString stringWithFormat:@"%.0f%%",(float)model.detail.rem*60/(float)length*100]
                                  DeepSleepScre:model.detail.sleepAnalyze.deepSleepScre
                                  WithWakeCount:(int)model.detail.awakeCount];
    [contrastView setDataArray:arr];
    
    
    [sDataView deepSleep:[NSString stringWithFormat:@"%.0f%%",(float)model.detail.deep*60/(float)length*100] length:model.detail.deep*60];
    [sDataView shallowSleep:[NSString stringWithFormat:@"%.0f%%",(float)model.detail.shallow*60/(float)length*100] length:model.detail.shallow*60];
    [sDataView remSleep:[NSString stringWithFormat:@"%.0f%%",(float)model.detail.rem*60/(float)length*100] length:model.detail.rem*60];
    [sDataView setGoal:(int)model.detail.sleepAnalyze.sleepScore];
    
    if (dType == DateType_Day) {
        if (model.detail.arrayNaps.count!=0) {
            NSMutableArray *naps = [NSMutableArray arrayWithArray:model.detail.arrayNaps];
            SleepNapModel *md = [SleepNapModel makeAll:model.detail.all];
            [naps addObject:md];
            [napView setArray:naps];
            napView.frame = CGRectMake(16, 252+contrastView.frame.size.height+16, [UIScreen mainScreen].bounds.size.width-32,naps.count*75);
            [scView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, selectView.frame.size.height+diagramView.frame.size.height+contrastView.frame.size.height+dateView.frame.size.height+kJL_HeightTabBar+napView.frame.size.height)];
        }else{
            [napView setArray:@[[SleepNapModel makeAll:model.detail.all]]];
            napView.frame = CGRectMake(16, 252+contrastView.frame.size.height+16, [UIScreen mainScreen].bounds.size.width-32,75);
            [scView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, selectView.frame.size.height+diagramView.frame.size.height+contrastView.frame.size.height+dateView.frame.size.height+kJL_HeightTabBar+napView.frame.size.height)];
        }
    }else{
        [napView setArray:@[[SleepNapModel makeAve:model.detail.all]]];
        napView.frame = CGRectMake(16, 252+contrastView.frame.size.height+16, [UIScreen mainScreen].bounds.size.width-32,75);
        [scView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, selectView.frame.size.height+diagramView.frame.size.height+contrastView.frame.size.height+dateView.frame.size.height+kJL_HeightTabBar+napView.frame.size.height)];
    }
    [scView setContentOffset:CGPointMake(0, -kJL_HeightStatusBar) animated:true];

    if (model.detail.all == 0) {
        [scView setScrollEnabled:false];
        [sDataView setTitleHidden:true];
        [contrastView setHidden:true];
    }else{
        [sDataView setTitleHidden:false];
        [scView setScrollEnabled:true];
        [contrastView setHidden:false];
    }
    
}

-(void)setUpTime:(NSInteger)length{
    
    int hour = (int)length/3600;
    int minute = length%3600/60;
    // 属性文本生成器
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    NSString *h = hour == 0 ? @"-":[NSString stringWithFormat:@"%d",hour];
    NSString *min = minute == 0 ? @"-":[NSString stringWithFormat:@"%d",minute];
    NSString *stepStr = [NSString stringWithFormat:@"%@%@%@%@",h,kJL_TXT("小时"),min,kJL_TXT("分钟")];
    textContainer.text = stepStr;
    // 整体设置属性
    textContainer.linesSpacing = 2;
    textContainer.paragraphSpacing = 5;
    textContainer.textColor = kDF_RGBA(255, 255, 255, 1);
    textContainer.font = [UIFont fontWithName:@"PingFangSC-Medium" size:30];
    textContainer.textAlignment = kCTTextAlignmentCenter;
   
    // 文字样式
    TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
    textStorage2.range = [stepStr rangeOfString:kJL_TXT("小时")];
    textStorage2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    textStorage2.textColor = kDF_RGBA(255, 255, 255, 0.7);
    [textContainer addTextStorage:textStorage2];
   
    // 文字样式
    TYTextStorage *textStorage3 = [[TYTextStorage alloc]init];
    textStorage3.range = [stepStr rangeOfString:kJL_TXT("分钟")];
    textStorage3.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    textStorage3.textColor = kDF_RGBA(255, 255, 255, 0.7);
    [textContainer addTextStorage:textStorage3];
    
    [dateView setTextWithContainer:textContainer];
    if (hour == 0 && minute == 0){
        [sDataView setHidden:true];
    }else{
        [sDataView setHidden:false];
    }
}

//MARK: - scrollviewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float k = (scrollView.contentOffset.y+kJL_HeightStatusBar)/60.0;
    if (k<0) {
        k = 0.0f;
    }else if (k>1){
        k = 1.0f;
    }
    if (scrollView.contentOffset.y< -2*kJL_HeightStatusBar) {
        k = 1.0f;
    }
    titleBarView.alpha = k;
    
//    NSLog(@"scrollViewDidScroll:%f",scrollView.contentOffset.y);
}


//MARK: - 测试代码
//-(void)testData1{
//    NSDateFormatter *dft = [EcTools cachedFm];
//    dft.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//    NSString *timeS = @"2021-11-07 22:43:49";
//    NSDate *dt = [dft dateFromString:timeS];
//    NSTimeInterval dt0 = [dt timeIntervalSince1970];
//    NSMutableArray *array = [NSMutableArray new];
//    [array addObject:[ECDiagramPoint make:[dft dateFromString:@"2021-11-07 23:50:00"] len:600 type:0]];
//    [array addObject:[ECDiagramPoint make:[dft dateFromString:@"2021-11-08 00:00:00"] len:2760 type:1]];
//    [array addObject:[ECDiagramPoint make:[dft dateFromString:@"2021-11-08 00:46:00"] len:2580 type:1]];
//    [array addObject:[ECDiagramPoint make:[dft dateFromString:@"2021-11-08 01:29:00"] len:5040 type:3]];
//    [array addObject:[ECDiagramPoint make:[dft dateFromString:@"2021-11-08 02:53:00"] len:4920 type:0]];
//    [array addObject:[ECDiagramPoint make:[dft dateFromString:@"2021-11-08 04:15:00"] len:2820 type:1]];
//    [array addObject:[ECDiagramPoint make:[dft dateFromString:@"2021-11-08 05:50:00"] len:5700 type:3]];
//    [array addObject:[ECDiagramPoint make:[dft dateFromString:@"2021-11-08 06:37:00"] len:4680 type:0]];
//    diagramView.dataArray = array;
//    diagramView.isHistogram = NO;
//    [diagramView setNeedsDisplay];
//    [self DateLabTestData:28760];
////    [contrastView setDataArray:[ContrastData makeTestData:7 WithMin:20 WithDeepPercentage:@"27%" WithShallowPercentage:@"27%" WithRem:@"27%" WithWakeCount:2]];
//    sDataView.type = SleepDataType_Day;
//    [self dataLabTestData];
//}

//-(void)testData2{
//    NSMutableArray *array2 = [NSMutableArray new];
//    ECSleepDuration *ecs = [ECSleepDuration make:0.32 shallow:0.4 awake:0.02 rem:0.26 Duration:26500 Date:[NSDate new]];
//    [array2 addObject:ecs];
//    ECSleepDuration *ecs1 = [ECSleepDuration make:0.42 shallow:0.3 awake:0.02 rem:0.26 Duration:26500 Date:[NSDate new]];
//    [array2 addObject:ecs1];
//    ECSleepDuration *ecs2 = [ECSleepDuration make:0.27 shallow:0.45 awake:0.01 rem:0.27 Duration:29500 Date:[NSDate new]];
//    [array2 addObject:ecs2];
//    ECSleepDuration *ecs3 = [ECSleepDuration make:0.58 shallow:0.14 awake:0.00 rem:0.28 Duration:23500 Date:[NSDate new]];
//    [array2 addObject:ecs3];
//    ECSleepDuration *ecs4 = [ECSleepDuration make:0.36 shallow:0.35 awake:0.03 rem:0.26 Duration:27500 Date:[NSDate new]];
//    [array2 addObject:ecs4];
//    ECSleepDuration *ecs5 = [ECSleepDuration make:0.42 shallow:0.3 awake:0.02 rem:0.26 Duration:28500 Date:[NSDate new]];
//    [array2 addObject:ecs5];
//    ECSleepDuration *ecs6 = [ECSleepDuration make:0.5 shallow:0.22 awake:0.00 rem:0.28 Duration:24500 Date:[NSDate new]];
//    [array2 addObject:ecs6];
//    diagramView.dataArray2 = array2;
//    diagramView.groupArray = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
//    diagramView.isHistogram = YES;
//    [diagramView setNeedsDisplay];
//    sDataView.type = SleepDataType_Other;
//    [self dataLabTestData];
//}

-(void)dataLabTestData{
    [sDataView setGoal:70];
}

-(void)DateLabTestData:(NSInteger)length{
    int hour = (int)length/3600;
    int minute = length%3600/60;
    
    [dateView setTitleLab:@"2021年2月22日 星期二" SecondLabel:@""];
    // 属性文本生成器
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    NSString *stepStr = [NSString stringWithFormat:@"%d%@%d%@",hour,kJL_TXT("小时"),minute,kJL_TXT("分钟")];
    textContainer.text = stepStr;
    
    // 整体设置属性
    textContainer.linesSpacing = 2;
    textContainer.paragraphSpacing = 5;
    textContainer.textAlignment = kCTTextAlignmentCenter;
    // 文字样式
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [stepStr rangeOfString:[NSString stringWithFormat:@"%d",hour]];
    textStorage.font = [UIFont fontWithName:@"PingFangSC-Medium" size:30];
    textStorage.textColor = kDF_RGBA(255, 255, 255, 1);
    [textContainer addTextStorage:textStorage];
    // 文字样式
    TYTextStorage *textStorage1 = [[TYTextStorage alloc]init];
    textStorage1.range = [stepStr rangeOfString:[NSString stringWithFormat:@"%d",minute]];
    textStorage1.font = [UIFont fontWithName:@"PingFangSC-Medium" size:30];
    textStorage1.textColor = kDF_RGBA(255, 255, 255, 1);
    [textContainer addTextStorage:textStorage1];
    // 文字样式
    TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
    textStorage2.range = [stepStr rangeOfString:kJL_TXT("小时")];
    textStorage2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    textStorage2.textColor = kDF_RGBA(255, 255, 255, 0.7);
    [textContainer addTextStorage:textStorage2];
    // 文字样式
    TYTextStorage *textStorage3 = [[TYTextStorage alloc]init];
    textStorage3.range = [stepStr rangeOfString:kJL_TXT("分钟")];
    textStorage3.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    textStorage3.textColor = kDF_RGBA(255, 255, 255, 0.7);
    [textContainer addTextStorage:textStorage3];
    
    [dateView setTextWithContainer:textContainer];
}

@end
