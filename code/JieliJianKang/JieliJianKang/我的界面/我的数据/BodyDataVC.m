//
//  BodyDataVC.m
//  JieliJianKang
//
//  Created by kaka on 2021/2/19.
//

#import "BodyDataVC.h"
#import "BodyDataView.h"
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"
#import "StepDetailViewController.h"
#import "HeartBeatDetailVC.h"
#import "WeightVC.h"
#import "OxygenSaturationVC.h"
#import "SleepDetailViewController.h"
#import "JLSqliteSportRunningRecord.h"
#import "JLSqliteStep.h"
#import "JLSqliteHeartRate.h"
#import "JLSqliteOxyhemoglobinSaturation.h"
#import "JLSqliteSleep.h"
#import <CoreDraw/CoreDraw.h>
#import "DataOverallPlanTools.h"

@interface BodyDataVC ()<BodyDataViewDelegate>{
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    
    UIScrollView *scrollView;
    BodyDataView *view1; //活动统计
    BodyDataView *view2; //健康状况
    
    int currentHeartValue;   //当天的心率值
    NSArray *heartBeatArray; //当天的心率的数组
    
    //步数显示
    NSInteger currentStepValue;
    float currentTotalMileage;
    NSInteger currentTotalConsumption;
    
    NSInteger targetStep;
    float mWeight;
    
    NSInteger oxygenValue;
    
    BodyDataObject *bushu;
    BodyDataObject *zonglicheng;
    BodyDataObject *reliang;
    BodyDataObject *xinlv;
    BodyDataObject *tizhong;
    BodyDataObject *xueyang;
    BodyDataObject *shuimian;
    
    NSString *unitStr;
}

@end

@implementation BodyDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
}

-(void)initData{
    unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    
    //活动统计
    //步数
    bushu = [[BodyDataObject alloc] init];
    bushu.img = [UIImage imageNamed:@"data_icon_step_nol"];
    bushu.funcStr = kJL_TXT("步数");
    bushu.funType = 0;
    
    //总里程
    zonglicheng = [[BodyDataObject alloc] init];
    zonglicheng.img = [UIImage imageNamed:@"data_icon_distance_nol"];
    zonglicheng.funcStr = kJL_TXT("总里程");
    zonglicheng.funType = 1;
    
//    //爬高
//    BodyDataObject *pagao = [[BodyDataObject alloc] init];
//    pagao.img = [UIImage imageNamed:@"data_icon_height_nol"];
//    pagao.funcStr = kJL_TXT("爬高");
//    pagao.funType = 2;
//
//    CGFloat pagaoFloat = 25.8;
//    NSString *mPagao = [NSString stringWithFormat:@"%.1f",pagaoFloat];
//    NSString *pagaoStr = [NSString stringWithFormat:@"%@%@",mPagao,@"米"];
//    NSMutableAttributedString *pagaoTotalStr=[[NSMutableAttributedString alloc] initWithString:pagaoStr attributes:nil];
//
//    NSRange pagao_ranage_1=[pagaoStr rangeOfString:[NSString stringWithFormat:@"%@",mPagao]];
//    NSDictionary *pagaoDic1=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(36, 36, 36, 1.0),NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Bold" size:18],NSFontAttributeName, nil];
//    [pagaoTotalStr addAttributes:pagaoDic1 range:pagao_ranage_1];
//
//    NSRange pagao_range_2 = [pagaoStr rangeOfString:@"米"];
//    NSDictionary *pagaoDic2=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(145, 145, 145, 1.0),NSForegroundColorAttributeName,[UIFont systemFontOfSize:12],NSFontAttributeName, nil];
//    [pagaoTotalStr addAttributes:pagaoDic2 range:pagao_range_2];
//
//    pagao.detailStr = pagaoTotalStr;
    
    //热量
    reliang = [[BodyDataObject alloc] init];
    reliang.img = [UIImage imageNamed:@"data_icon_energy_nol"];
    reliang.funcStr = kJL_TXT("热量");
    reliang.funType = 3;
    
    //健康状况
    //心率
    xinlv = [[BodyDataObject alloc] init];
    xinlv.img = [UIImage imageNamed:@"data_icon_heart_nol"];
    xinlv.funcStr = kJL_TXT("心率");
    xinlv.funType = 4;
    
    //体重
    tizhong = [[BodyDataObject alloc] init];
    tizhong.img = [UIImage imageNamed:@"data_icon_weight_nol"];
    tizhong.funcStr = kJL_TXT("体重");
    tizhong.funType = 5;
    
//    //压力
//    BodyDataObject *yali = [[BodyDataObject alloc] init];
//    yali.img = [UIImage imageNamed:@"data_icon_press_nol"];
//    yali.funcStr = kJL_TXT("压力");
//    yali.funType = 6;
//
//    int yaliInt = 15;
//    NSString *mYali = [NSString stringWithFormat:@"%d",yaliInt];
//    NSString *yaliStr = [NSString stringWithFormat:@"%@%@",mYali,@"放松"];
//    NSMutableAttributedString *yaliTotalStr=[[NSMutableAttributedString alloc] initWithString:yaliStr attributes:nil];
//
//    NSRange yali_ranage_1=[yaliStr rangeOfString:[NSString stringWithFormat:@"%@",mYali]];
//    NSDictionary *yaliDic1=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(36, 36, 36, 1.0),NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Bold" size:18],NSFontAttributeName, nil];
//    [yaliTotalStr addAttributes:yaliDic1 range:yali_ranage_1];
//
//    NSRange yali_ranage_2 = [yaliStr rangeOfString:@"放松"];
//    NSDictionary *yaliDic2=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(145, 145, 145, 1.0),NSForegroundColorAttributeName,[UIFont systemFontOfSize:12],NSFontAttributeName, nil];
//    [yaliTotalStr addAttributes:yaliDic2 range:yali_ranage_2];
//
//    yali.detailStr = yaliTotalStr;
    
    //血氧饱和度
    xueyang = [[BodyDataObject alloc] init];
    xueyang.img = [UIImage imageNamed:@"data_icon_spo_nol"];
    xueyang.funcStr = kJL_TXT("血氧饱和度");
    xueyang.funType = 7;
    
    //睡眠
    shuimian = [[BodyDataObject alloc] init];
    shuimian.img = [UIImage imageNamed:@"data_icon_sleep_nol"];
    shuimian.funcStr = kJL_TXT("睡眠");
    shuimian.funType = 8;
    
    [self getUserInfo];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    
    float sw = [UIScreen mainScreen].bounds.size.width;
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("我的数据");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    if (scrollView == nil) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kJL_HeightStatusBar+44, width, height-kJL_HeightNavBar-44)];
        [self.view addSubview:scrollView];
    }
    scrollView.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    
    UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(21,16, self.view.frame.size.width, 22)];
    lab1.textColor = kDF_RGBA(36, 36, 36, 1);
    [lab1 setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
    lab1.text = kJL_TXT("活动统计");
    [scrollView addSubview:lab1];
    
    CGFloat rowFirHight = 50.0;
    CGFloat sFirHeight = rowFirHight*self.huodongDataArray.count;
    view1 = [[BodyDataView alloc] initWithFrame:CGRectMake(16, 55, width-32, sFirHeight)];
    [JLUI_Effect addShadowOnView:view1];
    view1.delegate = self;
    view1.layer.masksToBounds = YES;
    [scrollView addSubview:view1];
    [view1 config:self.huodongDataArray];
    
    UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(21,view1.frame.origin.y+view1.frame.size.height+16, self.view.frame.size.width, 22)];
    lab2.textColor = kDF_RGBA(36, 36, 36, 1);
    [lab2 setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
    lab2.text = kJL_TXT("健康状况");
    [scrollView addSubview:lab2];
    
    CGFloat rowSecHight = 50.0;
    CGFloat sSecHeight = rowSecHight*self.jiankangDataArray.count;
    view2 = [[BodyDataView alloc] initWithFrame:CGRectMake(16, lab2.frame.origin.y+lab2.frame.size.height+16, width-32, sSecHeight)];
    [JLUI_Effect addShadowOnView:view2];
    view2.delegate = self;
    view2.layer.masksToBounds = YES;
    [scrollView addSubview:view2];
    [view2 config:self.jiankangDataArray];
    
    scrollView.contentSize = CGSizeMake(width,16+lab1.frame.size.height+16+view1.frame.size.height+16+lab2.frame.size.height
                                        +16+view2.frame.size.height);
    scrollView.showsVerticalScrollIndicator = NO;
}

-(void)bodyData:(BodyDataView *) view Selected:(BodyDataObject *)object{
    if ([view isEqual:view1]) {
        switch (object.funType) {
            case 0:
            case 1:
            case 3:
            {
                StepDetailViewController *vc = [[StepDetailViewController alloc] init];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
            }
                break;
            default:
                break;
        }
    }
    
    if ([view isEqual:view2]) {
        switch (object.funType) {
            case 4:
            {
                HeartBeatDetailVC *vc = [[HeartBeatDetailVC alloc] init];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 5:
            {
                WeightVC *vc = [[WeightVC alloc] init];
                [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 6:
            {
                
            }
                break;
            case 7:
            {
                OxygenSaturationVC *vc = [[OxygenSaturationVC alloc] init];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 8:
            {
                SleepDetailViewController *vc = [[SleepDetailViewController alloc] init];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
            }
                break;
            default:
                break;
        }
    }
}

- (IBAction)actionExit:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getUserInfo{
    [[User_Http shareInstance] requestGetUserConfigInfo:^(JLUser * _Nonnull userInfo) {
        [JL_Tools mainTask:^{
            //if(userInfo != nil){
                self->targetStep = [[NSString stringWithFormat:@"%d",userInfo.step] integerValue];
                self->mWeight = userInfo.weight;
                if([self->unitStr isEqualToString:@("英制")]){
                    self->mWeight = userInfo.weight*2.205;
                }
                [self updateUIData];

                self.huodongDataArray = @[self->bushu,self->zonglicheng,self->reliang];
                self.jiankangDataArray = @[self->xinlv,self->tizhong,self->xueyang,self->shuimian];
                
                [self initUI];
            //}
        }];
    }];
}

-(void)updateSleepData:(int )t{
    int hours = (int)t / 3600;
    int minutes = ((int)t / 60) % 60;

    int shuimianHourInt = hours;
    int shuimianMinInt = minutes;
    NSString *mShuimianHour = [NSString stringWithFormat:@"%d",shuimianHourInt];
    NSString *mShuimianMin = [NSString stringWithFormat:@"%d",shuimianMinInt];
    
    NSString *shuimianStr;
    if(shuimianHourInt<1){
        shuimianStr = [NSString stringWithFormat:@"%@ %@",mShuimianMin,kJL_TXT("分钟")];
    }else{
        shuimianStr = [NSString stringWithFormat:@"%@ %@%@ %@",mShuimianHour,kJL_TXT("小时"),mShuimianMin,kJL_TXT("分钟")];
    }
    
    NSMutableAttributedString *shuimianTotalStr=[[NSMutableAttributedString alloc] initWithString:shuimianStr attributes:nil];
    
    NSRange shuimian_hour_ranage=[shuimianStr rangeOfString:[NSString stringWithFormat:@"%@",mShuimianHour]];
    NSDictionary *shuimianDic1=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(36, 36, 36, 1.0),NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Bold" size:18],NSFontAttributeName, nil];
    [shuimianTotalStr addAttributes:shuimianDic1 range:shuimian_hour_ranage];
    
    NSRange shuimian_range_2 = [shuimianStr rangeOfString:kJL_TXT("小时")];
    NSDictionary *shuimianDic2 =[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(145, 145, 145, 1.0),NSForegroundColorAttributeName,[UIFont systemFontOfSize:12],NSFontAttributeName, nil];
    [shuimianTotalStr addAttributes:shuimianDic2 range:shuimian_range_2];
    
    NSRange shuimian_min_ranage=[shuimianStr rangeOfString:[NSString stringWithFormat:@"%@",mShuimianMin]];
    NSDictionary *shuimianDic3=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(36, 36, 36, 1.0),NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Bold" size:18],NSFontAttributeName, nil];
    [shuimianTotalStr addAttributes:shuimianDic3 range:shuimian_min_ranage];
    
    NSRange shuimian_range_4 = [shuimianStr rangeOfString:kJL_TXT("分钟")];
    NSDictionary *shuimianDic4 =[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(145, 145, 145, 1.0),NSForegroundColorAttributeName,[UIFont systemFontOfSize:12],NSFontAttributeName, nil];
    [shuimianTotalStr addAttributes:shuimianDic4 range:shuimian_range_4];
    
    shuimian.detailStr = shuimianTotalStr;
}

-(void)updateStepValue{
    int bushuInt = (int)self->currentStepValue;
    NSString *mBushu = [NSString stringWithFormat:@"%d ",bushuInt];
    NSString *bushuStr = [NSString stringWithFormat:@"%@%@",mBushu,kJL_TXT("步")];
    NSMutableAttributedString *bushuTotalStr=[[NSMutableAttributedString alloc] initWithString:bushuStr attributes:nil];
    
    NSRange bushu_ranage_1=[bushuStr rangeOfString:[NSString stringWithFormat:@"%@",mBushu]];
    NSDictionary *bushuDic1=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(36, 36, 36, 1.0),NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Bold" size:18],NSFontAttributeName, nil];
    [bushuTotalStr addAttributes:bushuDic1 range:bushu_ranage_1];
    
    NSRange bushu_range_2 = [bushuStr rangeOfString:@"步"];
    NSDictionary *bushuDic2=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(145, 145, 145, 1.0),NSForegroundColorAttributeName,[UIFont systemFontOfSize:12],NSFontAttributeName, nil];
    [bushuTotalStr addAttributes:bushuDic2 range:bushu_range_2];
    
    bushu.detailStr = bushuTotalStr;
}

-(void)updateTotalMileage{
    NSString *myUnits = @"公里";
    if([unitStr isEqualToString:@("英制")]){
        myUnits = kJL_TXT("英里");
    }else{
        myUnits = kJL_TXT("公里");
    }
    CGFloat zonglichengFloat = self->currentTotalMileage;
    NSString *mZonglicheng = [NSString stringWithFormat:@"%.2f ",zonglichengFloat];
    NSString *zonglichengStr = [NSString stringWithFormat:@"%@%@",mZonglicheng,myUnits];
    NSMutableAttributedString *zonglichengTotalStr=[[NSMutableAttributedString alloc] initWithString:zonglichengStr attributes:nil];
    
    NSRange zonglicheng_ranage_1=[zonglichengStr rangeOfString:[NSString stringWithFormat:@"%@",mZonglicheng]];
    NSDictionary *zonglichengDic1=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(36, 36, 36, 1.0),NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Bold" size:18],NSFontAttributeName, nil];
    [zonglichengTotalStr addAttributes:zonglichengDic1 range:zonglicheng_ranage_1];
    
    NSRange zonglicheng_range_2 = [zonglichengStr rangeOfString:myUnits];
    NSDictionary *zonglichengDic2=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(145, 145, 145, 1.0),NSForegroundColorAttributeName,[UIFont systemFontOfSize:12],NSFontAttributeName, nil];
    [zonglichengTotalStr addAttributes:zonglichengDic2 range:zonglicheng_range_2];
    
    zonglicheng.detailStr = zonglichengTotalStr;
}

-(void)updateTotalConsumption{
    int reliangInt = (int)currentTotalConsumption;
    NSString *mReliang = [NSString stringWithFormat:@"%d ",reliangInt];
    NSString *reliangStr = [NSString stringWithFormat:@"%@%@",mReliang,kJL_TXT("千卡")];
    NSMutableAttributedString *reliangTotalStr=[[NSMutableAttributedString alloc] initWithString:reliangStr attributes:nil];
    
    NSRange reliang_ranage_1=[reliangStr rangeOfString:[NSString stringWithFormat:@"%@",mReliang]];
    NSDictionary *reliangDic1=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(36, 36, 36, 1.0),NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Bold" size:18],NSFontAttributeName, nil];
    [reliangTotalStr addAttributes:reliangDic1 range:reliang_ranage_1];
    
    NSRange reliang_ranage_2 = [reliangStr rangeOfString:kJL_TXT("千卡")];
    NSDictionary *reliangDic2=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(145, 145, 145, 1.0),NSForegroundColorAttributeName,[UIFont systemFontOfSize:12],NSFontAttributeName, nil];
    [reliangTotalStr addAttributes:reliangDic2 range:reliang_ranage_2];
    
    reliang.detailStr = reliangTotalStr;
}

-(void)updateTotalXinLv{
    int xinlvInt = currentHeartValue;
    NSString *mXinlv = [NSString stringWithFormat:@"%d ",xinlvInt];
    NSString *xinlvStr = [NSString stringWithFormat:@"%@%@",mXinlv,kJL_TXT("次/分钟")];
    NSMutableAttributedString *xinlvTotalStr=[[NSMutableAttributedString alloc] initWithString:xinlvStr attributes:nil];
    
    NSRange xinlv_ranage_1=[xinlvStr rangeOfString:[NSString stringWithFormat:@"%@",mXinlv]];
    NSDictionary *xinlvDic1=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(36, 36, 36, 1.0),NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Bold" size:18],NSFontAttributeName, nil];
    [xinlvTotalStr addAttributes:xinlvDic1 range:xinlv_ranage_1];
    
    NSRange xinlv_ranage_2 = [xinlvStr rangeOfString:kJL_TXT("次/分钟")];
    NSDictionary *xinlvDic2=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(145, 145, 145, 1.0),NSForegroundColorAttributeName,[UIFont systemFontOfSize:12],NSFontAttributeName, nil];
    [xinlvTotalStr addAttributes:xinlvDic2 range:xinlv_ranage_2];
    
    xinlv.detailStr = xinlvTotalStr;
}

-(void)updateTiZhong{
    CGFloat tizhongFloat = mWeight;
    NSString *mTizhong = [NSString stringWithFormat:@"%.1f ",tizhongFloat];
    
    NSString *units = kJL_TXT("公斤");
    if([unitStr isEqualToString:@("英制")]){
        units = kJL_TXT("磅");
    }
    NSString *tizhongStr = [NSString stringWithFormat:@"%@%@",mTizhong,units];
    NSMutableAttributedString *tizhongTotalStr=[[NSMutableAttributedString alloc] initWithString:tizhongStr attributes:nil];
    
    NSRange tizhong_ranage_1=[tizhongStr rangeOfString:[NSString stringWithFormat:@"%@",mTizhong]];
    NSDictionary *tizhongDic1=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(36, 36, 36, 1.0),NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Bold" size:18],NSFontAttributeName, nil];
    [tizhongTotalStr addAttributes:tizhongDic1 range:tizhong_ranage_1];
    
    NSRange tizhong_ranage_2 = [tizhongStr rangeOfString:units];
    NSDictionary *tizhongDic2=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(145, 145, 145, 1.0),NSForegroundColorAttributeName,[UIFont systemFontOfSize:12],NSFontAttributeName, nil];
    [tizhongTotalStr addAttributes:tizhongDic2 range:tizhong_ranage_2];
    
    tizhong.detailStr = tizhongTotalStr;
}

-(void)updateXueYang{
    CGFloat xueyangFloat = oxygenValue;
    NSString *mXueyang = [NSString stringWithFormat:@"%.0f ",xueyangFloat];
    NSString *xueyangStr = [NSString stringWithFormat:@"%@%@",mXueyang,@"%"];
    NSMutableAttributedString *xueyangTotalStr=[[NSMutableAttributedString alloc] initWithString:xueyangStr attributes:nil];
    
    NSRange xueyang_ranage_1=[xueyangStr rangeOfString:[NSString stringWithFormat:@"%@",mXueyang]];
    NSDictionary *xueyangDic1=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(36, 36, 36, 1.0),NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Bold" size:18],NSFontAttributeName, nil];
    [xueyangTotalStr addAttributes:xueyangDic1 range:xueyang_ranage_1];
    
    NSRange xueyang_ranage_2 = [xueyangStr rangeOfString:@"%"];
    NSDictionary *xueyangDic2=[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(145, 145, 145, 1.0),NSForegroundColorAttributeName,[UIFont systemFontOfSize:12],NSFontAttributeName, nil];
    [xueyangTotalStr addAttributes:xueyangDic2 range:xueyang_ranage_2];
    
    xueyang.detailStr = xueyangTotalStr;
}

#pragma mark 更新UI的数据
-(void)updateUIData{
    //获取步数记录数据
    [JLSqliteStep s_checkoutTheLastDataWithResult:^(JL_Chart_MoveSteps * _Nonnull chart) {

        JL_Chart_MoveSteps *moveSteps = chart;
        self->currentStepValue = (int)moveSteps.allStep;
        if([self->unitStr isEqualToString:@("英制")]){
            self->currentTotalMileage = [[NSString stringWithFormat:@"%.2f",(moveSteps.totalMileage/100)*0.621] floatValue];
        }else{
            self->currentTotalMileage = [[NSString stringWithFormat:@"%.2f",moveSteps.totalMileage/100] floatValue];
        }
        self->currentTotalConsumption = [[NSString stringWithFormat:@"%.0f",moveSteps.totalConsumption] intValue];
    }];
    
    //获取心率记录数据
    [JLSqliteHeartRate s_checkoutTheLastDataWithResult:^(JLWearSyncHealthHeartRateChart * _Nonnull chart) {
        NSMutableArray *dayMulArray = [NSMutableArray new];
        
        JLWearSyncHealthHeartRateChart *model = chart;
        
        NSArray <HeartRateData *> *heartRatelist = model.heartRatelist;
        HeartRateData *heartRateData = heartRatelist[0];
        NSArray *heartRates = heartRateData.heartRates;
        
        for (int i =0; i<heartRates.count; i++) {
            float value = [heartRates[i] floatValue];
            NSValue *v = [NSValue valueWithCGPoint:CGPointMake(i,value)];
            [dayMulArray addObject:v];
        }
        
        if(dayMulArray.count>0){
            NSValue *v = dayMulArray[dayMulArray.count-1];
            CGPoint pt = [v CGPointValue];
            self->currentHeartValue = (int)pt.y;
        }
    }];
    
    //获取血氧饱和度
    [JLSqliteOxyhemoglobinSaturation s_checkoutTheLastDataWithResult:^(JL_Chart_OxyhemoglobinSaturation * _Nonnull chart) {
        JL_Chart_OxyhemoglobinSaturation *oxyHemo = chart;
        NSArray <BloodOxyganData *> *bloodOxyganArray= oxyHemo.bloodOxyganlist;
        BloodOxyganData *bloodOxyganData = bloodOxyganArray[0];
        NSArray *bloodOxygans = bloodOxyganData.bloodOxygans;
        if(bloodOxygans.count>0){
            float value = [bloodOxygans[0] floatValue];
            self->oxygenValue = value;
        }
    }];
    
    //获取睡眠记录
    [JLSqliteSleep s_checkoutTheLastDataWithResult:^(JLWearSyncHealthSleepChart * _Nonnull chart) {
        SleepDataFormatModel *tgModel = [SleepDataFormatModel new];
        NSMutableArray *napsArray = [NSMutableArray new];
        NSMutableArray *points = [NSMutableArray new];
        for (SleepData *spD in chart.sleepDataArray) {
            NSTimeInterval dateTimer = [spD.startDate timeIntervalSince1970];
            for (int i = 0; i<spD.sleeps.count; i++) {
                JLWearSleepModel *tmpModel = spD.sleeps[i];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateTimer];
                ECDiagramPoint *point;
                switch (tmpModel.type) {
                    case WatchSleep_WideAwake:{
                        tgModel.detail.awakeCount+=1;
                        point = [ECDiagramPoint make:date len:tmpModel.duration*60 type:SleepType_Awake];
                        tgModel.detail.awake+=tmpModel.duration;
                    }break;
                    case WatchSleep_Deep:{
                        point = [ECDiagramPoint make:date len:tmpModel.duration*60 type:SleepType_Deep];
                        tgModel.detail.deep+=tmpModel.duration;
                    }break;
                    case WatchSleep_Light:{
                        point = [ECDiagramPoint make:date len:tmpModel.duration*60 type:SleepType_Shallow];
                        tgModel.detail.shallow+=tmpModel.duration;
                    }break;
                    case WatchSleep_SporadicNaps:{
                        tgModel.detail.sporadicNaps.duration += tmpModel.duration;
                        [napsArray addObject:[SleepNapModel makeNap:date with:tmpModel]];
                    }break;
                    case WatchSleep_RapidEyeMovement:{
                        point = [ECDiagramPoint make:date len:tmpModel.duration*60 type:SleepType_Rem];
                        tgModel.detail.rem+=tmpModel.duration;
                    }break;
                }
                if (point) {
                    [points addObject:point];
                    dateTimer+=(tmpModel.duration*60);
                }
            }
        }
        
        tgModel.isHistogram = NO;
        tgModel.pointsArray = points;
        tgModel.detail.arrayNaps = napsArray;
        
        [self updateSleepData:(int)tgModel.detail.all*60];
    }];
    
    [self updateStepValue];
    [self updateTotalMileage];
    [self updateTotalConsumption];
    [self updateTotalXinLv];
    [self updateTiZhong];
    [self updateXueYang];
}

@end
