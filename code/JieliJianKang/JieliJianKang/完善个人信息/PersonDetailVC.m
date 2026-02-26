//
//  PersonDetailVC.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/3.
//

#import "PersonDetailVC.h"
#import "JL_RunSDK.h"
#import "PersonInfoCell.h"
#import "RenameVC.h"
#import "GenderView.h"
#import "BirthDayInfoView.h"
#import "HeightView.h"
#import "WeightView.h"
#import "StepView.h"
#import "User_Http.h"
#import "JLUser.h"

@interface PersonDetailVC ()<UITableViewDelegate,UITableViewDataSource,ReNameViewDelegate,GenderDelegate,BirthDayInfoDelegate,HeightDelegate,WeightDelegate,StepDelegate,UIScrollViewDelegate>{
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UIButton *tiaoguoBtn;
    
    UIImageView *topImv;
    UITableView *mTableView;
    
    UIButton    *nextBtn;    //下一步按钮
    
    NSArray *nameArray;
    NSArray *funArray;
    
    NSString *mName;         //昵称
    NSString *mGender;       //性别
    int      gender;         //性别索引
    NSString *mBirthday;     //出生年月日
    NSString *mBirYear;      //出生年
    NSString *mBirMonth;     //出生月
    NSString *mBirDay;       //出生日
    NSString *mHeight;       //身高
    NSString *mWeight;       //体重
    NSString *mStep;         //步数
    NSString *mTargetWeight; //目标体重
    NSString *mStartWeight;  //起始体重
    
    GenderView *genderView; //选择性别
    BirthDayInfoView *birthDayInfoView; //出生年月View
    HeightView *heightView;             //身高View;
    WeightView *weightView;             //体重View;
    StepView   *stepView;               //步数View;
    UIScrollView *mScroll;
    
    NSString *unitStr;
}

@end

@implementation PersonDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    float sW = [UIScreen mainScreen].bounds.size.width;
    float sH = [UIScreen mainScreen].bounds.size.height;
    titleHeight.constant = kJL_HeightNavBar;
    unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    
    subTitleView.frame = CGRectMake(0, 0, sW, kJL_HeightStatusBar+44);
    titleName.text = kJL_TXT("完善个人信息");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sW/2.0, kJL_HeightStatusBar+20);
    
    [tiaoguoBtn setTitle:kJL_TXT("跳过") forState:UIControlStateNormal];
    [tiaoguoBtn setTitleColor:kDF_RGBA(85, 140, 255, 1.0) forState:UIControlStateNormal];
    [tiaoguoBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:14]];
    tiaoguoBtn.bounds = CGRectMake(0, 0, 38, 20);
    tiaoguoBtn.center = CGPointMake(sW-28-16, kJL_HeightStatusBar+20);
    
    CGRect rect = CGRectMake(88,titleName.frame.origin.y+titleName.frame.size.height+60,sW-88*2,160);
    topImv = [[UIImageView alloc] initWithFrame:rect];
    topImv.contentMode = UIViewContentModeScaleToFill;
    UIImage *image = [UIImage imageNamed:@"img_nol"];
    topImv.image = image;
    [self.view addSubview:topImv];
    
    self->mGender = kJL_TXT("男");
    
    nameArray = @[kJL_TXT("昵称"),kJL_TXT("性别"),kJL_TXT("出生年月日"),kJL_TXT("身高"),kJL_TXT("体重"),kJL_TXT("运动目标")];
    [[User_Http shareInstance] requestGetUserConfigInfo:^(JLUser * _Nonnull userInfo) {
        [JL_Tools mainTask:^{
            if(userInfo == nil){
                self->mName = kJL_TXT("请填写");
                self->mGender = kJL_TXT("男");
                self->mBirthday = kJL_TXT("请选择");
                self->mHeight = kJL_TXT("请填写");
                self->mWeight = kJL_TXT("请填写");
                self->mStep = kJL_TXT("请填写");
            } else {
                self->mName = userInfo.nickname;
                self->gender = userInfo.gender;
                if(self->gender == 1){
                    self->mGender = kJL_TXT("女");
                } else {
                    self->mGender = kJL_TXT("男");
                }
                self->mBirYear = [NSString stringWithFormat:@"%d",userInfo.birthYear];
                self->mBirMonth = [NSString stringWithFormat:@"%d",userInfo.birthMonth];
                self->mBirDay = [NSString stringWithFormat:@"%d",userInfo.birthDay];
                if([kJL_GET hasPrefix:@"zh"]){
                    self->mBirthday =  [NSString stringWithFormat:@"%@%@%@%@%@%@", self->mBirYear, kJL_TXT("年"), self->mBirMonth, kJL_TXT("月"), self->mBirDay, kJL_TXT("日")];
                }else{
                    self->mBirthday =  [NSString stringWithFormat:@"%@%@%@%@%@", self->mBirYear, @"-", self->mBirMonth, @"-", self->mBirDay];
                }
                if([self->unitStr isEqualToString:@"英制"]){
                    userInfo.height = userInfo.height*0.394;
                }
                self->mHeight  = [NSString stringWithFormat:@"%d",userInfo.height];
                self->mStep  = [NSString stringWithFormat:@"%d",userInfo.step];
                if([self->unitStr isEqualToString:@"英制"]){
                    userInfo.weight = userInfo.weight*2.205;
                }
                self->mWeight  = [NSString stringWithFormat:@"%d",(int)userInfo.weight];
                self->mTargetWeight = [NSString stringWithFormat:@"%.1f",userInfo.weightTarget];
                self->mStartWeight = [NSString stringWithFormat:@"%d",(int)userInfo.weightStart];
                
                if(self->mName.length==0 || self->mBirthday.length == 0||
                   self->mHeight.length == 0||self->mWeight.length == 0||self->mStep.length == 0){
                    self->mName = kJL_TXT("请填写");
                    self->mGender = kJL_TXT("请选择");
                    self->mBirthday = kJL_TXT("请选择");
                    self->mHeight = kJL_TXT("请填写");
                    self->mWeight = kJL_TXT("请填写");
                    self->mStep = kJL_TXT("请填写");
                }
            }
            
            if(self->mStep.length>0){
                [self->nextBtn setBackgroundColor:kDF_RGBA(128, 91, 235, 1.0)];
                [self->nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            
            self->funArray = @[self->mName,self->mGender,self->mBirthday,self->mHeight,self->mWeight,self->mStep];
            
            if (!self->mScroll) {
                self->mScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self->topImv.frame.origin.y+self->topImv.frame.size.height+44, sW, sH-kJL_HeightStatusBar-220-44)];
                self->mScroll.delegate = self;
                self->mScroll.backgroundColor = [UIColor clearColor];
                [self.view addSubview:self->mScroll];
            }
            
            self->mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, sW, 348.0)];
            self->mTableView.rowHeight = 58.0;
            self->mTableView.delegate = self;
            self->mTableView.dataSource =self;
            self->mTableView.scrollEnabled = NO;
            [self->mTableView setSeparatorColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
            [self->mTableView registerNib:[UINib nibWithNibName:@"PersonInfoCell" bundle:nil] forCellReuseIdentifier:@"PersonInfoCell"];
            [self->mScroll addSubview:self->mTableView];
            [self->mTableView reloadData];
            
            self->nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(24,self->mTableView.frame.origin.y+self->mTableView.frame.size.height+51,sW-48,48)];
            [self->nextBtn addTarget:self action:@selector(enterFunClick:) forControlEvents:UIControlEventTouchUpInside];
            [self->nextBtn setTitle:kJL_TXT("下一步") forState:UIControlStateNormal];
            [self->nextBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:15]];
            [self->nextBtn setTitleColor:kDF_RGBA(179, 179, 179, 1.0) forState:UIControlStateNormal];
            [self->nextBtn setBackgroundColor:kDF_RGBA(240, 241, 241, 1.0)];
            self->nextBtn.layer.cornerRadius = 24;
            [self->mScroll addSubview:self->nextBtn];
            
            self->genderView = [[GenderView alloc] initWithFrame:CGRectMake(0, 0, sW, sH)];
            [self.view addSubview:self->genderView];
            self->genderView.delegate = self;
            self-> genderView.hidden = YES;
            
            self->birthDayInfoView = [[BirthDayInfoView alloc] initWithFrame:CGRectMake(0, 0, sW, sH)];
            [self.view addSubview:self->birthDayInfoView];
            self->birthDayInfoView.delegate = self;
            self->birthDayInfoView.labelTitleName.text = kJL_TXT("出生年月日");
            self->birthDayInfoView.hidden = YES;
            
            self->heightView = [[HeightView alloc] initWithFrame:CGRectMake(0, 0, sW, sH)];
            [self.view addSubview:self->heightView];
            self->heightView.delegate = self;
            self->heightView.hidden = YES;
            
            self->weightView = [[WeightView alloc] initWithFrame:CGRectMake(0, 0, sW, sH)];
            [self.view addSubview:self->weightView];
            self->weightView.delegate = self;
            self->weightView.hidden = YES;
            
            self->stepView = [[StepView alloc] initWithFrame:CGRectMake(0, 0, sW, sH)];
            [self.view addSubview:self->stepView];
            self->stepView.delegate = self;
            self->stepView.hidden = YES;
            
            self->mScroll.contentSize = CGSizeMake(0,self->mTableView.frame.size.height+self->nextBtn.frame.size.height+100);
        }];
    }];
}

- (IBAction)tiaoguoAction:(UIButton *)sender {
        [JL_Tools mainTask:^{
            [self dismissViewControllerAnimated:YES completion:nil];
            [JL_Tools post:kUI_ENTER_MAIN_VC Object:nil];
        }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PersonInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonInfoCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[PersonInfoCell alloc] init];
    }
    
    cell.imv1.hidden = YES;
    cell.label2.hidden = NO;
    cell.label1.text = nameArray[indexPath.row];
    cell.label1.textColor = kDF_RGBA(36.0, 36.0, 36.0, 1.0);
    cell.label1.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    
    if(indexPath.row == 3){
        if(mHeight.length>0 && ![mHeight isEqual:kJL_TXT("请填写")]){
            NSString *units = kJL_TXT("厘米");
            if([unitStr isEqualToString:@"英制"]){
                units = kJL_TXT("英寸");
            }
            NSString *heightStr = [NSString stringWithFormat:@"%@%@",funArray[indexPath.row],units];
            cell.label2.text = heightStr;
        }else{
            cell.label2.text = funArray[indexPath.row];
        }
    }else if(indexPath.row == 4){
        if(mWeight.length>0 && ![mWeight isEqual:kJL_TXT("请填写")]){
            NSString *units = kJL_TXT("公斤");
            if([unitStr isEqualToString:@("英制")]){
                units = kJL_TXT("磅");
            }else{
                units = kJL_TXT("公斤");
            }
            NSString *weightStr = [NSString stringWithFormat:@"%@%@",funArray[indexPath.row],units];
            cell.label2.text = weightStr;
        }else{
            cell.label2.text = funArray[indexPath.row];
        }
    }else if(indexPath.row == 5){
        if(mStep.length>0 && ![mStep isEqual:kJL_TXT("请填写")]){
            NSString *weightStr = [NSString stringWithFormat:@"%@%@",funArray[indexPath.row],kJL_TXT("步")];
            cell.label2.text = weightStr;
        }else{
            cell.label2.text = funArray[indexPath.row];
        }
    }else{
        cell.label2.text = funArray[indexPath.row];
    }
    
    cell.label2.textColor = kDF_RGBA(145.0, 145.0, 145.0, 1.0);
    cell.label2.font = [UIFont fontWithName:@"PingFangSC" size: 13];
    
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    cell.layoutMargins = UIEdgeInsetsMake(0, 16, 0, 16);
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            RenameVC *renameVC = [[RenameVC alloc] init];
            renameVC.type = 0;
            renameVC.modalPresentationStyle = UIModalPresentationFullScreen;
            if(mName.length>0 && (!([mName isEqual:@"请填写"]))){
                renameVC.txfdStr = mName;
            }
            renameVC.delegate = self;
            [self presentViewController:renameVC animated:YES completion:nil];
        }
            break;
        case 1:
        {
            genderView.hidden = NO;
            genderView.selectValue = gender;
        }
            break;
        case 2:
        {
            birthDayInfoView.hidden = NO;
            if(mBirthday.length>0 && (!([mBirthday isEqual:kJL_TXT("请选择")]))){
                birthDayInfoView.selectValue = mBirthday;
            }
        }
            break;
        case 3:
        {
            heightView.hidden = NO;
            heightView.selectMValue = mHeight;
        }
            break;
        case 4:
        {
            weightView.hidden = NO;
//            if(([mWeight intValue]!=[mStartWeight intValue]) && ([mStartWeight intValue]>0)){
//                weightView.selectMValue = mStartWeight;
//            }else{
                weightView.selectMValue = mWeight;
            //}
        }
            break;
        case 5:
        {
            stepView.hidden = NO;
            stepView.selectMValue = mStep;
        }
            break;
        default:
            break;
    }
}

#pragma mark 进入功能界面
-(void)enterFunClick:(UIButton *)btn{
    [[User_Http shareInstance] requestUserConfigInfo:mName Gender:[NSString stringWithFormat:@"%d",gender] BirthdayYear:mBirYear BirthdayMonth:mBirMonth BirthdayDay:mBirDay Height:mHeight Weigtht:mWeight Step:mStep AvatarUrl:@"" WeightStart:self->mStartWeight WeightTarget:self->mTargetWeight  Result:^(NSDictionary * _Nonnull info) {
        [JL_Tools mainTask:^{
            [self dismissViewControllerAnimated:YES completion:nil];
            [JL_Tools post:kUI_ENTER_MAIN_VC Object:nil];
        }];
    }];
}

-(void)didSelectBtnAction:(UIButton *)btn WithText:(NSString *)text{
    mName = text;
    if(mName.length>0){
        funArray = @[mName,mGender,mBirthday,mHeight,mWeight,mStep];
        [mTableView reloadData];
    }
}

-(void)didSelectGender:(int )index{
    gender = index;
    if(index == 0){
        mGender = kJL_TXT("男");
    }
    if(index == 1){
        mGender = kJL_TXT("女");
    }
    funArray = @[mName,mGender,mBirthday,mHeight,mWeight,mStep];
    [mTableView reloadData];
}

-(void)birthdayAction:(NSString *)birthYear Month:(NSString *)birthMonth Day:(NSString *)day SelectDate:(NSString *)date{
    mBirthday = date;
    mBirYear = birthYear;
    mBirMonth = birthMonth;
    mBirDay = day;
    
    if(mBirthday.length == 0){
        mBirthday = kJL_TXT("请选择");
    }
    
    if(mBirthday.length>0){
        funArray = @[mName,mGender,mBirthday,mHeight,mWeight,mStep];
        [mTableView reloadData];
    }
}

-(void)heightAction:(NSString *) selectValue{
    mHeight = selectValue;
    if(mHeight.length>0){
        funArray = @[mName,mGender,mBirthday,mHeight,mWeight,mStep];
        [mTableView reloadData];
    }
}

-(void)weightAction:(NSString *) selectValue{
    mWeight = selectValue;
    if(mHeight.length>0){
        funArray = @[mName,mGender,mBirthday,mHeight,mWeight,mStep];
        [mTableView reloadData];
    }
}

-(void)stepAction:(NSString *) selectValue{
    mStep = selectValue;
    if(mStep.length>0){
        [nextBtn setBackgroundColor:kDF_RGBA(128, 91, 235, 1.0)];
        [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    if(mStep.length>0){
        funArray = @[mName,mGender,mBirthday,mHeight,mWeight,mStep];
        [mTableView reloadData];
    }
}

@end
