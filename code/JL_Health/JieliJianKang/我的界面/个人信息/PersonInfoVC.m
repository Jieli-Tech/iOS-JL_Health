//
//  PersonInfoVC.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/1.
//

#import "PersonInfoVC.h"
#import "JL_RunSDK.h"
#import "PersonInfoCell.h"
#import "PhotoView.h"
#import "MyImageStore.h"
#import "RenameVC.h"
#import "GenderView.h"
#import "BirthDayInfoView.h"
#import "HeightView.h"
#import "WeightView.h"
#import "User_Http.h"
#import "JLUser.h"
#import "JLSqliteAICloundMessageRecord.h"

@interface PersonInfoVC ()<UITableViewDelegate,UITableViewDataSource,PhotoDelegate
,UINavigationControllerDelegate, UIImagePickerControllerDelegate,ReNameViewDelegate,GenderDelegate,BirthDayInfoDelegate,HeightDelegate,WeightDelegate>{
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    
    UITableView *mTableView;
    NSArray *nameArray;
    NSArray *funArray;
    UIButton *exitBtn;
    
    NSString *mName;         //昵称
    NSString *mGender;       //性别
    int      gender;         //性别索引
    NSString *mBirthday;     //出生年月日
    NSString *mBirYear;      //出生年
    NSString *mBirMonth;     //出生月
    NSString *mBirDay;       //出生日
    NSString *mHeight;       //身高
    NSString *mWeight;       //体重
    NSString *mTargetWeight; //目标体重
    NSString *mStartWeight;  //起始体重
    
    PersonInfoCell *cell;
    
    PhotoView *mPhotoView;
    GenderView *mGenderView;
    BirthDayInfoView *birthDayInfoView;
    HeightView *heightView;
    WeightView *weightView;
    
    NSString *unitStr;
}

@end

@implementation PersonInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    
    float sw = [UIScreen mainScreen].bounds.size.width;
    float sh = [UIScreen mainScreen].bounds.size.height;
    
    unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("个人信息");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    //nameArray = @[kJL_TXT("头像"),kJL_TXT("昵称"),kJL_TXT("性别"),kJL_TXT("出生年月"),kJL_TXT("身高"),kJL_TXT("体重")];
    nameArray = @[kJL_TXT("昵称"),kJL_TXT("性别"),kJL_TXT("出生年月日"),kJL_TXT("身高"),kJL_TXT("体重")];
    
    self->mName = kJL_TXT("请填写");
    self->mGender = kJL_TXT("男");
    self->mBirthday = kJL_TXT("请选择");
    self->mHeight = kJL_TXT("请填写");
    self->mWeight = kJL_TXT("请填写");
    self->funArray = @[self->mName,self->mGender,self->mBirthday,self->mHeight,self->mWeight];
    
    [[User_Http shareInstance] requestGetUserConfigInfo:^(JLUser * _Nonnull userInfo) {
        [JL_Tools mainTask:^{
            if(userInfo == nil){
                self->mName = kJL_TXT("请填写");
                self->mGender = kJL_TXT("男");
                self->mBirthday = kJL_TXT("请选择");
                self->mHeight = kJL_TXT("请填写");
                self->mWeight = kJL_TXT("请填写");
            } else {
                self->mName = userInfo.nickname;
                if ([userInfo.nickname isEqualToString:@"请填写"]) self->mName = kJL_TXT("请填写");
                self->gender = userInfo.gender;
                if(self->gender == 1){
                    self->mGender = kJL_TXT("女");
                } else {
                    self->mGender = kJL_TXT("男");
                }
                self->mBirYear = [NSString stringWithFormat:@"%d",userInfo.birthYear];
                self->mBirMonth = [NSString stringWithFormat:@"%d",userInfo.birthMonth];
                self->mBirDay =  [NSString stringWithFormat:@"%d",userInfo.birthDay];
                if([kJL_GET hasPrefix:@"zh"]){
                    self->mBirthday =  [NSString stringWithFormat:@"%@%@%@%@%@%@",self->mBirYear,kJL_TXT("年"),self->mBirMonth,kJL_TXT("月"),self->mBirDay,kJL_TXT("日")];
                }else{
                    self->mBirthday =  [NSString stringWithFormat:@"%@%@%@%@%@",self->mBirYear,@"-",self->mBirMonth,@"-",self->mBirDay];
                }
                if([self->unitStr isEqualToString:@"英制"]){
                    userInfo.height = userInfo.height*0.394;
                }
                self->mHeight  = [NSString stringWithFormat:@"%d",userInfo.height];
                if([self->unitStr isEqualToString:@"英制"]){
                    userInfo.weight = userInfo.weight*2.205;
                }
                self->mWeight  = [NSString stringWithFormat:@"%d",(int)userInfo.weight];
                self->mTargetWeight = [NSString stringWithFormat:@"%.1f",userInfo.weightTarget];
                self->mStartWeight = [NSString stringWithFormat:@"%d",(int)userInfo.weightStart];
                
                if(self->mName.length==0 || self->mBirthday.length == 0||
                   self->mHeight.length == 0||self->mWeight.length == 0
                   || [self->mBirYear isEqualToString:@"0"]
                   || [self->mBirMonth isEqualToString:@"0"]
                   || [self->mBirDay isEqualToString:@"0"]
                   || [self->mHeight isEqualToString:@"0"]
                   || [self->mWeight isEqualToString:@"0"]){
                    self->mGender = kJL_TXT("请选择");
                    self->mBirthday = kJL_TXT("请选择");
                    self->mHeight = kJL_TXT("请选择");
                    self->mWeight = kJL_TXT("请选择");
                }
            }
            
            self->funArray = @[self->mName,self->mGender,self->mBirthday,self->mHeight,self->mWeight];

            self->mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kJL_HeightNavBar+8, sw, 300.0)];
            self->mTableView.rowHeight = 60.0;
            self->mTableView.delegate = self;
            self->mTableView.dataSource =self;
            self->mTableView.scrollEnabled = NO;
            [self->mTableView setSeparatorColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
            [self->mTableView registerNib:[UINib nibWithNibName:@"PersonInfoCell" bundle:nil] forCellReuseIdentifier:@"PersonInfoCell"];
            [self.view addSubview:self->mTableView];

            [self->mTableView reloadData];

            [self getLastWeight];
            
            self->exitBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,self->mTableView.frame.origin.y+self->mTableView.frame.size.height+10,sw,60)];
            [self->exitBtn setTitle:kJL_TXT("退出登录") forState:UIControlStateNormal];
            [self->exitBtn addTarget:self action:@selector(actionExitLogin:) forControlEvents:UIControlEventTouchUpInside];
            [self->exitBtn setTitleColor:kDF_RGBA(36.0, 36.0, 36.0, 1.0) forState:UIControlStateNormal];
            self->exitBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC" size: 15];
            self->exitBtn.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:self->exitBtn];

            self->mPhotoView = [[PhotoView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
            [self.view addSubview:self->mPhotoView];
            self->mPhotoView.delegate = self;
            self->mPhotoView.hidden = YES;

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
        }];
    }];
}

-(void)getLastWeight{
    //获取体重
    [JLSqliteWeight s_checkoutTheLastDataWithResult:^(JL_Chart_Weight * _Nonnull chart) {
        NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
        NSString *units = kJL_TXT("公斤");
        
        float mWeight;
        if([unitStr isEqualToString:@("英制")]){
            units = kJL_TXT("磅");
            mWeight = chart.weight*2.205;
        }else{
            mWeight = chart.weight;
            units = kJL_TXT("公斤");
        }
        self->mWeight = [NSString stringWithFormat:@"%.0f",mWeight];
        self->funArray = @[self->mName,self->mGender,self->mBirthday,self->mHeight,self->mWeight];
        [self->mTableView reloadData];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    cell = [tableView dequeueReusableCellWithIdentifier:@"PersonInfoCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[PersonInfoCell alloc] init];
    }
    
//    if(indexPath.row == 0){
//        cell.imv1.hidden = NO;
//        cell.label2.hidden = YES;
//        UIImage *image = [[MyImageStore sharedStore] imageForKey:@"CYFStore"];
//        if(image!=nil){
//            [cell.imv1 setImage:image];
//        }else{
//            if(gender == 0){
//                [cell.imv1 setImage:[UIImage imageNamed:@"img_profile_01_nol"]];
//            }
//            if(gender == 1){
//                [cell.imv1 setImage:[UIImage imageNamed:@"img_profile_02_nol"]];
//            }
//        }
//        cell.imv1.contentMode = UIViewContentModeScaleAspectFill;
//        [cell.imv1.layer setCornerRadius:CGRectGetHeight([cell.imv1 bounds]) / 2];
//        cell.imv1.layer.masksToBounds = true;
//        //可以根据需求设置边框宽度、颜色
//        cell.imv1.layer.borderWidth = 0;
//        cell.imv1.layer.borderColor = [[UIColor blackColor] CGColor];
//    }else{
        cell.imv1.hidden = YES;
        cell.label2.hidden = NO;
    //}
    cell.label1.text = nameArray[indexPath.row];
    cell.label1.textAlignment = NSTextAlignmentLeft;
    cell.label1.textColor = kDF_RGBA(36.0, 36.0, 36.0, 1.0);
    cell.label1.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    
    //if(indexPath.row>0){
        if(indexPath.row == 3){
            if(mHeight.length>0 && ![mHeight isEqual:kJL_TXT("请填写")]){
                NSString *units = kJL_TXT("厘米");
                if([unitStr isEqualToString:@"英制"]){
                    units = kJL_TXT("英寸");
                }
                NSString *heightStr;
                if([funArray[indexPath.row] isEqual:kJL_TXT("请选择")]){
                    heightStr = [NSString stringWithFormat:@"%@",funArray[indexPath.row]];
                }else{
                    heightStr = [NSString stringWithFormat:@"%@%@",funArray[indexPath.row],units];
                }
                cell.label2.text = heightStr;
            }else{
                cell.label2.text = funArray[indexPath.row];
            }
        }else if(indexPath.row == 4){
            if(mWeight.length>0 && ![mWeight isEqual:kJL_TXT("请填写")]){
                NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
                NSString *weightStr;
                NSString *units = kJL_TXT("公斤");
                if([unitStr isEqualToString:@("英制")]){
                    units = kJL_TXT("磅");
                    weightStr = [NSString stringWithFormat:@"%@%@",funArray[indexPath.row],units];
                }else{
                    weightStr = [NSString stringWithFormat:@"%@%@",funArray[indexPath.row],units];
                }
                cell.label2.text = weightStr;
            }else{
                cell.label2.text = funArray[indexPath.row];
            }
        }
        else{
            cell.label2.text = funArray[indexPath.row];
        }
        cell.label2.textColor = kDF_RGBA(145.0, 145.0, 145.0, 1.0);
        cell.label2.font = [UIFont fontWithName:@"PingFangSC" size: 13];
    //}
    
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    cell.layoutMargins = UIEdgeInsetsMake(0, 16, 0, 16);
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
//        case 0:
//        {
//            mPhotoView.hidden = NO;
//        }
//            break;
        case 0:
        {
            RenameVC *vc = [[RenameVC alloc] init];
            vc.type = 0;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            vc.delegate = self;
            if(mName.length>0 && (!([mName isEqual:@"请填写"]))){
                vc.txfdStr = mName;
            }
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
        case 1:
        {
            mGenderView.hidden = NO;
            mGenderView.selectValue = gender;
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
        default:
            break;
    }
}

- (IBAction)actionExit:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)actionExitLogin:(UIButton *)btn{

    NSString *uuid = [JL_Tools getUserByKey:@"Entity"];
    JL_EntityM   *__nullable mBleEntityM = [JL_RunSDK getEntity:uuid];
    [kJL_BLE_Multiple disconnectEntity:mBleEntityM Result:^(JL_EntityM_Status status) {
    }];
    [self.navigationController popViewControllerAnimated:YES];
    
    
    [JL_Tools removeUserByKey:kUI_ACCESS_TOKEN];
    [JL_Tools removeUserByKey:kUI_HTTP_USER_WAY];
    
    [UserProfile removeProfile];
    [self deleteDBFile];

    [JL_Tools post:kUI_LOGOUT Object:nil];
}

-(void)deleteDBFile{
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    UserProfile *userPfInfo = [UserProfile locateProfile];
    if(userPfInfo){
        NSString *identify = userPfInfo.identify;
        
        NSString *deleteHealthPath = [NSString stringWithFormat:@"%@%@%@%@",pathDocuments,@"/",identify,@".db"];
        NSString *deleteUserDevicesPath = [NSString stringWithFormat:@"%@%@%@",pathDocuments,@"/",@"UserDevices.sqlite"];

        [fileManager removeItemAtPath:deleteHealthPath error:nil];
        [fileManager removeItemAtPath:deleteUserDevicesPath error:nil];
    }

}

#pragma mark 头像拍照
-(void)takePhoto{
    mPhotoView.hidden = YES;
    
    //创建UIImagePickerController实例
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    [JLApplicationDelegate.navigationController pushViewController:imagePickerController animated:YES];
}

#pragma mark 头像从相册选取
-(void)takePicture{
    mPhotoView.hidden = YES;
    
    //创建UIImagePickerController实例
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - - - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
//    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    [[MyImageStore sharedStore] setImage:image forKey:@"CYFStore"];
    [mTableView reloadData];
}

-(void)didSelectBtnAction:(UIButton *)btn WithText:(NSString *)text{
    mName = text;
    [[User_Http shareInstance] requestUserConfigInfo:mName Gender:[NSString stringWithFormat:@"%d",gender] BirthdayYear:mBirYear BirthdayMonth:mBirMonth BirthdayDay:mBirDay Height:mHeight Weigtht:mWeight Step:@"" AvatarUrl:@"" WeightStart:self->mStartWeight WeightTarget:self->mTargetWeight Result:^(NSDictionary * _Nonnull info) {
    }];
    funArray = @[mName,mGender,mBirthday,mHeight,mWeight];
    [mTableView reloadData];
}

-(void)didSelectGender:(int )index{
    gender = index;
    if(index == 0){
        mGender = kJL_TXT("男");
    }
    if(index == 1){
        mGender = kJL_TXT("女");
    }
    [[User_Http shareInstance] requestUserConfigInfo:mName Gender:[NSString stringWithFormat:@"%d",gender] BirthdayYear:mBirYear BirthdayMonth:mBirMonth BirthdayDay:mBirDay Height:mHeight Weigtht:mWeight Step:@"" AvatarUrl:@"" WeightStart:self->mStartWeight WeightTarget:self->mTargetWeight Result:^(NSDictionary * _Nonnull info) {
    }];
    funArray = @[mName,mGender,mBirthday,mHeight,mWeight];
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
        [[User_Http shareInstance] requestUserConfigInfo:mName Gender:[NSString stringWithFormat:@"%d",gender] BirthdayYear:mBirYear BirthdayMonth:mBirMonth BirthdayDay:mBirDay Height:mHeight Weigtht:mWeight Step:@"" AvatarUrl:@"" WeightStart:self->mStartWeight WeightTarget:self->mTargetWeight Result:^(NSDictionary * _Nonnull info) {
        }];
    }
    
    funArray = @[mName,mGender,mBirthday,mHeight,mWeight];
    [mTableView reloadData];
}

-(void)heightAction:(NSString *) selectValue{
    mHeight = selectValue;
    
    if(mHeight.length == 0){
        mHeight = kJL_TXT("请输入");
    }
    
    if(mHeight.length>0){
        [[User_Http shareInstance] requestUserConfigInfo:mName Gender:[NSString stringWithFormat:@"%d",gender] BirthdayYear:mBirYear BirthdayMonth:mBirMonth BirthdayDay:mBirDay Height:mHeight Weigtht:mWeight Step:@"" AvatarUrl:@"" WeightStart:self->mStartWeight WeightTarget:self->mTargetWeight Result:^(NSDictionary * _Nonnull info) {
        }];
    }
    
    funArray = @[mName,mGender,mBirthday,mHeight,mWeight];
    [mTableView reloadData];
}

-(void)weightAction:(NSString *) selectValue{
    mWeight = selectValue;
    
    unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];

    if(mWeight.length == 0){
        mWeight = kJL_TXT("请输入");
    }
    
    JL_Chart_Weight *model = [[JL_Chart_Weight alloc] init];
    float mTempWeight;
    NSString *myStartWeight;
    if([self->unitStr isEqualToString:@"英制"]){
        mTempWeight = [mWeight floatValue]/2.205;
        myStartWeight =[NSString stringWithFormat:@"%.1f",mTempWeight];
    }else{
        mTempWeight = [mWeight floatValue];
        myStartWeight = mWeight;
    }
    model.weight = mTempWeight;

    model.date = [NSDate new];
    [JLSqliteWeight s_update:model];
    [UserDataSync uploadHealthWeightData];
    if(mHeight.length>0){
        [[User_Http shareInstance] requestUserConfigInfo:mName Gender:[NSString stringWithFormat:@"%d",gender] BirthdayYear:mBirYear BirthdayMonth:mBirMonth BirthdayDay:mBirDay Height:mHeight Weigtht:mWeight Step:@"" AvatarUrl:@"" WeightStart:myStartWeight WeightTarget:self->mTargetWeight Result:^(NSDictionary * _Nonnull info) {
        }];
    }
    
    funArray = @[mName,mGender,mBirthday,mHeight,mWeight];
    [mTableView reloadData];
}

@end
