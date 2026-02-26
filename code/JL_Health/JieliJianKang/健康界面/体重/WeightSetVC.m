//
//  WeightSetVC.m
//  JieliJianKang
//
//  Created by kaka on 2021/2/22.
//

#import "WeightSetVC.h"
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"
#import "WeightPickView.h"
#import "BirthDayInfoView.h"
#import "HourMinutePickerView.h"
#import "JLSqliteWeight.h"
#import "User_Http.h"
#import "UserDataSync.h"

@interface WeightSetVC ()<BirthDayInfoDelegate,WeightPickViewDelegate,HourMinutePickerDelegate>{
    UIView   *dateView;
    UIView   *weightView;
    UIButton *okBtn;
    
    WeightPickView   *pickWeightView;
    NSMutableArray   *weightCollectArray;
    float            weightCurrent;
    UILabel          *weightLabel;
    UILabel          *weightLabel2;
    float            sw;
    float            sh;
    
    __weak IBOutlet UIView   *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    
    BirthDayInfoView     *birthDayInfoView;
    HourMinutePickerView *hourMinutePickerView;
    
    UILabel *dateLabel2;
    UILabel *timeLabel2;
    
    long year;
    UInt8 month;
    UInt8 mDay;
    UInt8 hour;
    UInt8 min;
    
    NSDate *settingsWeight; //设定当前的体重
    
    double currentYear;  //当前的年
    double currentMonth; //当前的月
    double currentDay;   //当前的日期
    double currentHour;  //当前的时
    double currentMin;   //当前的分
    
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
    
    UIView *contentView;
    UIView *contentView2;
}

@end

@implementation WeightSetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self getUserInfo];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    
    sw = [UIScreen mainScreen].bounds.size.width;
    sh = [UIScreen mainScreen].bounds.size.height;

    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("体重设定");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    CGFloat height = kJL_HeightNavBar;
    
    dateView = [[UIView alloc] initWithFrame:CGRectMake(16, height+20, sw-32, 120)];
    [self.view addSubview:dateView];
    dateView.layer.cornerRadius = 8;
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw-32, 60)];
    [dateView addSubview:contentView];
    contentView.layer.cornerRadius = 8;
    
    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.frame = CGRectMake(18,20,sw-125,21);
    dateLabel.numberOfLines = 0;
    [contentView addSubview:dateLabel];
    dateLabel.font =  [UIFont fontWithName:@"Helvetica-Bold" size: 15];
    dateLabel.text =  kJL_TXT("日期");
    dateLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UIButton *dateBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-32-4-22,19,22,22)];
    [dateBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [contentView addSubview:dateBtn];
    contentView.backgroundColor = kDF_RGBA(255, 255, 255, 1);
    
    dateLabel2 = [[UILabel alloc] init];
    dateLabel2.frame = CGRectMake(contentView.frame.size.width-138,20,108,20);
    dateLabel2.numberOfLines = 0;
    [contentView addSubview:dateLabel2];
    dateLabel2.font =  [UIFont fontWithName:@"PingFang SC" size: 14];
    dateLabel2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sw-32-32, 1)];
    [contentView addSubview:view1];
    view1.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    contentView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 60, sw-32, 60)];
    [dateView addSubview:contentView2];
    contentView2.layer.cornerRadius = 8;
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.frame = CGRectMake(18,20,sw-125,21);
    timeLabel.numberOfLines = 0;
    [contentView2 addSubview:timeLabel];
    timeLabel.font =  [UIFont fontWithName:@"Helvetica-Bold" size: 15];
    timeLabel.text =  kJL_TXT("时间");
    timeLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UIButton *timeBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-32-4-22,19,22,22)];
    [timeBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [contentView2 addSubview:timeBtn];
    contentView2.backgroundColor = kDF_RGBA(255, 255, 255, 1);
    
    timeLabel2 = [[UILabel alloc] init];
    timeLabel2.frame = CGRectMake(contentView2.frame.size.width-75,20,45,20);
    timeLabel2.numberOfLines = 0;
    [contentView2 addSubview:timeLabel2];
    timeLabel2.font =  [UIFont fontWithName:@"PingFang SC" size: 14];
    timeLabel2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    
    UITapGestureRecognizer *dateGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dataClick)];
    [contentView addGestureRecognizer:dateGestureRecognizer];
    contentView.userInteractionEnabled=YES;
    
    UITapGestureRecognizer *timeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeClick)];
    [contentView2 addGestureRecognizer:timeGestureRecognizer];
    contentView2.userInteractionEnabled=YES;
    
    UILabel *tizhongLabel = [[UILabel alloc] init];
    tizhongLabel.frame = CGRectMake(34,dateView.frame.origin.y+dateView.frame.size.height+12,50,21);
    tizhongLabel.numberOfLines = 0;
    [self.view addSubview:tizhongLabel];
    [tizhongLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    tizhongLabel.text =  kJL_TXT("体重");
    tizhongLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    weightView = [[UIView alloc] initWithFrame:CGRectMake(16, tizhongLabel.frame.origin.y+tizhongLabel.frame.size.height+11, sw-32, 160)];
    [self.view addSubview:weightView];
    weightView.backgroundColor = kDF_RGBA(255, 255, 255, 1);
    weightView.layer.cornerRadius = 8;
    
    weightLabel = [[UILabel alloc] init];
    weightLabel.frame = CGRectMake((sw-32)/2-100/2,22,100,42);
    weightLabel.numberOfLines = 0;
    [weightView addSubview:weightLabel];
    weightLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:30];
    weightLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    weightLabel.contentMode = UIViewContentModeCenter;
    
    weightLabel2 = [[UILabel alloc] init];
    weightLabel2.frame = CGRectMake(sw-32-126-50,29,38,32);
    weightLabel2.numberOfLines = 0;
    [weightView addSubview:weightLabel2];
    weightLabel2.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    weightLabel2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    weightLabel2.contentMode = UIViewContentModeLeft;
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    if([unitStr isEqualToString:@"英制"]){
        weightLabel2.text = kJL_TXT("磅");
    }else{
        weightLabel2.text = kJL_TXT("公斤");
    }
    
    weightCollectArray = [NSMutableArray new];

    int startPoint = 0;
    int endPoint = 0;
    
    if([unitStr isEqualToString:@"英制"]){
        startPoint = 9*2.205;
        endPoint = 250*2.205;
    }else{
        startPoint = 9;
        endPoint = 250;
    }
    
    pickWeightView = [[WeightPickView alloc] initWithFrame:CGRectMake(18, weightLabel.frame.origin.y+weightLabel.frame.size.height+14, sw-32-36, 70)
                                    StartPoint:startPoint EndPoint:endPoint];
    pickWeightView.delegate = self;
    [weightView addSubview:pickWeightView];
    
    okBtn = [[UIButton alloc] initWithFrame:CGRectMake(16, weightView.frame.origin.y+weightView.frame.size.height+100, sw-32, 52)];
    [okBtn addTarget:self action:@selector(actionOk:) forControlEvents:UIControlEventTouchUpInside];
    [okBtn setTitle:kJL_TXT("确定") forState:UIControlStateNormal];
    [okBtn setTitleColor:kDF_RGBA(128, 91, 235, 1.0) forState:UIControlStateNormal];
    [self.view addSubview:okBtn];
    okBtn.backgroundColor = kDF_RGBA(255, 255, 255, 1);
    okBtn.layer.cornerRadius = 8;
    
    birthDayInfoView = [[BirthDayInfoView alloc]initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self.view addSubview:birthDayInfoView];
    birthDayInfoView.delegate = self;
    birthDayInfoView.hidden = YES;
    
    hourMinutePickerView = [[HourMinutePickerView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self.view addSubview:hourMinutePickerView];
    hourMinutePickerView.delegate = self;
    hourMinutePickerView.hidden = YES;
    hourMinutePickerView.type = 0;
    
    [self getCurrentDate];
    
    if([kJL_GET hasPrefix:@"zh"]){
        birthDayInfoView.selectValue =[NSString stringWithFormat:@"%0.f%@%0.f%@%0.f%@",currentYear,kJL_TXT("年"),currentMonth,kJL_TXT("月"),currentDay,kJL_TXT("日")];
    }else{
        birthDayInfoView.selectValue =[NSString stringWithFormat:@"%0.f%@%0.f%@%0.f",currentYear,@"-",currentMonth,@"-",currentDay];
    }
    hourMinutePickerView.selectIndexs = @[@(currentHour),@(currentMin)];
    
    if([kJL_GET hasPrefix:@"zh"]){
        dateLabel2.text =  [NSString stringWithFormat:@"%0.f%@%0.f%@%0.f%@",currentYear,kJL_TXT("年"),currentMonth,kJL_TXT("月"),currentDay,kJL_TXT("日")];
    }else{
        dateLabel2.text =  [NSString stringWithFormat:@"%0.f%@%0.f%@%0.f",currentYear,@"-",currentMonth,@"-",currentDay];
    }
    CGFloat length1 = [self getWidthWithString:dateLabel2.text font:[UIFont fontWithName:@"PingFang SC" size: 14]];
    dateLabel2.frame = CGRectMake(contentView.frame.size.width-length1-30,20,length1,20);
    
    if(currentHour<10&&currentMin>10){
        timeLabel2.text = [NSString stringWithFormat:@"%d%0.f%@%0.f",0,currentHour,@":",currentMin];
    }if(currentHour>=10&currentMin<10){
        timeLabel2.text = [NSString stringWithFormat:@"%0.f%@%d%0.f",currentHour,@":",0,currentMin];
    }if(currentHour<10&&currentMin<=10){
        if(currentMin == 10){
            timeLabel2.text = [NSString stringWithFormat:@"%d%0.f%@%0.f",0,currentHour,@":",currentMin];
        }else{
            timeLabel2.text = [NSString stringWithFormat:@"%d%0.f%@%d%0.f",0,currentHour,@":",0,currentMin];
        }
    }if(currentHour>=10 && currentMin>=10){
        timeLabel2.text = [NSString stringWithFormat:@"%0.f%@%0.f",currentHour,@":",currentMin];
    }
    
    CGFloat length2 = [self getWidthWithString:timeLabel2.text font:[UIFont fontWithName:@"PingFang SC" size: 14]];
    timeLabel2.frame = CGRectMake(contentView2.frame.size.width-length2-30,20,45,20);
}

-(void)dataClick{
    birthDayInfoView.hidden = NO;
}

#pragma mark 获取当前的NSDate
-(void)getCurrentDate{
    // 获取代表公历的NSCalendar对象
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 获取当前日期
    NSDate* dt = [NSDate date];
    // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
    unsigned unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |  NSCalendarUnitDay |
    NSCalendarUnitHour |  NSCalendarUnitMinute |
    NSCalendarUnitSecond | NSCalendarUnitWeekday;
    // 获取不同时间字段的信息
    NSDateComponents* comp = [gregorian components: unitFlags
                                          fromDate:dt];
    currentYear  = comp.year;
    currentMonth = comp.month;
    currentDay   = comp.day;
    currentHour  = comp.hour;
    currentMin   = comp.minute;
    
    year = currentYear;
    month = currentMonth;
    mDay = currentDay;
    hour = currentHour;
    min = currentMin;
    
    [JL_Tools setUser:@(year) forKey:@"year"];
    [JL_Tools setUser:@(month) forKey:@"month"];
    [JL_Tools setUser:@(mDay) forKey:@"mDay"];
    [JL_Tools setUser:@(hour) forKey:@"hour"];
    [JL_Tools setUser:@(min) forKey:@"min"];
}

-(void)timeClick{
    hourMinutePickerView.hidden = NO;
}

-(void)getUserInfo{
    self->year = [[JL_Tools getUserByKey:@"year"] doubleValue];
    self->month = [[JL_Tools getUserByKey:@"month"] intValue];
    self->mDay = [[JL_Tools getUserByKey:@"mDay"] intValue];
    self->hour = [[JL_Tools getUserByKey:@"hour"] intValue];
    self->min = [[JL_Tools getUserByKey:@"min"] intValue];
    
    [[User_Http shareInstance] requestGetUserConfigInfo:^(JLUser * _Nonnull userInfo) {
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
                self->mTargetWeight = [NSString stringWithFormat:@"%.1f",userInfo.weightTarget];
                NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
                if([unitStr isEqualToString:@"英制"]){
                    userInfo.weightStart = userInfo.weightStart*2.205;
                }
                if(userInfo.weightStart ==0){
                    userInfo.weightStart = 10.f;
                }
                self->mStartWeight= [NSString stringWithFormat:@"%.1f",userInfo.weightStart];
                
                if(self->mName.length==0 || self->mBirthday.length == 0||
                   self->mHeight.length == 0||self->mWeight.length == 0||self->mStep.length == 0){
                    self->mName = kJL_TXT("请填写");
                    self->mBirthday = kJL_TXT("请填写");
                    self->mHeight = kJL_TXT("请填写");
                    self->mWeight = kJL_TXT("请填写");
                    self->mStep = kJL_TXT("请填写");
                }
            }
            NSString *txt = [NSString stringWithFormat:@"%.1f", [self->mStartWeight floatValue]];
            self->weightLabel.text = txt;
            if(self->mStartWeight.length == 0){
                [self->pickWeightView setWeightPoint:10*10];
            }else{
                [self->pickWeightView setWeightPoint:[self->mStartWeight floatValue]*10];
            }
        }];
    }];
}

-(void)actionOk:(UIButton *)btn{
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    if([unitStr isEqualToString:@("英制")]){
        weightCurrent = weightCurrent/2.205;
    }
    
    [[User_Http shareInstance] requestUserConfigInfo:mName Gender:[NSString stringWithFormat:@"%d",gender] BirthdayYear:mBirYear BirthdayMonth:mBirMonth BirthdayDay:mBirDay Height:mHeight Weigtht:mWeight Step:mStep AvatarUrl:@"" WeightStart:[NSString stringWithFormat:@"%.1f",weightCurrent] WeightTarget:self->mTargetWeight  Result:^(NSDictionary * _Nonnull info) {
    }];

    if(year==0||month==0||mDay==0||hour==0||min==0){
        [DFUITools showText:kJL_TXT("请先选择时间") onView:self.view delay:1.0];
        return;
    }
    NSString *date = [NSString stringWithFormat:@"%ld-%d-%d %d:%d",year,month,mDay,hour,min];
    
    JL_Chart_Weight *model = [[JL_Chart_Weight alloc] init];
    model.weight = [[NSString stringWithFormat:@"%.1f",weightCurrent] floatValue];
    
    NSDateFormatter *dateFormatter = [EcTools cachedFm];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *mDate = [dateFormatter dateFromString:date];
    model.date = mDate;
    [JLSqliteWeight s_update:model];
    [UserDataSync uploadHealthWeightData];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionExit:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

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
    NSString *txt = [NSString stringWithFormat:@"%.1f",vl/10.0f];
    weightCurrent = [txt floatValue];
}

-(void)updateWeightUI:(uint16_t)weightPoint{
    if (weightPoint<10) {
        return;
    }
    float wp = (float)weightPoint/10.0;
    if(wp>=100.0){
        weightLabel2.frame = CGRectMake(weightLabel.frame.origin.x+weightLabel.frame.size.width-20,29,38,32);
    }else{
        weightLabel2.frame = CGRectMake(weightLabel.frame.origin.x+weightLabel.frame.size.width-35,29,38,32);
    }
    weightLabel.text = [NSString stringWithFormat:@"%.1f",wp];
}

-(void)birthdayAction:(NSString *)birthYear Month:(NSString *)birthMonth Day:(NSString *)day SelectDate:(NSString *)date{
    year = [birthYear intValue];
    month = [birthMonth intValue];
    mDay = [day intValue];
    
    [JL_Tools setUser:@(year) forKey:@"year"];
    [JL_Tools setUser:@(month) forKey:@"month"];
    [JL_Tools setUser:@(mDay) forKey:@"mDay"];
    
    if([kJL_GET hasPrefix:@"zh"]){
        dateLabel2.text =  [NSString stringWithFormat:@"%@%@%@%@%@%@",birthYear,kJL_TXT("年"),birthMonth,kJL_TXT("月"),day,kJL_TXT("日")];
    }else{
        dateLabel2.text =  [NSString stringWithFormat:@"%@%@%@%@%@",birthYear,@"-",birthMonth,@"-",day];
    }
    
    CGFloat length = [self getWidthWithString:dateLabel2.text font:[UIFont fontWithName:@"PingFang SC" size: 14]];
    dateLabel2.frame = CGRectMake(contentView.frame.size.width-length-30,20,length,20);
}

-(void)HourMinutePickerActionStartTime:(NSMutableArray *) selectArray{
    hour = (UInt8)[selectArray[0] intValue];
    min = (UInt8)[selectArray[1] intValue];
    
    [JL_Tools setUser:@(hour) forKey:@"hour"];
    [JL_Tools setUser:@(min) forKey:@"min"];
    
    hourMinutePickerView.selectIndexs = @[@(hour),@(min)];
    
    if(hour<10&&min>10){
        timeLabel2.text = [NSString stringWithFormat:@"%d%d%@%d",0,hour,@":",min];
    }if(hour>=10&&min<10){
        timeLabel2.text = [NSString stringWithFormat:@"%d%@%d%d",hour,@":",0,min];
    }if(hour<10&&min<=10){
        if(min ==10){
            timeLabel2.text = [NSString stringWithFormat:@"%d%d%@%d",0,hour,@":",min];
        }else{
            timeLabel2.text = [NSString stringWithFormat:@"%d%d%@%d%d",0,hour,@":",0,min];
        }
    }if(hour>=10 && min>=10){
        timeLabel2.text = [NSString stringWithFormat:@"%d%@%d",hour,@":",min];
    }
    
    CGFloat length3 = [self getWidthWithString:timeLabel2.text font:[UIFont fontWithName:@"PingFang SC" size: 14]];
    timeLabel2.frame = CGRectMake(contentView2.frame.size.width-length3-30,20,45,20);
}

-(void)HourMinutePickerActionEndTime:(NSMutableArray *) selectArray{
    
}

/**
 *  字符串转NSDate
 *  @prama dateFormatterString @"2015-06-15 16:01:03"
 *  @return NSDate对象
 */
-(NSDate *)dateWtihString:(NSString *)dateFormatterString {
    NSDateFormatter *dateFormatter = [EcTools cachedFm];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateFormatterString];
    return date;
}

-(double)getWidthWithString:(NSString*)str font:(UIFont*)font{
    NSDictionary *dict = @{NSFontAttributeName:font};
    CGSize detailSize = [str sizeWithAttributes:dict];
    return detailSize.width;
}

@end
