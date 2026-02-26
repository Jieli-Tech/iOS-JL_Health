//
//  AboutVC.m
//  JieliJianKang
//
//  Created by kaka on 2021/2/20.
//

#import "AboutVC.h"
#import "JL_RunSDK.h"
#import "UserProfileVC.h"
#import "PrivacyPolicyVC.h"
#import "DebugFuncsViewController.h"
#import "NavViewController.h"

@interface AboutVC ()<UITableViewDelegate,UITableViewDataSource>{
    UIImageView *topImv;
    UITableView *aboutTableView;
    UILabel *bottomLab;
    UIButton *bottomLabBtn;
    UIImageView *bottomLabImv;
    NSArray     *tmpArray;
    float       sw;
    __weak IBOutlet UIView   *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel  *titleName;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
}

@end

@implementation AboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    sw = [UIScreen mainScreen].bounds.size.width;
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("关于");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    CGFloat height = kJL_HeightNavBar;
    
    //顶部图标
    UIView *topIConView = [[UIView alloc] initWithFrame:CGRectMake(sw/2-110/2,height+44,110,110)];
    [self.view addSubview:topIConView];
    topImv = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,110,110)];
    topImv.image = [UIImage imageNamed:@"img_logo"];
    topImv.contentMode = UIViewContentModeScaleAspectFill;
    [topIConView addSubview:topImv];
    UILongPressGestureRecognizer *gapes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction)];
    gapes.minimumPressDuration = 4;
    [topIConView addGestureRecognizer:gapes];
    
    height+=154;
    
    UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(sw/2-100/2,height+8,100,22)];
    lab1.font =  [UIFont fontWithName:@"Helvetica-Bold" size:16];
    lab1.text =  kJL_TXT("宜动健康");
    lab1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    lab1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lab1];
        
    UILabel *lab2;
    if([kJL_GET hasPrefix:@"zh"]){
        lab2 = [[UILabel alloc] initWithFrame:CGRectMake(sw/2-150/2,lab1.frame.origin
                                                            .y+lab1.frame.size.height+2,150,18)];
    }else{
        lab2 = [[UILabel alloc] initWithFrame:CGRectMake(sw/2-180/2,lab1.frame.origin
                                                            .y+lab1.frame.size.height+2,180,18)];
    }
    
    lab2.font =  [UIFont systemFontOfSize:13];
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    
    lab2.text =  [NSString stringWithFormat:@"%@%@%@",kJL_TXT("当前版本"),@" v",appVersion];
    lab2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    lab2.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lab2];
    
    aboutTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,lab2.frame.origin
                                                                   .y+lab2.frame.size.height+39,[UIScreen mainScreen].bounds.size.width,60*2)];
    aboutTableView.delegate      = self;
    aboutTableView.dataSource    = self;
    aboutTableView.scrollEnabled = NO;
    aboutTableView.tag = 0 ;
    aboutTableView.rowHeight = 60;
    [aboutTableView setSeparatorColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
    [self.view addSubview:aboutTableView];
    

    
    
    tmpArray = @[kJL_TXT("用户协议"),kJL_TXT("隐私政策")];
    [aboutTableView reloadData];
    
    
    bottomLabBtn = [UIButton new];
    NSString *bottomLabBtnName = [NSString stringWithFormat:@"%@:%@",kJL_TXT("ICP filing information"),@"粤ICP备18069041号-3A"];
    [bottomLabBtn setTitle:bottomLabBtnName forState:UIControlStateNormal];
    bottomLabBtn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [bottomLabBtn setTitleColor:kDF_RGBA(0, 0, 0, 0.3) forState:UIControlStateNormal];
    [bottomLabBtn addTarget:self action:@selector(bottomLabBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomLabBtn];
    
    bottomLabImv = [UIImageView new];
    bottomLabImv.image = [UIImage imageNamed:@"icon_next_10"];
    bottomLabImv.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:bottomLabImv];
   
    
    bottomLab = [[UILabel alloc] init];
    bottomLab.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    bottomLab.text = [NSString stringWithFormat:@"Copyright©2010-%@ %@",[NSDate new].toYYYY,kJL_TXT("珠海市杰理科技股份有限公司")];
    bottomLab.textColor = kDF_RGBA(0, 0, 0, 0.3);
    bottomLab.textAlignment = NSTextAlignmentCenter;
    bottomLab.numberOfLines = 0;
    bottomLab.adjustsFontSizeToFitWidth = true;
    [self.view addSubview:bottomLab];
    [bottomLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(20);
        make.bottom.equalTo(self.view.mas_bottom).offset(-30);
    }];
    
    [bottomLabBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(bottomLab.mas_top);
        make.centerX.equalTo(self.view);
    }];
    
    [bottomLabImv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomLabBtn.mas_right);
        make.width.height.equalTo(@12);
        make.centerY.equalTo(bottomLabBtn);
    }];
}

-(void)bottomLabBtnClick {
    ICPViewController *vc = [[ICPViewController alloc] init];
    vc.urlStr = @"https://beian.miit.gov.cn/";
    [[JLApplicationDelegate navigationController] pushViewController:vc animated:true];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return tmpArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* IDCell = @"lcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDCell];
    if (cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IDCell];
    }

    [cell.contentView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];

    cell.textLabel.text = tmpArray[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"PingFang SC" size: 14];
    cell.textLabel.textColor = kDF_RGBA(36, 36, 36, 1);
    
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-16-22,19,22,22)];
    [nextBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [cell addSubview:nextBtn];
    
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    cell.layoutMargins = UIEdgeInsetsMake(0, 16, 0, 16);
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0){
        UserProfileVC *vc = [[UserProfileVC alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
    if(indexPath.row == 1){
        PrivacyPolicyVC *vc = [[PrivacyPolicyVC alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (IBAction)actionExit:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK: - long press
-(void)longPressAction{
    DebugFuncsViewController *vc = [[DebugFuncsViewController alloc] init];
    NavViewController *nvc = [[NavViewController alloc] initWithRootViewController:vc];
    nvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nvc animated:true completion:nil];
}

@end
