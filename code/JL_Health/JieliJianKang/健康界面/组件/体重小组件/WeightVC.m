//
//  WeightVC.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/30.
//

#import "WeightVC.h"
#import "JL_RunSDK.h"
#import "DateLabelView.h"
#import "SelectTitleBar.h"
#import "EcDateSelectView.h"
#import "YaLiView.h"
#import "WeightShow.h"
#import "MyTargetVC.h"
#import "WeightSetVC.h"
#import "User_Http.h"
#import "JLSqliteWeight.h"
#import "ContrastView.h"
#import <CoreDraw/CoreDraw.h>

@interface WeightVC ()<DateLabelViewDelegate,SelectActionDelegate,EcDtSltDelegate,YaLiViewDelegate>{
    UIButton *leftBtn;
    UILabel *titleLab;
    UIButton *dayBtn;
    
    DateLabelView   *datelabView;
    SelectTitleBar  *selectView;
    
    YaLiView        *yaliView;
    WeightShow      *weightShow_0;
    WeightShow      *weightShow_1;
    WeightShow      *weightShow_2;
    EcDateSelectView *ecDtSltv;
    
    UIView *subView_1;
    
    float sw;
    float sh;
    
    UILabel *labelBMI;
    UILabel *startLabel;
    UILabel *muBiaoLabel;
    
    UIProgressView *pro;
    
    UIView *view1; //体重设定
    UIView *view2; //体重目标
    
    UIImageView *imv1;
    UIImageView *imv2;
    UIImageView *imv3;
    UIImageView *imv4;
    
    UILabel *label1;
    UILabel *label2;
    UILabel *label3;
    
    NSString *mTargetWeight; //目标体重
    
    DateType    dType;
    float currentWeight;
    
    JLUser *user;
    
    float weekMaxValue;
    float weekMinValue;
    
    float monthMaxValue;
    float monthMinValue;
    
    float yearMaxValue;
    float yearMinValue;
    
    float avgWeek;
    float avgMonth;
    float avgYear;
    
    float proWeek;  //周体重的变化
    float proMonth; //月体重的变化
    float proYear;  //年体重的变化
    
    NSDate *nowDate;
    NSMutableArray *dateArray;
    NSMutableArray *tempWeekDateArray;
    NSMutableArray *tempMonthDateArray;
    NSMutableArray *tempYearDateArray;
    
    NSString *unitStr;
    JL_Chart_Weight *mChartWeight;
}

@end

@implementation WeightVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI{
    sw = [UIScreen mainScreen].bounds.size.width;
    sh = [UIScreen mainScreen].bounds.size.height;
    
    dType =     DateType_Day;
    
    //float all_H = 750;
    
    UIScrollView *scView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [scView setScrollEnabled:YES];
    scView.backgroundColor = [JLColor colorWithString:@"#7D85DD"];
    [self.view addSubview:scView];
    
    [scView setContentOffset:CGPointMake(0, 0)];
    //[scView setContentSize:CGSizeMake(sw, all_H)];
    
    leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(10,kJL_HeightNavBar-40, 40, 40)];
    [leftBtn setImage:[UIImage imageNamed:@"icon_return_nol_white"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBtn];
    
    titleLab = [[UILabel alloc] initWithFrame:CGRectMake(sw/2-120, kJL_HeightNavBar-30, 240, 25)];
    titleLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = [UIColor whiteColor];
    titleLab.text = kJL_TXT("体重");
    [self.view addSubview:titleLab];
    
    dayBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-50, kJL_HeightNavBar-40, 40, 40)];
    [dayBtn setImage:[UIImage imageNamed:@"icon_calender_nol"] forState:UIControlStateNormal];
    [dayBtn addTarget:self action:@selector(dayBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dayBtn];
    
    UIView *subView_0 = [UIView new];
    subView_0.frame = CGRectMake(0, 0, sw, sh);
    [self colorWear:subView_0];
    [scView addSubview:subView_0];
    
    selectView = [[SelectTitleBar alloc] initWithFrame:CGRectMake(16, 40+22, sw-32, 34)];
    selectView.delegate = self;
    selectView.selectColor = [UIColor blueColor];
    [subView_0 addSubview:selectView];
    
    
    float mHeight = selectView.frame.origin.y+selectView.frame.size.height+12;
    datelabView = [[DateLabelView alloc] initWithFrame:CGRectMake(16, mHeight, sw-32, 80)];
    datelabView.delegate = self;
    [subView_0 addSubview:datelabView];
    
    yaliView = [[YaLiView alloc] initWithFrame:CGRectMake(0, 230, sw, 250)];
    yaliView.pColor = kDF_RGBA(241, 135, 83, 1);
    yaliView.nColor = kDF_RGBA(72, 82, 202, 1);
    yaliView.delegate = self;
    [subView_0 addSubview:yaliView];
    
    subView_1 = [UIView new];
    subView_1.frame = CGRectMake(0, 230+250, sw, 405);
    subView_1.backgroundColor = kDF_RGBA(246, 247, 248, 1);
    subView_1.layer.cornerRadius = 25.0;
    [subView_0 addSubview:subView_1];
    
    
    CGRect rect_0 = CGRectMake(20, 16, sw-40.0, 60);
    weightShow_0 = [[WeightShow alloc] initByFrame:rect_0];
    [subView_1 addSubview:weightShow_0];
    
    CGRect rect_1 = CGRectMake(20, 16+60+20, sw-40.0, 60);
    weightShow_1 = [[WeightShow alloc] initByFrame:rect_1];
    [subView_1 addSubview:weightShow_1];
    
    CGRect rect_2 = CGRectMake(20, 16+60+20+60+20, sw-40.0, 60);
    weightShow_2 = [[WeightShow alloc] initByFrame:rect_2];
    [subView_1 addSubview:weightShow_2];
    
    ecDtSltv = [[EcDateSelectView alloc] initWithFrame:CGRectMake(0, 0, sw, [UIScreen mainScreen].bounds.size.height)];
    ecDtSltv.delegate = self;
    ecDtSltv.hidden = YES;
    [self.view addSubview:ecDtSltv];
    
    labelBMI = [[UILabel alloc] init];
    labelBMI.frame = CGRectMake(sw/2-50,datelabView.frame.size.height+datelabView.frame.origin.y+15,self.view.frame.size.width,21);
    labelBMI.numberOfLines = 0;
    [subView_0 addSubview:labelBMI];
    labelBMI.font =  [UIFont fontWithName:@"PingFang SC" size: 14];
    labelBMI.textColor = kDF_RGBA(255, 255, 255, 1.0);
    labelBMI.hidden = YES;
    
    pro=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    pro.frame=CGRectMake(20, labelBMI.frame.size.height+labelBMI.frame.origin.y+20, sw-40, 4);
    pro.trackTintColor = [UIColor whiteColor];
    pro.progressTintColor = kDF_RGBA(87,240,255,1.0);
    pro.layer.cornerRadius = 2;
    [subView_0 addSubview:pro];
    pro.hidden = YES;
    
    startLabel = [[UILabel alloc] init];
    startLabel.frame = CGRectMake(20,pro.frame.size.height+pro.frame.origin.y+20,120,20);
    startLabel.numberOfLines = 0;
    [subView_0 addSubview:startLabel];
    startLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 14];
    startLabel.textColor = kDF_RGBA(255, 255, 255, 1.0);
    startLabel.hidden = YES;
    
    muBiaoLabel = [[UILabel alloc] init];
    muBiaoLabel.frame = CGRectMake(sw-20-90,pro.frame.size.height+pro.frame.origin.y+20,120,20);
    muBiaoLabel.numberOfLines = 0;
    [subView_0 addSubview:muBiaoLabel];
    muBiaoLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 14];
    muBiaoLabel.textColor = kDF_RGBA(255, 255, 255, 1.0);
    muBiaoLabel.hidden = YES;
    
    view1 = [[UIView alloc] init];
    view1.frame = CGRectMake(20,16,sw-40.0,60);
    view1.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    view1.layer.cornerRadius = 12;
    [subView_1 addSubview:view1];
    view1.hidden = YES;
    
    CGRect rect = CGRectMake(16,17,26,26);
    imv1 = [[UIImageView alloc] initWithFrame:rect];
    imv1.contentMode = UIViewContentModeScaleToFill;
    UIImage *image = [UIImage imageNamed:@"icon_record_nol"];
    imv1.image = image;
    [view1 addSubview:imv1];
    
    label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(50,20,sw,21);
    label1.numberOfLines = 0;
    [view1 addSubview:label1];
    label1.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label1.text =  kJL_TXT("体重设定");
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    CGRect rectImv2 = CGRectMake(view1.frame.size.width-12-22,19,22,22);
    imv2 = [[UIImageView alloc] initWithFrame:rectImv2];
    imv2.contentMode = UIViewContentModeScaleToFill;
    UIImage *image2 = [UIImage imageNamed:@"icon_next_nol"];
    imv2.image = image2;
    [view1 addSubview:imv2];
    
    view2 = [[UIView alloc] init];
    view2.frame = CGRectMake(20,16+60+20,sw-40.0,60);
    view2.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    view2.layer.cornerRadius = 12;
    [subView_1 addSubview:view2];
    view2.hidden = YES;
    
    CGRect rectImv3 = CGRectMake(16,17,26,26);
    imv3 = [[UIImageView alloc] initWithFrame:rectImv3];
    imv3.contentMode = UIViewContentModeScaleToFill;
    UIImage *image3 = [UIImage imageNamed:@"icon_goal_nol"];
    imv3.image = image3;
    [view2 addSubview:imv3];
    
    label2 = [[UILabel alloc] init];
    label2.frame = CGRectMake(50,20,sw,21);
    label2.numberOfLines = 0;
    [view2 addSubview:label2];
    label2.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label2.text =  kJL_TXT("体重目标");
    label2.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    CGRect rectImv4 = CGRectMake(view2.frame.size.width-12-22,19,22,22);
    imv4 = [[UIImageView alloc] initWithFrame:rectImv4];
    imv4.contentMode = UIViewContentModeScaleToFill;
    UIImage *image4 = [UIImage imageNamed:@"icon_next_nol"];
    imv4.image = image4;
    [view2 addSubview:imv4];
    
    label3 = [[UILabel alloc] init];
    label3.frame = CGRectMake(view2.frame.size.width-12-22-4-60,20,70,21);
    label3.numberOfLines = 0;
    [view2 addSubview:label3];
    label3.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label3.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UITapGestureRecognizer *view1GestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(weightSettingsClick)];
    [view1 addGestureRecognizer:view1GestureRecognizer];
    view1.userInteractionEnabled=YES;
    
    UITapGestureRecognizer *view2GestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(weightGoalClick)];
    [view2 addGestureRecognizer:view2GestureRecognizer];
    view2.userInteractionEnabled=YES;
    
    nowDate = [NSDate date];
    
    [scView setContentSize:CGSizeMake(sw, selectView.frame.size.height+datelabView.frame.size.height+yaliView.frame.size.height+subView_1.frame.size.height+kJL_HeightTabBar)];
}

-(void)viewWillAppear:(BOOL)animated{
    unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    [self getUserInfo];
    [self barDidSelectIndex:0];
}

-(void)getUserInfo{
    [[User_Http shareInstance] requestGetUserConfigInfo:^(JLUser * _Nonnull userInfo) {
        [JL_Tools mainTask:^{
            if(userInfo != nil){
                self->user = userInfo;
                self->mTargetWeight = [NSString stringWithFormat:@"%.1f",userInfo.weightTarget];
                
                NSString *units = kJL_TXT("公斤");
                float beginWeight = 0.f;
                if([self->unitStr isEqualToString:@"英制"]){
                    units = kJL_TXT("磅");
                    float tempWeight = userInfo.weightTarget*2.205;
                    self->label3.text =  [NSString stringWithFormat:@"%.1f%@",tempWeight,units];
                    beginWeight = (userInfo.weightStart)*2.205;
                }else{
                    self->label3.text =  [NSString stringWithFormat:@"%@%@",self->mTargetWeight,units];
                    beginWeight = userInfo.weightStart;
                }
                
                CGFloat width = [self getWidthWithText:self->label3.text height:21 font:15];
                self->label3.frame = CGRectMake(self->view2.frame.size.width-12-22-width,20,width,21);
                
                self->muBiaoLabel.text = [NSString stringWithFormat:@"%@: %@",kJL_TXT("目标"),self->label3.text];
                self->startLabel.text =  [NSString stringWithFormat:@"%@ %.1f%@",kJL_TXT("起始"),beginWeight,units];
                
//                startLabel.frame = CGRectMake(20,pro.frame.size.height+pro.frame.origin.y+20,120,20);
//                muBiaoLabel.frame = CGRectMake(sw-20-90,pro.frame.size.height+pro.frame.origin.y+20,120,20);
                CGFloat startLabelWidth = [self getWidthWithText:self->startLabel.text height:20 font:14];
                CGFloat muBiaoLabelWidth = [self getWidthWithText:self->muBiaoLabel.text height:20 font:14];

                self->startLabel.frame = CGRectMake(20,self->pro.frame.size.height+self->pro.frame.origin.y+20,startLabelWidth,20);
                self->muBiaoLabel.frame = CGRectMake(self->sw-muBiaoLabelWidth-20,self->pro.frame.size.height+
                                                     self->pro.frame.origin.y+20,muBiaoLabelWidth,20);
                
                //[self DateLabTestData:userInfo.weightStart];
                
                float myHeight = userInfo.height;
                float mHight = [[NSString stringWithFormat:@"%.2f",myHeight/100] floatValue]; //单位:米
                float mWight = [[NSString stringWithFormat:@"%.1f",userInfo.weightStart] floatValue];//单位:公斤
                float bmiVal = mWight/(mHight*mHight);
                if(mHight == 0.f){
                    bmiVal = 0.f;
                }
                if(bmiVal<18.5){
                    self->labelBMI.text =  [NSString stringWithFormat:@"%@ %.1f %@",@"BMI",bmiVal,kJL_TXT("偏低")];
                }else if(bmiVal<24){
                    self->labelBMI.text =  [NSString stringWithFormat:@"%@ %.1f %@",@"BMI",bmiVal,kJL_TXT("正常")];
                }else if(bmiVal<26){
                    self->labelBMI.text =  [NSString stringWithFormat:@"%@ %.1f %@",@"BMI",bmiVal,kJL_TXT("超重")];
                }else if(bmiVal<28){
                    self->labelBMI.text =  [NSString stringWithFormat:@"%@ %.1f %@",@"BMI",bmiVal,kJL_TXT("偏胖")];
                }else{
                    self->labelBMI.text =  [NSString stringWithFormat:@"%@ %.1f %@",@"BMI",bmiVal,kJL_TXT("肥胖")];
                }
            }
        }];
    }];
}

-(void)weightSettingsClick{
    WeightSetVC *vc = [[WeightSetVC alloc] init];
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
}

-(void)weightGoalClick{
    MyTargetVC *vc = [[MyTargetVC alloc] init];
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
    
}

-(void)leftBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dayBtnAction{
    ecDtSltv.hidden = NO;
}

#pragma mark 加载图表周的界面
-(void)loadWeekData{
    [yaliView resetUI];
    
    [self queryWeekFromDB];
    yaliView.gap_L = 30;
    yaliView.gap_R = 50;
    yaliView.type = 0;
    yaliView.textArray = @[kJL_TXT("我的周一"),kJL_TXT("我的周二"),kJL_TXT("我的周三"),kJL_TXT("我的周四"),kJL_TXT("我的周五"),kJL_TXT("我的周六"),kJL_TXT("我的周日")];
    yaliView.dateArray = dateArray;
    yaliView.temDateArray = tempWeekDateArray;
    
    //if(yaliView.dataArray.count>0){
        [yaliView loadUI];
    //}
}

#pragma mark 加载图表月的界面
-(void)loadMonthData{
    [yaliView resetUI];
    
    [self queryMonthFromDB];
    yaliView.gap_L = 15;
    yaliView.gap_R = 15;
    yaliView.type = 1;
    yaliView.textArray = nowDate.thisMonthDays;
    yaliView.dateArray = dateArray;
    yaliView.temDateArray = tempMonthDateArray;

    //if(yaliView.dataArray.count>0){
        [yaliView loadUI];
    //}
}

#pragma mark 加载图表年的界面
-(void)loadYearData{
    [yaliView resetUI];
    
    [self queryYearFromDB];
    yaliView.gap_L = 30;
    yaliView.gap_R = 50;
    yaliView.type = 2;
    yaliView.textArray = nowDate.thisYearMonths;
    yaliView.dateArray = dateArray;
    yaliView.temDateArray = tempYearDateArray;

    //if(yaliView.dataArray.count>0){
        [yaliView loadUI];
    //}
}

//MARK:日历选择回调
-(void)ecDidDateSelected:(NSDate *)date{
    nowDate = date;
    [ecDtSltv setHidden:YES];
    if(dType == 0){
        [self queryDayFromDB];
    }
    if(dType == 1){
        [self loadWeekData];
    }
    if(dType == 2){
        [self loadMonthData];
    }
    if(dType == 3){
        [self loadYearData];
    }
    [self DateLabTestData:currentWeight];
}

#pragma mark 查询数据库日的数据
-(void)queryDayFromDB{
    [JLSqliteWeight s_checkoutWtihStartDate:nowDate withEndDate:nowDate Result:^(NSArray<JL_Chart_Weight *> * _Nonnull charts) {
        if(charts.count ==0){
            self->currentWeight = 0;
        }
        for (JL_Chart_Weight *model in charts) {
            self->mChartWeight = model;
            self->currentWeight = model.weight;
        }
    }];
}

#pragma mark 查询数据库周的数据
-(void)queryWeekFromDB{
    StartAndEndDate *dates = nowDate.thisWeek;

    [JLSqliteWeight s_checkoutWtihStartDate:dates.start withEndDate:dates.end Result:^(NSArray<JL_Chart_Weight *> * _Nonnull charts) {
        
        [self->datelabView setTitleLab:[NSString stringWithFormat:@"%@-%@",dates.start.toYYYYMMdd2,dates.end.toYYYYMMdd2] SecondLabel:@""];
        
        if(charts.count ==0){
            self->currentWeight = 0;
        }
        NSMutableArray *weekMulArray = [NSMutableArray new];
        NSMutableArray *dateMulArray = [NSMutableArray new];
        NSMutableArray *tempDateMulArray = [NSMutableArray new];

        for (JL_Chart_Weight *model in charts) {
            if(weekMulArray.count<=7){
                [weekMulArray addObject:@(model.weight)];
                [dateMulArray addObject:model.date];
                [tempDateMulArray addObject:@(model.date.witchWeekDay-1)];
            }
        }
        
        if(weekMulArray.count>0){
            self->weekMaxValue = [[weekMulArray valueForKeyPath:@"@max.floatValue"] floatValue];
            self->weekMinValue = [[weekMulArray valueForKeyPath:@"@min.floatValue"] floatValue];
            if([weekMulArray valueForKeyPath:@"@avg.floatValue"]!=nil){
                self->avgWeek = [[weekMulArray valueForKeyPath:@"@avg.floatValue"] floatValue];
            }
            
            self->currentWeight = self->avgWeek;
            
            float a = [weekMulArray[0] floatValue];
            float b = [weekMulArray[weekMulArray.count-1] floatValue];
            
            self->proWeek = b-a;
            
            self->yaliView.dataArray = [weekMulArray copy];
        }
        
        self->dateArray = dateMulArray;
        self->tempWeekDateArray = tempDateMulArray;
    }];
}

#pragma mark 查询数据库月的数据
-(void)queryMonthFromDB{
    StartAndEndDate *dates = nowDate.thisMonth;
    
    [JLSqliteWeight s_checkoutWtihStartDate:dates.start withEndDate:dates.end Result:^(NSArray<JL_Chart_Weight *> * _Nonnull charts) {
        
        if(charts.count ==0){
            self->currentWeight = 0;
        }
        NSMutableArray *monthMulArray = [NSMutableArray new];
        NSMutableArray *dateMulArray = [NSMutableArray new];
        NSMutableArray *tempDateMulArray = [NSMutableArray new];

        for (JL_Chart_Weight *model in charts) {
            if(monthMulArray.count<=30){
                [monthMulArray addObject:@(model.weight)];
                [dateMulArray addObject:model.date];
                [tempDateMulArray addObject:@(model.date.witchDay-1)];
            }
        }
        
        if(monthMulArray.count>0){
            self->monthMaxValue = [[monthMulArray valueForKeyPath:@"@max.floatValue"] floatValue];
            self->monthMinValue = [[monthMulArray valueForKeyPath:@"@min.floatValue"] floatValue];
            if([monthMulArray valueForKeyPath:@"@avg.floatValue"]!=nil){
                self->avgMonth = [[monthMulArray valueForKeyPath:@"@avg.floatValue"] floatValue];
            }
            self->currentWeight = self->avgMonth;
            
            float a = [monthMulArray[0] floatValue];
            float b = [monthMulArray[monthMulArray.count-1] floatValue];
            
            self->proMonth = b-a;
            
            self->yaliView.dataArray = [monthMulArray copy];
            self->dateArray = dateMulArray;
        }
        
        self->dateArray = dateMulArray;
        self->tempMonthDateArray = tempDateMulArray;
    }];
}

#pragma mark 查询数据库年的数据
-(void)queryYearFromDB{
    StartAndEndDate *dates = nowDate.thisYear;
    [JLSqliteWeight s_checkoutWtihStartDate:dates.start withEndDate:dates.end Result:^(NSArray<JL_Chart_Weight *> * _Nonnull charts) {
        
        if(charts.count ==0){
            self->currentWeight = 0;
        }
        NSMutableArray *yearMulArray = [NSMutableArray new];
        NSMutableArray *dateMulArray = [NSMutableArray new];
        //NSMutableArray *avgMulArray = [NSMutableArray new];
        NSMutableArray *tempDateMulArray = [NSMutableArray new];
        
        for (JL_Chart_Weight *model in charts) {
            if(yearMulArray.count<=12){
                [yearMulArray addObject:@(model.weight)];
                [dateMulArray addObject:model.date];
                [tempDateMulArray addObject:@(model.date.witchMonth-1)];
            }
        }
        
        if(yearMulArray.count>0){
            self->yearMaxValue = [[yearMulArray valueForKeyPath:@"@max.floatValue"] floatValue];
            self->yearMinValue = [[yearMulArray valueForKeyPath:@"@min.floatValue"] floatValue];
            if([yearMulArray valueForKeyPath:@"@avg.floatValue"]!=nil){
                self->avgYear = [[yearMulArray valueForKeyPath:@"@avg.floatValue"] floatValue];
            }
            
            self->currentWeight = self->avgYear;
            
            float a = [yearMulArray[0] floatValue];
            float b = [yearMulArray[yearMulArray.count-1] floatValue];
            
            self->proYear = b-a;
            
            //[avgMulArray addObject:@(self->avgYear)];
            self->yaliView.dataArray = yearMulArray;
            self->dateArray = dateMulArray;
        }
        
        self->dateArray = dateMulArray;
        self->tempYearDateArray = tempDateMulArray;
    }];
}

///MARK: 日期前后回调
-(void)dateLabelViewPreviousBtnAction{
    switch (dType) {
        case 0:{
            nowDate = nowDate.before;
            [self queryDayFromDB];
        }break;
        case 1:{
            nowDate = nowDate.beforeWeek;
            [self loadWeekData];
        }break;
        case 2:{
            nowDate = nowDate.beforeMonth;
            [self loadMonthData];
        }break;
        case 3:{
            nowDate = nowDate.beforeYear;
            [self loadYearData];
        }break;
        default:
            break;
    }
    [self DateLabTestData:currentWeight];
}

-(void)dateLabelViewNextBtnAction{
    switch (dType) {
        case 0:{
            nowDate = nowDate.next;
            [self queryDayFromDB];
        }break;
        case 1:{
            nowDate = nowDate.nextWeek;
            [self loadWeekData];
        }break;
        case 2:{
            nowDate = nowDate.nextMonth;
            [self loadMonthData];
        }break;
        case 3:{
            nowDate = nowDate.nextYear;
            [self loadYearData];
        }break;
        default:
            break;
    }
    [self DateLabTestData:currentWeight];
}

-(void)updateDateRightBtnStatus{
    switch (dType) {
        case DateType_Day:{
            datelabView.rightBtn.hidden = !nowDate.beforeNow_0;
        }break;
        case DateType_Week:{
            datelabView.rightBtn.hidden = !nowDate.beforeThisWeek_0;
        }break;
        case DateType_Month:{
            datelabView.rightBtn.hidden = !nowDate.beforeThisMonth_0;
        }break;
        case DateType_Year:{
            datelabView.rightBtn.hidden = !nowDate.beforeThisYear_0;
        }break;
        default:
            break;
    }
}

//MARK: 日期选择回调
-(void)barDidSelectIndex:(NSInteger)index{
    dType = index;
    
    if (dType == DateType_Week) {
        ecDtSltv.isWeek = true;
    }else if(dType == DateType_Day){
        ecDtSltv.isWeek = false;
    }
    
    if(dType == 0){
        dayBtn.hidden = NO;
        
        
        labelBMI.hidden = NO;
        pro.hidden = NO;
        startLabel.hidden = NO;
        muBiaoLabel.hidden = NO;
        view1.hidden = NO;
        view2.hidden = NO;
        
        subView_1.frame = CGRectMake(0,self->startLabel.frame.origin.y+self->startLabel.frame.size.height+35, sw, sh-(self->startLabel.frame.origin.y+self->startLabel.frame.size.height+35));
        
        weightShow_0.hidden = YES;
        weightShow_1.hidden = YES;
        weightShow_2.hidden = YES;
        
        yaliView.hidden = YES;
        
        [self queryDayFromDB];
    }
    if(dType == 1){
        subView_1.frame = CGRectMake(0, 230+250, sw, 405);
        
        dayBtn.hidden = NO;
        
        //ecDtSltv.type = 1;
        labelBMI.hidden = YES;
        pro.hidden = YES;
        startLabel.hidden = YES;
        muBiaoLabel.hidden = YES;
        view1.hidden = YES;
        view2.hidden = YES;
        
        weightShow_0.hidden = NO;
        weightShow_1.hidden = NO;
        weightShow_2.hidden = NO;
        
        yaliView.hidden = NO;
        
        [self loadWeekData];
    }
    if(dType == 2){
        dayBtn.hidden = YES;
        subView_1.frame = CGRectMake(0, 230+250, sw, 405);
        
        labelBMI.hidden = YES;
        pro.hidden = YES;
        startLabel.hidden = YES;
        muBiaoLabel.hidden = YES;
        view1.hidden = YES;
        view2.hidden = YES;
        
        weightShow_0.hidden = NO;
        weightShow_1.hidden = NO;
        weightShow_2.hidden = NO;
        
        yaliView.hidden = NO;
        
        [self loadMonthData];
    }
    if(dType == 3){
        
        dayBtn.hidden = YES;
        
        subView_1.frame = CGRectMake(0, 230+250, sw, 405);
        
        labelBMI.hidden = YES;
        pro.hidden = YES;
        startLabel.hidden = YES;
        muBiaoLabel.hidden = YES;
        view1.hidden = YES;
        view2.hidden = YES;
        
        weightShow_0.hidden = NO;
        weightShow_1.hidden = NO;
        weightShow_2.hidden = NO;
        
        yaliView.hidden = NO;
        
        [self loadYearData];
    }
    [self DateLabTestData:currentWeight];
}

-(void)DateLabTestData:(float)weight{
    [self updateDateRightBtnStatus];
    if(dType == 0){
        if(weight == 0.f){
            [datelabView setTitleLab:nowDate.standardDate SecondLabel:@"- -"];
        }else{
            [datelabView setTitleLab:nowDate.standardDate SecondLabel:mChartWeight.date.toHHmm];
        }
        float start = self->user.weightStart;
        if(self->user.weightTarget<start){
            pro.progress = 0;
        }else{
            pro.progress = start/self->user.weightTarget;
        }
    }
    if(dType == 1){
        StartAndEndDate *dates = nowDate.thisWeek;
        [datelabView setTitleLab:[NSString stringWithFormat:@"%@-%@",dates.start.toYYYYMMdd2,dates.end.toYYYYMMdd2] SecondLabel:@""];
        
        weightShow_0.lb_0.text = kJL_TXT("体重");
        
        NSString *units =kJL_TXT("公斤");
        if([self->unitStr isEqualToString:@"英制"]){
            units = kJL_TXT("磅");
            weekMinValue = weekMinValue*2.205;
            weekMaxValue = weekMaxValue*2.205;
            avgWeek = avgWeek*2.205;
            proWeek = proWeek*2.205;
        }
        weightShow_0.lb_1.text = [NSString stringWithFormat:@"%.1f-%.1f%@",weekMinValue,weekMaxValue,units];
        weightShow_1.lb_0.text = kJL_TXT("周均");
        weightShow_1.lb_1.text = [NSString stringWithFormat:@"%.1f%@",avgWeek,units];
        weightShow_2.lb_0.text = kJL_TXT("变化");
        weightShow_2.lb_1.text = [NSString stringWithFormat:@"%.1f%@",proWeek,units];
    }
    if(dType == 2){
        StartAndEndDate *dates = nowDate.thisMonth;
        [datelabView setTitleLab:[NSString stringWithFormat:@"%@-%@",dates.start.toYYYYMMdd2,dates.end.toYYYYMMdd2] SecondLabel:@""];
        
        weightShow_0.lb_0.text = kJL_TXT("体重");
        NSString *units = kJL_TXT("公斤");
        if([self->unitStr isEqualToString:@"英制"]){
            units = kJL_TXT("磅");
            monthMinValue = monthMinValue*2.205;
            monthMaxValue = monthMaxValue*2.205;
            avgMonth = avgMonth*2.205;
            proMonth = proMonth*2.205;
        }
        weightShow_0.lb_1.text = [NSString stringWithFormat:@"%.1f-%.1f%@",monthMinValue,monthMaxValue,units];
        weightShow_1.lb_0.text = kJL_TXT("月均");
        weightShow_1.lb_1.text = [NSString stringWithFormat:@"%.1f%@",avgMonth,units];
        weightShow_2.lb_0.text =  kJL_TXT("变化");
        weightShow_2.lb_1.text = [NSString stringWithFormat:@"%.1f%@",proMonth,units];
    }
    if(dType ==3){
        StartAndEndDate *dates = nowDate.thisYear;
        [datelabView setTitleLab:[NSString stringWithFormat:@"%@-%@",dates.start.toYYYYMMdd2,dates.end.toYYYYMMdd2] SecondLabel:@""];
        
        weightShow_0.lb_0.text = kJL_TXT("体重");
        NSString *units = kJL_TXT("公斤");
        if([self->unitStr isEqualToString:@"英制"]){
            units = kJL_TXT("磅");
            yearMinValue = yearMinValue*2.205;
            yearMaxValue = yearMaxValue*2.205;
            avgYear = avgYear*2.205;
            proYear = proYear*2.205;
        }
        weightShow_0.lb_1.text = [NSString stringWithFormat:@"%.1f-%.1f%@",yearMinValue,yearMaxValue,units];
        weightShow_1.lb_0.text = kJL_TXT("年均");
        weightShow_1.lb_1.text = [NSString stringWithFormat:@"%.1f%@",avgYear,units];
        weightShow_2.lb_0.text =  kJL_TXT("变化");
        weightShow_2.lb_1.text = [NSString stringWithFormat:@"%.1f%@",proYear,units];
    }
    
    // 属性文本生成器
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    NSString *stepStr;
    
    NSString *units = kJL_TXT("公斤");
    if([self->unitStr isEqualToString:@"英制"]){
        units = kJL_TXT("磅");
        weight = weight*2.205;
    }
    if(dType == 0){
        stepStr = [NSString stringWithFormat:@"%.1f %@",weight,units];
    }
    if(dType == 1 || dType ==2){
        stepStr = [NSString stringWithFormat:@"%@ %.1f %@",kJL_TXT("日均"),weight,units];
    }
    if(dType == 3){
        stepStr = [NSString stringWithFormat:@"%@ %.1f %@",kJL_TXT("月均"),weight,units];
    }
    
    textContainer.text = stepStr;
    
    // 整体设置属性
    textContainer.linesSpacing = 2;
    textContainer.paragraphSpacing = 5;
    textContainer.textAlignment = kCTTextAlignmentCenter;
    
    // 文字样式
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [stepStr rangeOfString:[NSString stringWithFormat:@"%.1f",weight]];
    textStorage.font = [UIFont fontWithName:@"PingFangSC-Medium" size:30];
    textStorage.textColor = kDF_RGBA(255, 255, 255, 1);
    [textContainer addTextStorage:textStorage];
    
    // 文字样式
    TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
    textStorage2.range = [stepStr rangeOfString:units];
    textStorage2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    textStorage2.textColor = kDF_RGBA(255, 255, 255, 0.7);
    [textContainer addTextStorage:textStorage2];
    
    // 文字样式
    TYTextStorage *textStorage3 = [[TYTextStorage alloc]init];
    if(dType == 1 || dType ==2){
        textStorage3.range = [stepStr rangeOfString:kJL_TXT("日均")];
    }
    if(dType == 3){
        textStorage3.range = [stepStr rangeOfString:kJL_TXT("月均")];
    }
    textStorage3.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    textStorage3.textColor = kDF_RGBA(255, 255, 255, 0.7);
    [textContainer addTextStorage:textStorage3];
    
    [datelabView setTextWithContainer:textContainer];
}

-(void)YaLiViewClickIndex:(long) index{
    int mIndex = 0;
    if(dType == 1){
        mIndex = (int)[tempWeekDateArray indexOfObject:@(index)];
    }
    if(dType == 2){
        mIndex = (int)[tempMonthDateArray indexOfObject:@(index)];
    }
    if(dType == 3){
        mIndex = (int)[tempYearDateArray indexOfObject:@(index)];
    }
    
    currentWeight =  [self->yaliView.dataArray[mIndex] floatValue];
    NSDate *date = dateArray[mIndex];

    [self DateLabTestData:currentWeight];

    if(dType ==3){
        [datelabView setSecondLab:date.toMM];
    }else{
        [datelabView setSecondLab:date.toMMdd3];
    }
}

-(void)colorWear:(UIView *)view{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame =CGRectMake(0,0,view.frame.size.width,view.frame.size.height);
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[JLColor colorWithString:@"#7D85DD"].CGColor,
                       (id)[JLColor colorWithString:@"#3642D6"].CGColor,
                       nil];
    [view.layer insertSublayer:gradient atIndex:0];
}

/// 计算宽度
/// @param text 文字
/// @param height 高度
/// @param font 字体
- (CGFloat)getWidthWithText:(NSString *)text height:(CGFloat)height font:(CGFloat)font{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size: font]} context:nil];
    return rect.size.width;
}
@end
