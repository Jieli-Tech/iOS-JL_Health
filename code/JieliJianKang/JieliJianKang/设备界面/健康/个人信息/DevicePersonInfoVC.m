//
//  PersonInfoVC.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/1.
//

#import "DevicePersonInfoVC.h"
#import "JL_RunSDK.h"
#import "PersonInfoCell.h"
#import "GenderView.h"
#import "BirthDayInfoView.h"
#import "HeightView.h"
#import "WeightView.h"

@interface DevicePersonInfoVC ()<UITableViewDelegate,UITableViewDataSource,
UINavigationControllerDelegate,GenderDelegate,BirthDayInfoDelegate,HeightDelegate,WeightDelegate,JL_WatchProtocol>{
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    
    UITableView *mTableView;
    NSArray *nameArray;
    NSArray *funArray;
    
    NSString *mGender;       //性别
    NSString *mBirthday;     //出生年月日
    NSString *mBirYear;      //出生年
    NSString *mBirMonth;     //出生月
    NSString *mBirDay;       //出生日
    NSString *mHeight;       //身高
    NSString *mWeight;       //体重
    
    NSDate *birthDay;
    uint16_t height;
    uint16_t weight;
    uint8_t myGender;
    
    PersonInfoCell *cell;
    
    GenderView *mGenderView;
    BirthDayInfoView *birthDayInfoView;
    HeightView *heightView;
    WeightView *weightView;
    
    NSString *unitStr;
}

@end

@implementation DevicePersonInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self addNote];
    [self requireDataFromDevice];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    float sw = [DFUITools screen_2_W];
    float sh = [DFUITools screen_2_H];
    
    unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("个人信息");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    nameArray = @[kJL_TXT("性别"),kJL_TXT("出生年月日"),kJL_TXT("身高"),kJL_TXT("体重")];
    
    self->mGender   = kJL_TXT("请填写");
    self->mBirthday = kJL_TXT("请填写");
    self->mHeight   = kJL_TXT("请填写");
    self->mWeight   = kJL_TXT("请填写");
    self->funArray  = @[self->mGender,self->mBirthday,self->mHeight,self->mWeight];
    
    self->mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kJL_HeightNavBar+8, sw, 240.0)];
    self->mTableView.rowHeight = 60.0;
    self->mTableView.delegate = self;
    self->mTableView.dataSource =self;
    self->mTableView.scrollEnabled = NO;
    [self->mTableView setSeparatorColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
    [self->mTableView registerNib:[UINib nibWithNibName:@"PersonInfoCell" bundle:nil] forCellReuseIdentifier:@"PersonInfoCell"];
    [self.view addSubview:self->mTableView];
    [self->mTableView reloadData];

    self->mGenderView = [[GenderView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self.view addSubview:self->mGenderView];
    self->mGenderView.delegate = self;
    self->mGenderView.hidden = YES;

    self->birthDayInfoView = [[BirthDayInfoView alloc]initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self.view addSubview:self->birthDayInfoView];
    self->birthDayInfoView.delegate = self;
    self->birthDayInfoView.labelTitleName.text = kJL_TXT("出生年月日");
    self->birthDayInfoView.hidden = YES;

    self->heightView = [[HeightView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self.view addSubview:self->heightView];
    self->heightView.delegate = self;
    self->heightView.hidden = YES;

    self->weightView = [[WeightView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self.view addSubview:self->weightView];
    self->weightView.delegate = self;
    self->weightView.hidden = YES;
}

-(void)requireDataFromDevice{
    JLWearable *w = [JLWearable sharedInstance];
    [w w_addDelegate:self];
    
    [w w_InquireDeviceFuncWith:JL_WATCH_SETTING_PERSONAL_INFO withEntity:kJL_BLE_EntityM];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    cell = [tableView dequeueReusableCellWithIdentifier:@"PersonInfoCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[PersonInfoCell alloc] init];
    }
    
    cell.imv1.hidden = YES;
    cell.label2.hidden = NO;
    cell.label1.text = nameArray[indexPath.row];
    cell.label1.textColor = kDF_RGBA(36.0, 36.0, 36.0, 1.0);
    cell.label1.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    
    if(indexPath.row ==0){
        if(mGender.length>0 && (![mHeight isEqual:kJL_TXT("请填写")])){
            cell.label2.text = funArray[indexPath.row];
        }else{
            cell.label2.text = funArray[indexPath.row];
        }
    }
    if(indexPath.row ==1){
        if(mBirthday.length>0 && (![mBirthday isEqual:kJL_TXT("请填写")])){
            cell.label2.text = funArray[indexPath.row];
        }else{
            cell.label2.text = funArray[indexPath.row];
        }
    }
    if(indexPath.row ==2){
        if(mHeight.length>0 && (![mHeight isEqual:kJL_TXT("请填写")])){
            NSString *units = kJL_TXT("厘米");
            if([unitStr isEqualToString:@"英制"]){
                units = kJL_TXT("英寸");
            }
            NSString *heightStr = [NSString stringWithFormat:@"%@%@",funArray[indexPath.row],units];
            cell.label2.text = heightStr;
        }else{
            cell.label2.text = funArray[indexPath.row];
        }
    }
    if(indexPath.row == 3){
        if(mWeight.length>0 && (![mWeight isEqual:kJL_TXT("请填写")])){
            NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
            NSString *units = kJL_TXT("公斤");
            if([unitStr isEqualToString:@"英制"]){
                units = kJL_TXT("磅");
            }
            NSString *weightStr = [NSString stringWithFormat:@"%@%@",funArray[indexPath.row],units];
            cell.label2.text = weightStr;
        }else{
            cell.label2.text = funArray[indexPath.row];
        }
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
            mGenderView.hidden = NO;
            mGenderView.selectValue = myGender;
        }
            break;
        case 1:
        {
            birthDayInfoView.hidden = NO;
            if(mBirthday.length>0 && (!([mBirthday isEqual:kJL_TXT("请填写")]))){
                birthDayInfoView.selectValue = mBirthday;
            }
        }
            break;
        case 2:
        {
            heightView.hidden = NO;
            heightView.selectMValue = mHeight;
        }
            break;
        case 3:
        {
            weightView.hidden = NO;
            weightView.selectMValue = mWeight;
        }
            break;
        default:
            break;
    }
}

- (IBAction)actionExit:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)didSelectGender:(int )index{
    myGender = index;
    if(index == 0){
        mGender = kJL_TXT("男");
    }
    if(index == 1){
        mGender = kJL_TXT("女");
    }
    
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    JLPersonInfoModel *model1 = [[JLPersonInfoModel alloc] initWith:birthDay height:height weight:weight gener:myGender];
    [models addObject:model1];
    
    JLWearable *w = [JLWearable sharedInstance];
    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
    funArray = @[mGender,mBirthday,mHeight,mWeight];
    [mTableView reloadData];
}

-(void)birthdayAction:(NSString *)birthYear Month:(NSString *)birthMonth Day:(NSString *)day SelectDate:(NSString *)date{
    mBirthday = date;
    mBirYear = birthYear;
    mBirMonth = birthMonth;
    mBirDay = day;
    
    if(mBirthday.length == 0){
        mBirthday = kJL_TXT("请填写");
    }
                   
    NSString *str = [NSString stringWithFormat:@"%@-%@-%@",mBirYear,mBirMonth,mBirDay];
    NSDateFormatter *formatter = [EcTools cachedFm];
    formatter.dateFormat = @"YYYY-MM-dd";
    birthDay = [formatter dateFromString:str];
    
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    JLPersonInfoModel *model1 = [[JLPersonInfoModel alloc] initWith:birthDay height:height weight:weight gener:myGender];
    [models addObject:model1];

    JLWearable *w = [JLWearable sharedInstance];
    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];

    funArray = @[mGender,mBirthday,mHeight,mWeight];
    [mTableView reloadData];
}

-(void)heightAction:(NSString *) selectValue{
    mHeight = selectValue;
    
    if(mHeight.length == 0){
        mHeight = kJL_TXT("请填写");
    }
    
    height = [mHeight intValue];
    
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    JLPersonInfoModel *model1 = [[JLPersonInfoModel alloc] initWith:birthDay height:height weight:weight gener:myGender];
    [models addObject:model1];
    
    JLWearable *w = [JLWearable sharedInstance];
    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
    
    mHeight = [NSString stringWithFormat:@"%d",height];
    
    funArray = @[mGender,mBirthday,mHeight,mWeight];
    [mTableView reloadData];
}

-(void)weightAction:(NSString *) selectValue{
    mWeight = selectValue;
    
    if(mWeight.length == 0){
        mWeight = kJL_TXT("请填写");
    }
    
    weight = [mWeight intValue];
    
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    JLPersonInfoModel *model1 = [[JLPersonInfoModel alloc] initWith:birthDay height:height weight:weight gener:myGender];
    [models addObject:model1];
    
    JLWearable *w = [JLWearable sharedInstance];
    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
    
    mWeight = [NSString stringWithFormat:@"%d",weight];
    
    funArray = @[mGender,mBirthday,mHeight,mWeight];
    [mTableView reloadData];
}

#pragma mark 个人信息
-(void)jlWatchSetPersonInfoModel:(JLPersonInfoModel *)model{
    birthDay = model.birthDay;
    myGender = model.gender;
    height = model.height;
    weight = model.weight;
    
    if(model.gender == 0){
        mGender = kJL_TXT("男");
    }
    if(model.gender == 1){
        mGender = kJL_TXT("女");
    }
    
    mHeight = [NSString stringWithFormat:@"%d",model.height];
    mWeight = [NSString stringWithFormat:@"%d",model.weight];
        
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc]init];
    dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateStr1 = [dateFmt stringFromDate:model.birthDay];
    if(dateStr1.length == 0){
        mBirthday = kJL_TXT("请填写");
    }else{
        NSString *year = [dateStr1 substringWithRange:NSMakeRange(0, 4)];
        NSString *month = [dateStr1 substringWithRange:NSMakeRange(5, 2)];
        NSString *day = [dateStr1 substringWithRange:NSMakeRange(8, 2)];
        
        if([kJL_GET hasPrefix:@"zh"]){
            mBirthday = [NSString stringWithFormat:@"%@%@%@%@%@%@", year,kJL_TXT("年"),month,kJL_TXT("月"),day,kJL_TXT("日")];
        }else{
            mBirthday = [NSString stringWithFormat:@"%@%@%@%@%@", year,@"-",month,@"-",day];
        }
    }

   funArray = @[mGender,mBirthday,mHeight,mWeight];
   [mTableView reloadData];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline || tp == JLDeviceChangeTypeBleOFF) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)removeNote{
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

-(void)dealloc{
    [self removeNote];
}

@end
