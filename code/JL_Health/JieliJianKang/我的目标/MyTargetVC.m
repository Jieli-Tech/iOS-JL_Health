//
//  MyTargetVC.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/4.
//

#import "MyTargetVC.h"
#import "BushuPick.h"
#import "WeightPickView.h"
#import "User_Http.h"

@interface MyTargetVC ()<BushuPickDelegate,WeightPickViewDelegate>{
    __weak IBOutlet NSLayoutConstraint *subTitleView_H;
    __weak IBOutlet UIView *view_0;
    __weak IBOutlet UIView *view_1;
    __weak IBOutlet UILabel *lb_0;
    __weak IBOutlet UILabel *lb_1;
    __weak IBOutlet UILabel *mTitleName;
    __weak IBOutlet UIButton *btnSaveBtn;
    __weak IBOutlet UILabel *muBiaoLabel; //目标步数
    __weak IBOutlet UILabel *stepUnits; //步数的单位
    __weak IBOutlet UILabel *mCalLabels; //消耗的千卡
    __weak IBOutlet UILabel *muBiaoWeight; //目标体重
    __weak IBOutlet UILabel *weightUnits; //目标体重单位

    BushuPick   *pick_0;
    WeightPickView *pickWeightView;
    //TizhongPick *pick_1;

    NSString *mName;         //昵称
    NSString *mGender;       //性别
    int      gender;         //性别索引
    NSString *mBirthday;     //出生年月
    NSString *mBirYear;      //出生年
    NSString *mBirMonth;     //出生月
    NSString *mBirDay;       //出生日
    NSString *mHeight;       //身高
    NSString *mWeight;       //体重
    NSString *mStep;         //步数
    NSString *mTargetWeight; //目标体重
    NSString *mStartWeight;  //起始体重
    
    NSString *unitStr;
    
    JLUser *myUserInfo;
}

@end

@implementation MyTargetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI{
    subTitleView_H.constant = kJL_HeightNavBar;
    view_0.layer.cornerRadius = 8.0;
    view_1.layer.cornerRadius = 8.0;
    
    float sW = [UIScreen mainScreen].bounds.size.width;
    
    muBiaoLabel.text = kJL_TXT("目标步数");
    stepUnits.text = kJL_TXT("步");
    muBiaoWeight.text = kJL_TXT("目标体重");
    
    CGRect rect_0 = CGRectMake(10.0, 100.0, sW-30.0*2, 60);
    pick_0 = [[BushuPick alloc] initWithFrame:rect_0 StartPoint:0 EndPoint:20];
    pick_0.delegate = self;
    [view_0 addSubview:pick_0];
    

    CGRect rect_1 = CGRectMake(10.0, 80.0, sW-30.0*2, 80);

    mTitleName.text = kJL_TXT("目标");
    [btnSaveBtn setTitle:kJL_TXT("保存") forState:UIControlStateNormal];
    
    int startPoint = 0;
    int endPoint = 0;
    
    self->unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];

    if([unitStr isEqualToString:@"英制"]){
        startPoint = 9*2.205;
        endPoint = 250*2.205;
    }else{
        startPoint = 9;
        endPoint = 250;
    }
    pickWeightView = [[WeightPickView alloc] initWithFrame:rect_1 StartPoint:startPoint EndPoint:endPoint];
    pickWeightView.delegate = self;
    [view_1 addSubview:pickWeightView];
    
    if([unitStr isEqualToString:@"英制"]){
        weightUnits.text = kJL_TXT("磅");
    }else{
        weightUnits.text = kJL_TXT("公斤");
    }
    [self getUserInfo];
}

-(void)getUserInfo{
    [[User_Http shareInstance] requestGetUserConfigInfo:^(JLUser * _Nonnull userInfo) {
        self->myUserInfo = userInfo;
        [JL_Tools mainTask:^{
            if(userInfo == nil){
                self->mName = kJL_TXT("请填写");
                self->mBirthday = kJL_TXT("请填写");
                self->mHeight = kJL_TXT("请填写");
                self->mWeight = kJL_TXT("请填写");
                self->mStep = kJL_TXT("请填写");
            } else {
                self->mName = userInfo.nickname;
                self->mGender =  userInfo.genderText;
                self->mBirYear = [NSString stringWithFormat:@"%d",userInfo.birthYear];
                self->mBirMonth = [NSString stringWithFormat:@"%d",userInfo.birthMonth];
                self->mBirDay = [NSString stringWithFormat:@"%d",userInfo.birthDay];
                if([kJL_GET hasPrefix:@"zh"]){
                    self->mBirthday =  [NSString stringWithFormat:@"%@%@%@%@%@%@", self->mBirYear, kJL_TXT("年"), self->mBirMonth, kJL_TXT("月"), self->mBirDay, kJL_TXT("日")];
                }else{
                    self->mBirthday =  [NSString stringWithFormat:@"%@%@%@%@%@", self->mBirYear, @"-", self->mBirMonth, @"-", self->mBirDay];
                }
                self->mHeight  = [NSString stringWithFormat:@"%d",userInfo.height];
                self->mWeight  = [NSString stringWithFormat:@"%.1f",userInfo.weight];
                self->mStep  = [NSString stringWithFormat:@"%d",userInfo.step];
                NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
                if([unitStr isEqualToString:@"英制"]){
                    userInfo.weightTarget = userInfo.weightTarget*2.205;
                }
                if(userInfo.weightTarget==0){
                    userInfo.weightTarget = 10.f;
                }
                self->mTargetWeight = [NSString stringWithFormat:@"%.1f",userInfo.weightTarget];
                self->mStartWeight = [NSString stringWithFormat:@"%.1f",userInfo.weightStart];
                
                if(self->mName.length==0 || self->mBirthday.length == 0||
                   self->mHeight.length == 0||self->mWeight.length == 0||self->mStep.length == 0){
                    self->mName = kJL_TXT("请填写");
                    self->mBirthday = kJL_TXT("请填写");
                    self->mHeight = kJL_TXT("请填写");
                    self->mWeight = kJL_TXT("请填写");
                    self->mStep = kJL_TXT("请填写");
                }
            }
            
            int stepRate = 90;//步/min
            int duration = [self->mStep intValue]/stepRate; //min
            int consume = (int)(0.43*[self->mHeight intValue]+0.57*[self->mWeight intValue]+0.26*stepRate+0.92*duration-108.44);
            if(consume<0){
                consume = 0;
            }
            self->mCalLabels.text = [NSString stringWithFormat:@"%@%d%@",kJL_TXT("消耗约"),consume,kJL_TXT("千卡")];
            self->lb_0.text = self->mStep;
            
            [self->pick_0 setBushuPoint:userInfo.step/1000];
            if(self->mTargetWeight.length ==0){
                [self->pickWeightView setWeightPoint:10*10];
            }else{
                [self->pickWeightView setWeightPoint:[self->mTargetWeight floatValue]*10];
            }
        }];
    }];
}

- (IBAction)btn_back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btn_save:(id)sender {
    unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    if([unitStr isEqualToString:@("英制")]){
        mTargetWeight = [NSString stringWithFormat:@"%.1f",self->myUserInfo.weightTarget/2.205];
    }
    [[User_Http shareInstance] requestUserConfigInfo:mName Gender:mGender BirthdayYear:mBirYear BirthdayMonth:mBirMonth BirthdayDay:mBirDay Height:mHeight Weigtht:mWeight Step:mStep AvatarUrl:@"" WeightStart:self->mStartWeight WeightTarget:mTargetWeight Result:^(NSDictionary * _Nonnull info) {
        [JL_Tools mainTask:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}


static long bushuPoint_last = 0;
-(void)onBushuPick:(BushuPick *)view didChange:(NSInteger)point{
    kJLLog(JLLOG_DEBUG, @"Bushu ---> %ld",(long)point);
    int stepRate = 90;//步/min
    int duration = (int)point/stepRate; //min
    int consume = (int)(0.43*[self->mHeight intValue]+0.57*[self->mWeight intValue]+0.26*stepRate+0.92*duration-108.44);
    if(consume<0){
        consume = 0;
    }
    self->mCalLabels.text = [NSString stringWithFormat:@"%@%d%@",kJL_TXT("消耗约"),consume,kJL_TXT("千卡")];
    
    if (bushuPoint_last != point) {
        AudioServicesPlaySystemSound(1519);
        bushuPoint_last = point;
    }
    lb_0.text = [NSString stringWithFormat:@"%ld",(long)point];
    mStep = lb_0.text;
}

//-(void)onTizhongPick:(TizhongPick *)view didChange:(NSInteger)point{
//    kJLLog(JLLOG_DEBUG, @"Tizhong ---> %ld",(long)point);
//       float vl = (float)point;
//       NSString *txt = [NSString stringWithFormat:@"%.1f",vl/10.0f];
//       lb_1.text = txt;
//       mTargetWeight = lb_1.text;
//}

#pragma mark WeightPickViewDelegate
static long weightPoint_last = 0;
-(void)onWeightPickView:(WeightPickView*)view didChange:(NSInteger)pickPoint{
    /*--- 震动体验 ---*/
    if (weightPoint_last != pickPoint) {
        [self updateWeightUI:pickPoint];
        AudioServicesPlaySystemSound(1519);
        weightPoint_last = pickPoint;
    }
}

-(void)onWeightPickView:(WeightPickView*)view didSelect:(NSInteger)pickPoint{
    float vl = (float)pickPoint;
    self->myUserInfo.weightTarget = vl/10.0f;
    NSString *txt = [NSString stringWithFormat:@"%.1f",vl/10.0f];
    mTargetWeight = txt;
}

-(void)updateWeightUI:(uint16_t)weightPoint{
    if (weightPoint<10) {
        return;
    }
    float wp = (float)weightPoint/10.0;
    self->myUserInfo.weightTarget = wp;
    lb_1.text = [NSString stringWithFormat:@"%.1f",wp];
    mTargetWeight = lb_1.text;
}

@end
