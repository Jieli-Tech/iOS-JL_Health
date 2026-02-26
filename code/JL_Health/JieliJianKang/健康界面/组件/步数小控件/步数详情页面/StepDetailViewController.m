//
//  StepDetailViewController.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/24.
//

#import "StepDetailViewController.h"
#import "DateLabelView.h"
#import "SelectTitleBar.h"
#import "StepDataView.h"
#import "JL_RunSDK.h"
#import "EcDateSelectView.h"
#import <CoreDraw/CoreDraw.h>
#import "JLSqliteStep.h"
#import "SyncDataManager.h"
#import "JLSqliteStep.h"
#import "ContrastView.h"

@interface StepDetailViewController ()<ECHistogramDelegate,DateLabelViewDelegate,SelectActionDelegate,EcDtSltDelegate,UIScrollViewDelegate>{
    UIView *titleBarView;
    StepDataView *dataView;
    DateLabelView *dateView;
    SelectTitleBar *selectView;
    ECHistogram *hisView;
    EcDateSelectView *ecDtSltv;
    
    UIButton *leftBtn;
    UILabel *titleLab;
    UIButton *dayBtn;
    
    int mStepIndex;
    //int currentTotalStepValue;
    int dayStepValue;
    int weekStepValue;
    int monthStepValue;
    int yearStepValue;
    float currentTotalMileage;
    double currentTotalConsumption;
    
    NSInteger month;
    
    DateType    dType;
    NSDate *nowDate;
    
    NSMutableArray *mulArray;
    NSMutableArray *stepArray;
}
@end

@implementation StepDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat height = 0;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    mStepIndex = -1;
    dType =     DateType_Day;
    
    mulArray  = [NSMutableArray new];
    stepArray = [NSMutableArray new];
    
    UIScrollView *scView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, [UIScreen mainScreen].bounds.size.height)];
    scView.showsVerticalScrollIndicator = false;
    scView.delegate = self;
    [self.view addSubview:scView];
    
    titleBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, kJL_HeightNavBar+60)];
    titleBarView.backgroundColor = [JLColor colorWithString:@"#9864FF"];
    titleBarView.alpha = 0;
    [self.view addSubview:titleBarView];
    
    leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(10,kJL_HeightNavBar-40, 40, 40)];
    [leftBtn setImage:[UIImage imageNamed:@"icon_return_nol_white"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBtn];
    
    titleLab = [[UILabel alloc] initWithFrame:CGRectMake(width/2-120, kJL_HeightNavBar-30, 240, 25)];
    titleLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = [UIColor whiteColor];
    titleLab.text = kJL_TXT("步数");
    [self.view addSubview:titleLab];
    
    dayBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-50, kJL_HeightNavBar-40, 40, 40)];
    [dayBtn setImage:[UIImage imageNamed:@"icon_calender_nol"] forState:UIControlStateNormal];
    [dayBtn addTarget:self action:@selector(dayBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dayBtn];
    
    hisView = [[ECHistogram alloc] initWithFrame:CGRectMake(0,-kJL_HeightNavBar,width, 532+kJL_HeightNavBar)];
    hisView.drawType = ECDrawBgc_TopToBottom;
    hisView.maxValue = 840;
    hisView.minValue = 0;
    hisView.ecBottom = 90;
    hisView.ecLeft = 20;
    hisView.ecRight = 10;
    hisView.ecTop = 280+kJL_HeightNavBar;
    hisView.delegate = self;
    [scView addSubview:hisView];
    
    selectView = [[SelectTitleBar alloc] initWithFrame:CGRectMake(16, kJL_HeightNavBar+20, width-32, 34)];
    selectView.delegate = self;
    [self.view addSubview:selectView];
    
    float mHeight = titleBarView.frame.size.height-kJL_HeightStatusBar;
    dateView = [[DateLabelView alloc] initWithFrame:CGRectMake(16, mHeight, width-32, 80)];
    dateView.delegate = self;
    [scView addSubview:dateView];

    
    CGFloat tmpH = 461;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, tmpH, width, 812)];
    bgView.backgroundColor = kDF_RGBA(246, 247, 248, 1);
    bgView.layer.cornerRadius = 24;
    bgView.layer.masksToBounds = YES;
    [scView addSubview:bgView];
    dataView = [[StepDataView alloc] initWithFrame:CGRectMake(16, 31, width-32, 90)];
    [bgView addSubview:dataView];
        
    [scView setContentSize:CGSizeMake(width, 812)];
    
    ecDtSltv = [[EcDateSelectView alloc] initWithFrame:CGRectMake(0, 0, width, [UIScreen mainScreen].bounds.size.height)];
    ecDtSltv.delegate = self;
    ecDtSltv.hidden = YES;
    [self.view addSubview:ecDtSltv];
    
    nowDate = [NSDate date];
    [self barDidSelectIndex:0];
}

-(void)leftBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 显示日历选择的控件
-(void)dayBtnAction{
    [ecDtSltv setHidden:NO];
}

//MARK:日历选择回调
-(void)ecDidDateSelected:(NSDate *)date{
    nowDate = date;
   
    [ecDtSltv setHidden:YES];
    
    if(dType == 0){
        [self loadDayData];
        [self DateLabTestData:dayStepValue];
    }
    if(dType == 1){
        [self loadWeekData];
        [self DateLabTestData:weekStepValue];
    }
    if(dType == 2){
        [self loadMonthData];
        [self DateLabTestData:monthStepValue];
    }
    if(dType == 3){
        [self loadYearData];
        [self DateLabTestData:yearStepValue];
    }
  
}

///MARK:图表代理回调
-(void)ecHistogram:(ECHistogram *) echis StepData:(NSInteger)step Index:(NSInteger) index{
    mStepIndex = (int)index;
    [self DateLabTestData:(int)step];
    
    if(dType ==     DateType_Day){
        dayStepValue = (int)step;
        int lastHour    = mStepIndex;
        int currentHour = mStepIndex+1;
        NSString *secondLabel = [NSString stringWithFormat:@"%d%@%@%d%@",lastHour,@":00",@"-",currentHour,@":00"];
        [dateView setSecondLab:secondLabel];
    }
    if(dType ==     DateType_Week){
        weekStepValue = (int)step;
    }
    if(dType ==     DateType_Month){
        monthStepValue = (int)step;
    }
    if(dType ==     DateType_Week || dType ==     DateType_Month){
        NSDate *date = mulArray[index];
        [dateView setSecondLab:date.toMMdd3];
    }
    if (dType ==     DateType_Year){
        yearStepValue = (int)step;
        NSDate *date = mulArray[index];
        [dateView setSecondLab:date.toYYYYMM];
    }
}

///MARK: 日期前后回调
-(void)dateLabelViewPreviousBtnAction{
    switch (dType) {
        case     DateType_Day:{
            nowDate = nowDate.before;
            [self loadDayData];
            [self DateLabTestData:dayStepValue];
            
                
        }break;
        case     DateType_Week:{
            nowDate = nowDate.beforeWeek;
            [self loadWeekData];
            [self DateLabTestData:weekStepValue];
            dateView.rightBtn.hidden = !nowDate.beforeThisWeek_0;
        }break;
        case     DateType_Month:{
            nowDate = nowDate.beforeMonth;
            [self loadMonthData];
            [self DateLabTestData:monthStepValue];
            
        }break;
        case     DateType_Year:{
            nowDate = nowDate.beforeYear;
            [self loadYearData];
            [self DateLabTestData:yearStepValue];
            
        }break;
        default:
            break;
    }
    
    [self updateDateRightBtnStatus];
    
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

-(void)dateLabelViewNextBtnAction{
    switch (dType) {
        case     DateType_Day:{
            nowDate = nowDate.next;
            [self loadDayData];
            [self DateLabTestData:dayStepValue];
            
        }break;
        case     DateType_Week:{
            nowDate = nowDate.nextWeek;
            [self loadWeekData];
            [self DateLabTestData:weekStepValue];
            
        }break;
        case     DateType_Month:{
            nowDate = nowDate.nextMonth;
            [self loadMonthData];
            [self DateLabTestData:monthStepValue];
            
        }break;
        case     DateType_Year:{
            nowDate = nowDate.nextYear;
            [self loadYearData];
            [self DateLabTestData:yearStepValue];
            
        }break;
        default:
            break;
    }
    [self updateDateRightBtnStatus];
}

///MARK: 日期选择回调
-(void)barDidSelectIndex:(NSInteger)index{
    dType = index;
    if (dType == DateType_Week) {
        ecDtSltv.isWeek = true;
    }else if (dType == DateType_Day){
        ecDtSltv.isWeek = false;
    }
    if(index == 0){
        dayBtn.hidden = NO;
        [self loadDayData];
        [self DateLabTestData:dayStepValue];
    }
    
    if (index == 1) {
        dayBtn.hidden = NO;
        [self loadWeekData];
        [self DateLabTestData:weekStepValue];
    }
    if (index == 2) {
        dayBtn.hidden = YES;
        [self loadMonthData];
        [self DateLabTestData:monthStepValue];
    }
    if (index == 3) {
        dayBtn.hidden = YES;
        [self loadYearData];
        [self DateLabTestData:yearStepValue];
    }
    [self updateDateRightBtnStatus];
}


///MARK:测试数据
//-(void)testData{
//    stepDayArray = [NSMutableArray new];
//    for (int i = 0; i<24; i++) {
//        int k = random()%10000;
//        if (i==0||i==23||i == 12||i == 1||i == 2||i == 3||i == 4||i == 5) {
//            k = 0;
//        }
//        CGPoint p = CGPointMake(i, k);
//        kJLLog(JLLOG_DEBUG, @"%f,%f",p.x,p.y);
//        [stepDayArray addObject:[NSValue valueWithCGPoint:p]];
//    }
//    hisView.dataArray = stepDayArray;
//    hisView.presetNum = 24;
//    hisView.cellWidth = 9;
//    hisView.timeLabArray = @[@"00:00",@"06:00",@"12:00",@"18:00",@"00:00"];
//    [self DateLabTestData:currentStepValue];
//    [hisView startToDraw];
//    [dataView setTabLab:kJL_TXT("总里程") TabLab2:kJL_TXT("总消耗") Value1:kJL_TXT("0.56") Unit1:kJL_TXT("公里") Value2:@"35" Unit2:kJL_TXT("千卡")];
//}

//-(void)testDataWeek{
//    NSMutableArray *ps = [NSMutableArray new];
//    for (int i = 0; i<7; i++) {
//        int k = random()%10000;
//
//        CGPoint p = CGPointMake(i, k);
////        kJLLog(JLLOG_DEBUG, @"%f,%f",p.x,p.y);
//        [ps addObject:[NSValue valueWithCGPoint:p]];
//    }
//    hisView.dataArray = ps;
//    hisView.presetNum = 7;
//    hisView.timeLabArray = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
//    hisView.cellWidth = 12;
//    [hisView setNeedsDisplay];
//}
//
//
//-(void)testDataMonth{
//    NSMutableArray *ps = [NSMutableArray new];
//    for (int i = 0; i<30; i++) {
//
//        int k = random()%10000;
//        if (i == 10) {
//            k = 0;
//        }
//        CGPoint p = CGPointMake(i, k);
////        kJLLog(JLLOG_DEBUG, @"%f,%f",p.x,p.y);
//        [ps addObject:[NSValue valueWithCGPoint:p]];
//    }
//    hisView.dataArray = ps;
//    hisView.presetNum = 30;
//    hisView.timeLabArray = @[@"1日",@"3日",@"5日",@"7日",@"8日",@"10日",@"12日",@"14日",@"17日",@"19日",
//                             @"21日",@"24日",@"26日",@"28日",@"30日"];
//    hisView.cellWidth = 10;
//    [hisView setNeedsDisplay];
//}
//
//-(void)testDataYear{
//    NSMutableArray *ps = [NSMutableArray new];
//    for (int i = 0; i<12; i++) {
//
//        int k = random()%10000;
//        if (i == 10) {
//            k = 0;
//        }
//        CGPoint p = CGPointMake(i, k);
////        kJLLog(JLLOG_DEBUG, @"%f,%f",p.x,p.y);
//        [ps addObject:[NSValue valueWithCGPoint:p]];
//    }
//    hisView.dataArray = ps;
//    hisView.presetNum = 12;
//    hisView.timeLabArray = @[@"1月",@"2月",@"3月",@"4月",@"5月",@"6月",@"7月",@"8月",@"9月",@"10月",@"11月",@"12月"];
//    hisView.cellWidth = 12;
//    [hisView setNeedsDisplay];
//}

-(void)DateLabTestData:(int)step{
    if(dType == 0){
        [self->dateView setTitleLab:self->nowDate.standardDate SecondLabel:@""];
    }
    if(dType == 1){
        StartAndEndDate *dates = nowDate.thisWeek;
        [self->dateView setTitleLab:[NSString stringWithFormat:@"%@-%@",dates.start.toYYYYMMdd2,dates.end.toYYYYMMdd2] SecondLabel:@""];
    }
    if(dType == 2){
        StartAndEndDate *dates = nowDate.thisMonth;
        [self->dateView setTitleLab:dates.start.toYYYYMM SecondLabel:@""];
    }
    if(dType ==3){
        StartAndEndDate *dates = nowDate.thisYear;
        [self->dateView setTitleLab:[NSString stringWithFormat:@"%@-%@",dates.start.toYYYYMM,dates.end.toYYYYMM] SecondLabel:@""];
    }
    
    // 属性文本生成器
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    
    NSString *stepStr = [NSString stringWithFormat:@"%d%@",step,kJL_TXT("步")];
    if (step == 0){
        stepStr = [NSString stringWithFormat:@"- -%@",kJL_TXT("步")];;
    }
    textContainer.text = stepStr;
    
    // 整体设置属性
    textContainer.linesSpacing = 2;
    textContainer.paragraphSpacing = 5;
    textContainer.textAlignment = kCTTextAlignmentCenter;
    // 文字样式
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [stepStr rangeOfString:[NSString stringWithFormat:@"%d",step]];
    if (step == 0){
        textStorage.range = [stepStr rangeOfString:[NSString stringWithFormat:@"- -"]];
    }
    textStorage.font = [UIFont fontWithName:@"PingFangSC-Medium" size:30];
    textStorage.textColor = kDF_RGBA(255, 255, 255, 1);
    [textContainer addTextStorage:textStorage];
    // 文字样式
    TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
    textStorage2.range = [stepStr rangeOfString:kJL_TXT("步")];
    textStorage2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    textStorage2.textColor = kDF_RGBA(255, 255, 255, 0.7);
    [textContainer addTextStorage:textStorage2];
    [dateView setTextWithContainer:textContainer];
}

#pragma mark 查询数据库日的数据
-(void)queryDayFromDB{
    [JLSqliteStep s_checkout:@[nowDate] Result:^(NSArray<JL_Chart_MoveSteps *> * _Nonnull charts) {
        NSMutableArray *dayStepMulArray = [NSMutableArray new];
        NSMutableArray *totalStep = [NSMutableArray new];
        
        for (int i=0; i<charts.count; i++) {
            JL_Chart_MoveSteps *moveStepModel = charts[i];
            
            self->currentTotalMileage = moveStepModel.totalMileage;
            self->currentTotalConsumption = moveStepModel.totalConsumption;

            NSArray <StepCountData *> *bloodOxyganArray= moveStepModel.stepCountlist;
            
            StepCountData *stepCountData = bloodOxyganArray[i];
            
            NSArray *stepArrays = stepCountData.stepCounts;
            
            for(int j=0;j<stepArrays.count;j++){
                JLWearStepCountModel *model = stepArrays[j];

                CGPoint p1 = CGPointMake(j, model.count);

                NSValue *v1 = [NSValue valueWithCGPoint:p1];

                [dayStepMulArray addObject:v1];
                [totalStep addObject:@(model.count)];
            }
        }
        int temMaxValue = [[totalStep valueForKeyPath:@"@max.floatValue"] intValue];
        self->hisView.maxValue = temMaxValue+3;
        if (dayStepMulArray.count>0){
            self->hisView.dataArray = [dayStepMulArray copy];
        }else{
            self->hisView.dataArray = [self makeNoneDataBy:24];
        }
        self->hisView.presetNum = 24;
        self->hisView.cellWidth = 9;
        self->hisView.timeLabArray = @[@"00:00",@"06:00",@"12:00",@"18:00",@"00:00"];
        [self->hisView startToDraw];
        
        
        NSString *myTotalConsumption = [NSString stringWithFormat:@"%.0f",self->currentTotalConsumption];
        if (self->currentTotalConsumption == 0){
            myTotalConsumption = @"- -";
        }
        NSString *myUnits;
        NSString *myTotalMileage;
        
        NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
        if([unitStr isEqualToString:@("英制")]){
            myTotalMileage = [NSString stringWithFormat:@"%.2f",(self->currentTotalMileage/100)*0.621];
            myUnits = kJL_TXT("英里");
        }else{
            myTotalMileage = [NSString stringWithFormat:@"%.2f",self->currentTotalMileage/100];
            myUnits = kJL_TXT("公里");
        }
        if ([myTotalMileage isEqualToString:@"0.00"]){
            myTotalMileage = @"- -";
        }
        [self->dataView setTabLab:kJL_TXT("总里程") TabLab2:kJL_TXT("总消耗") Value1:myTotalMileage Unit1:myUnits Value2:myTotalConsumption Unit2:kJL_TXT("千卡")];
    }];
}

#pragma mark 查询数据库周的数据
-(void)queryWeekFromDB{
    StartAndEndDate *dates = nowDate.thisWeek;
    [JLSqliteStep s_checkoutWtihStartDate:dates.start withEndDate:dates.end Result:^(NSArray<JL_Chart_MoveSteps *> * _Nonnull charts) {
        NSMutableArray *weekStepMulArray = [NSMutableArray new];
        NSMutableArray *totalStep = [NSMutableArray new];
        
        [self->mulArray removeAllObjects];
        for (int i=0; i<7; i++) {
            NSDate *d = [dates.start dateByAddingTimeInterval:i*60*60*24];
            NSValue *value = [self checkWithValueDate:d Charts:charts isWeek:true];
            [weekStepMulArray addObject:value];
        }
        
        for (int i=0; i<charts.count; i++) {
            JL_Chart_MoveSteps *moveStepModel = charts[i];
            self->currentTotalMileage = [[NSString stringWithFormat:@"%.2f",moveStepModel.totalMileage] floatValue];
            self->currentTotalConsumption = [[NSString stringWithFormat:@"%.0f",moveStepModel.totalConsumption] intValue];
            NSArray <StepCountData *> *stepArray= moveStepModel.stepCountlist;
            for (StepCountData *stepCountData in stepArray) {
                [totalStep addObject:@((int)moveStepModel.allStep)];
                [self->stepArray addObject:@((int)moveStepModel.allStep)];
            }
        }
        
        int temMyMaxValue = [[totalStep valueForKeyPath:@"@max.floatValue"] intValue];
        self->hisView.maxValue = temMyMaxValue+3;
        
        if (weekStepMulArray.count>0){
            self->hisView.dataArray = [weekStepMulArray copy];
        }else{
            self->hisView.dataArray = [self makeNoneDataBy:7];
            [self->mulArray removeAllObjects];
            for (int i = 0;i<7;i++){
                [self->stepArray addObject:@(0)];
                NSDate *d = [dates.start dateByAddingTimeInterval:i*60*60*24];
                [self->mulArray addObject:d];
            }
        }
        self->hisView.presetNum = 7;
        self->hisView.timeLabArray = @[kJL_TXT("我的周一"),kJL_TXT("我的周二"),kJL_TXT("我的周三"),kJL_TXT("我的周四"),kJL_TXT("我的周五"),kJL_TXT("我的周六"),kJL_TXT("我的周日")];
        self->hisView.cellWidth = 12;
        [self->hisView setNeedsDisplay];

        int temSumValue = [[totalStep valueForKeyPath:@"@sum.floatValue"] intValue];
        int temavgValue = [[totalStep valueForKeyPath:@"@avg.floatValue"] intValue];
        
        NSString *myStepValue = [NSString stringWithFormat:@"%d",temSumValue];
        NSString *avgStep = [NSString stringWithFormat:@"%d",temavgValue];
        
        if (temavgValue == 0){
            avgStep = @"- -";
        }
        if (temavgValue == 0){
            myStepValue = @"- -";
        }
        
        [self->dataView setTabLab:kJL_TXT("总步数") TabLab2:kJL_TXT("平均步数") Value1:myStepValue Unit1:kJL_TXT("步") Value2:avgStep Unit2:kJL_TXT("步")];
    }];
}

#pragma mark 查询数据库月的数据

-(NSValue *)checkWithValueDate:(NSDate *) thisDate Charts:(NSArray<JL_Chart_MoveSteps *> *)charts isWeek:(BOOL)isWeek{
    [mulArray addObject:thisDate];
    if (charts.count == 0){
        NSInteger day = thisDate.witchDay;
        if (isWeek){
            day = thisDate.witchWeekDay;
        }
        CGPoint p1 = CGPointMake(day-1, 0);
        return [NSValue valueWithCGPoint:p1];
    }
    for (int i = 0;i<charts.count;i++){
        JL_Chart_MoveSteps *moveStepModel = charts[i];
        NSArray <StepCountData *> *stepArray= moveStepModel.stepCountlist;
        for (StepCountData *stepCountData in stepArray) {
            if ([[NSCalendar currentCalendar] isDate:stepCountData.startDate inSameDayAsDate:thisDate]){
                NSInteger day = stepCountData.startDate.witchDay;
                CGPoint p1 = CGPointMake(day-1, moveStepModel.allStep);
                NSValue *v1 = [NSValue valueWithCGPoint:p1];
                return v1;
            }
        }
    }
    NSInteger day = thisDate.witchDay;
    CGPoint p1 = CGPointMake(day-1, 0);
    return [NSValue valueWithCGPoint:p1];
}

-(void)queryMonthFromDB{
    StartAndEndDate *dates = nowDate.thisMonth;
    NSInteger maxDay = nowDate.monthDayCount;
    [JLSqliteStep s_checkoutWtihStartDate:dates.start withEndDate:dates.end Result:^(NSArray<JL_Chart_MoveSteps *> * _Nonnull charts) {
        NSMutableArray *monthStepMulArray = [NSMutableArray new];
        NSMutableArray *totalStep = [NSMutableArray new];
        
        [self->mulArray removeAllObjects];
        for (int i=0; i<maxDay; i++) {
            NSDate *d = [dates.start dateByAddingTimeInterval:i*60*60*24];
            NSValue *value = [self checkWithValueDate:d Charts:charts isWeek:false];
            [monthStepMulArray addObject:value];
        }
        for (int i = 0;i<charts.count;i++){
            JL_Chart_MoveSteps *moveStepModel = charts[i];
            self->currentTotalMileage = [[NSString stringWithFormat:@"%.2f",moveStepModel.totalMileage] floatValue];
            self->currentTotalConsumption = [[NSString stringWithFormat:@"%.0f",moveStepModel.totalConsumption] intValue];
            NSArray <StepCountData *> *stepArray= moveStepModel.stepCountlist;
            for (StepCountData *stepCountData in stepArray) {
                [totalStep addObject:@((int)moveStepModel.allStep)];
                [self->stepArray addObject:@((int)moveStepModel.allStep)];
                [self->mulArray addObject:stepCountData.startDate];
            }
        }
        
        int temMyMaxValue = [[totalStep valueForKeyPath:@"@max.floatValue"] intValue];
        self->hisView.maxValue = temMyMaxValue+3;
        self->hisView.dataArray = [monthStepMulArray copy];
        self->hisView.presetNum = maxDay;
        self->hisView.timeLabArray = self->nowDate.thisMonthDays;

        self->hisView.cellWidth = 10;
        [self->hisView setNeedsDisplay];

        int temSumValue = [[totalStep valueForKeyPath:@"@sum.floatValue"] intValue];
        int temavgValue = [[totalStep valueForKeyPath:@"@avg.floatValue"] intValue];
        NSString *myStepValue = [NSString stringWithFormat:@"%d",temSumValue];
        
        NSString *avgStep = [NSString stringWithFormat:@"%d",temavgValue];
        if (temavgValue == 0){
            avgStep = @"- -";
        }
        if (temavgValue == 0){
            myStepValue = @"- -";
        }

        [self->dataView setTabLab:kJL_TXT("总步数") TabLab2:kJL_TXT("平均步数") Value1:myStepValue Unit1:kJL_TXT("步") Value2:avgStep Unit2:kJL_TXT("步")];
    }];
}

#pragma mark 查询数据库年的数据


-(void)queryYearFromDB{
    StartAndEndDate *dates = nowDate.thisYear;
    [JLSqliteStep s_checkoutWtihStartDate:dates.start withEndDate:dates.end Result:^(NSArray<JL_Chart_MoveSteps *> * _Nonnull charts) {
        NSMutableArray *yearStepMulArray = [NSMutableArray new];
        NSMutableArray *totalStep = [NSMutableArray new];
        NSDate *firstMonth = dates.start;
        [self->mulArray removeAllObjects];
        for (int j = 0; j<12 ;j++){
            int countStep = 0;
            for (int i = 0;i<charts.count;i++){
                JL_Chart_MoveSteps *moveStepModel = charts[i];
               
                NSArray <StepCountData *> *stepArray= moveStepModel.stepCountlist;
                for (StepCountData *stepCountData in stepArray) {
                    if ([stepCountData.startDate witchMonth] == j){
                        countStep+=moveStepModel.allStep;
                    }
                }
            }
            [self->mulArray addObject:firstMonth];
            CGPoint p1 = CGPointMake(j, countStep);
            NSValue *v1 = [NSValue valueWithCGPoint:p1];
            firstMonth = firstMonth.nextMonth_0;
            [yearStepMulArray addObject:v1];
        }
        
        for (int i=0; i<charts.count; i++) {
            JL_Chart_MoveSteps *moveStepModel = charts[i];
            
            self->currentTotalMileage = [[NSString stringWithFormat:@"%.2f",moveStepModel.totalMileage] floatValue];
            self->currentTotalConsumption = [[NSString stringWithFormat:@"%.0f",moveStepModel.totalConsumption] intValue];

            NSArray <StepCountData *> *stepArray= moveStepModel.stepCountlist;

            for (StepCountData *stepCountData in stepArray) {
                self->month = stepCountData.startDate.witchMonth;
                [totalStep addObject:@((int)moveStepModel.allStep)];
                [self->mulArray addObject:stepCountData.startDate];
            }
        }
        
        
        
        self->yearStepValue = [[totalStep valueForKeyPath:@"@avg.floatValue"] intValue];

        int temAvgValue = [[totalStep valueForKeyPath:@"@avg.floatValue"] intValue];
        [self->stepArray addObject:@(temAvgValue)];
        
        
        int temMyAvgValue = temAvgValue;
        self->hisView.maxValue = temMyAvgValue+3;
        self->hisView.dataArray = yearStepMulArray;
        self->hisView.presetNum = 12;
        self->hisView.timeLabArray = self->nowDate.thisYearMonths;//@[@"1月",@"2月",@"3月",@"4月",@"5月",@"6月",@"7月",@"8月",@"9月",@"10月",@"11月",@"12月"];
        self->hisView.cellWidth = 12;
        [self->hisView setNeedsDisplay];

        int temavgValue = [[totalStep valueForKeyPath:@"@avg.floatValue"] intValue];
        
        NSString *myStepValue = [NSString stringWithFormat:@"%d",[[totalStep valueForKeyPath:@"@sum.floatValue"] intValue]];
        
        NSString *avgStep = [NSString stringWithFormat:@"%d",temavgValue];
        
        if ([[totalStep valueForKeyPath:@"@sum.floatValue"] intValue] == 0){
            myStepValue = @"- -";
        }
        if (temavgValue == 0){
            avgStep = @"- -";
        }

        [self->dataView setTabLab:kJL_TXT("总步数") TabLab2:kJL_TXT("平均步数") Value1:myStepValue Unit1:kJL_TXT("步") Value2:avgStep Unit2:kJL_TXT("步")];
    }];
}

#pragma mark 加载图表日的界面
-(void)loadDayData{
    [self queryDayFromDB];
}

#pragma mark 加载图表周的界面
-(void)loadWeekData{
    [self queryWeekFromDB];
}

#pragma mark 加载图表月的界面
-(void)loadMonthData{
    [self queryMonthFromDB];
}

#pragma mark 加载图表年的界面
-(void)loadYearData{
    [self queryYearFromDB];
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
    
//    kJLLog(JLLOG_DEBUG, @"scrollViewDidScroll:%f",scrollView.contentOffset.y);
}

//MARK: - 默认数据
-(NSArray *)makeNoneDataBy:(int)number{
    NSMutableArray *ps = [NSMutableArray new];
    for (int i = 0; i<number; i++) {
        CGPoint p = CGPointMake(i, 0);
        [ps addObject:[NSValue valueWithCGPoint:p]];
    }
    return ps;
}



@end
