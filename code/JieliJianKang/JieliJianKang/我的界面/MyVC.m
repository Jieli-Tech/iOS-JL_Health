//
//  MyVC.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/1.
//

#import "MyVC.h"
#import "JL_RunSDK.h"
#import "MyCell.h"
#import "BodyDataVC.h"
#import "SettingVC.h"
#import "AboutVC.h"
#import "PersonInfoVC.h"
#import "MyImageStore.h"
#import "User_Http.h"
#import "JLUser.h"
#import "JLSportWeeklyReportsViewController.h"

@interface MyVC ()<UITableViewDelegate,UITableViewDataSource,LanguagePtl>{
    UIView *headView;    //我的图像和个人信息
    UIImageView *myImv;  //我的图像
    UILabel     *myName; //我的名字
    UIButton    *nextBtn;
    UITableView *mTableView; //我的TableView
    
    NSArray *myNames;
    NSArray *myIcons;
    
    UILabel *myLabel;
    float sw;
}

@end

@implementation MyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LanguageCls share] add:self];
    [self initUI];
}

-(void)initUI{
    sw = [DFUITools screen_2_W];
    
    myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(16,kJL_HeightStatusBar+10,sw-16,33);
    myLabel.numberOfLines = 0;
    [self.view addSubview:myLabel];
    myLabel.font =  [UIFont fontWithName:@"Helvetica-Bold" size: 24];
    myLabel.text =  kJL_TXT("我的");
    myLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    headView = [[UIView alloc] initWithFrame:CGRectMake(16, myLabel.frame.origin.y+myLabel.frame.size.height+30, sw-32, 64.0)];
    [self.view addSubview:headView];
    
    UITapGestureRecognizer *headGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(personMessageClick)];
    [headView addGestureRecognizer:headGestureRecognizer];
    headView.userInteractionEnabled=YES;
    
    myImv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64.0, 64.0)];
    myImv.layer.cornerRadius = myImv.frame.size.width/2;
    myImv.layer.masksToBounds = YES;
    myImv.contentMode = UIViewContentModeScaleAspectFill;
    [headView addSubview:myImv];
    
    myName = [[UILabel alloc] init];
    myName.frame = CGRectMake(myImv.frame.origin.x+myImv.frame.size.width+16,headView.frame.size.height/2-25/2,headView.frame.size.width-102,25);
    myName.numberOfLines = 0;
    [headView addSubview:myName];
    myName.font =  [UIFont fontWithName:@"PingFangSC" size: 18];
    myName.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-32-22-5,headView.frame.size.height/2-22/2,22,22)];
    [nextBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [headView addSubview:nextBtn];
    
    myNames = @[kJL_TXT("我的数据"),kJL_TXT("运动周报"),kJL_TXT("设置"),kJL_TXT("关于")];
//    myNames = @[kJL_TXT("我的数据"),kJL_TXT("设置"),kJL_TXT("帮助"),kJL_TXT("关于")];
    myIcons = @[@"mine_icon_data_nol",@"mine_icon_weekly_nol",@"mine_icon_settle_nol",@"mine_icon_help_nol",@"mine_icon_about_nol"];
    
    mTableView = [[UITableView alloc] initWithFrame:CGRectMake(-16, headView.frame.origin.y+headView.frame.size.height+35, sw, 250)];
    mTableView.rowHeight = 50.0;
    mTableView.delegate = self;
    mTableView.dataSource =self;
    mTableView.scrollEnabled = NO;
    mTableView.backgroundColor = [UIColor clearColor];
    mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [mTableView registerClass:[MyCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:mTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [[User_Http shareInstance] requestGetUserConfigInfo:^(JLUser * _Nonnull userInfo) {
        [JL_Tools mainTask:^{
            if (userInfo == nil) {
                self->myName.text = kJL_TXT("未设置昵称");
            } else {
                if(userInfo.nickname.length == 0){
                    self->myName.text = kJL_TXT("未设置昵称");
                }else{
                    if([userInfo.nickname isEqualToString:@"请填写"]){
                        self->myName.text = kJL_TXT("未设置昵称");
                    }else{
                        self->myName.text = userInfo.nickname;
                    }
                }
            }
            
            //int index = userInfo.gender;
//            UIImage *mImage = [[MyImageStore sharedStore] imageForKey:@"CYFStore"];
//            if (mImage!=nil) {
//                self->myImv.image = mImage;
//            } else {
            if(UserHttpInstance.userInfo.gender == 1) {
                [self->myImv setImage:[UIImage imageNamed:@"img_profile_02_nol"]];
            } else {
                [self->myImv setImage:[UIImage imageNamed:@"img_profile_01_nol"]];
            }
           // }
        }];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return myNames.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[MyCell alloc] init];
    }
    [cell.cellImv setImage:[UIImage imageNamed:myIcons[indexPath.row]]];
    cell.label.text = myNames[indexPath.row];
    
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-16-12,19,22,22)];
    [nextBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [cell addSubview:nextBtn];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0: //我的数据
        {
            BodyDataVC *vc = [[BodyDataVC alloc] init];
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1: //运动周报
        {
            JLSportWeeklyReportsViewController *vc = [[JLSportWeeklyReportsViewController alloc] init];
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2: //设置
        {
            SettingVC *vc = [[SettingVC alloc] init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3: //关于
        {
            AboutVC *vc = [[AboutVC alloc] init];
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark 进入个人信息界面
-(void)personMessageClick{
    PersonInfoVC *vc = [[PersonInfoVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
}

- (void)languageChange {
    myNames = @[kJL_TXT("我的数据"),kJL_TXT("运动周报"),kJL_TXT("设置"),kJL_TXT("关于")];
    myLabel.text =  kJL_TXT("我的");
    [mTableView reloadData];
}

@end
