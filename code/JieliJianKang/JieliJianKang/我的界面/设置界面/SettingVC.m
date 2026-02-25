//
//  SettingVC.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/2/18.
//

#import "SettingVC.h"
#import "JL_RunSDK.h"
#import "AboutVC.h"
#import "MyAccountVC.h"
#import "MyTargetVC.h"
#import "UnitsView.h"
#import "MessageNoticeVC.h"
#import "LanguageViewController.h"

#define UNITS_ALERT             @"UNITS_ALERT"

@interface SettingVC ()<UnitsDelegate,LanguagePtl>{
    UIView *accountView;     //账号和安全
    UIView *mubiaoView;      //目标View
    UIView *myDanWeiView;    //单位View;
    UIView *languageView;
    
    UIView *mView1;          //消息通知、天气推送、单位设置
    UIView *messageView;     //消息通知View
    UIView *weatherView;     //天气推送View
    UIView *danweiView;      //单位设置View
    UIView *mView2;          //蓝牙断开提醒、抬腕亮屏
    UIView *bluetoothView;   //蓝牙断开提醒View
    UIView *taiwanView;      //抬腕亮屏View
    UIView *cleanCacheView;  //清理缓存View
    UnitsView *unitsView;
    UILabel   *danweiLabel2;
    int      unnitsIndex;    //单位索引
    
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    
    UILabel *accountLabel;
    UILabel *mubiaoLabel;
    UILabel *danweiLabel;
    UILabel *langagueLabel;
    UILabel *languageLabel2;
    UILabel *cleanLabel;

    
}

@end

@implementation SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LanguageCls share] add:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [self initUI];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    float sw = [DFUITools screen_2_W];
    float sh = [DFUITools screen_2_H];

    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("设置");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    CGFloat height = kJL_HeightNavBar;
    
    accountView = [[UIView alloc] initWithFrame:CGRectMake(0, height+8, sw, 60)];
    [self.view addSubview:accountView];
    UITapGestureRecognizer *accountGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(accountClick)];
    [accountView addGestureRecognizer:accountGestureRecognizer];
    accountView.userInteractionEnabled=YES;
    
    accountLabel = [[UILabel alloc] init];
    accountLabel.frame = CGRectMake(16,19,sw-22,21);
    accountLabel.numberOfLines = 0;
    [accountView addSubview:accountLabel];
    accountLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    accountLabel.text =  kJL_TXT("账号与安全");
    accountLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UIButton *accountBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-16-22,19,22,22)];
    [accountBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [accountView addSubview:accountBtn];
    accountView.backgroundColor = [UIColor whiteColor];
    
    mubiaoView = [[UIView alloc] initWithFrame:CGRectMake(0, accountView.frame.origin.y+accountView.frame.size.height+8, sw, 60)];
    [self.view addSubview:mubiaoView];
    UITapGestureRecognizer *mubiaoGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(muBiaoClick)];
    [mubiaoView addGestureRecognizer:mubiaoGestureRecognizer];
    mubiaoView.userInteractionEnabled=YES;
    
    mubiaoLabel = [[UILabel alloc] init];
    mubiaoLabel.frame = CGRectMake(16,19,sw-22,21);
    mubiaoLabel.numberOfLines = 0;
    [mubiaoView addSubview:mubiaoLabel];
    mubiaoLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    mubiaoLabel.text =  kJL_TXT("设置目标");
    mubiaoLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UIButton *mubiaoBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-16-22,19,22,22)];
    [mubiaoBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [mubiaoView addSubview:mubiaoBtn];
    mubiaoView.backgroundColor = [UIColor whiteColor];
    
    myDanWeiView = [[UIView alloc] initWithFrame:CGRectMake(0, mubiaoView.frame.origin.y+mubiaoView.frame.size.height+8, sw, 60)];
    [self.view addSubview:myDanWeiView];
    
    UITapGestureRecognizer *danweiGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(danweiClick)];
    [myDanWeiView addGestureRecognizer:danweiGestureRecognizer];
    myDanWeiView.userInteractionEnabled=YES;
    
    danweiLabel = [[UILabel alloc] init];
    danweiLabel.frame = CGRectMake(16,19,sw-70,21);
    danweiLabel.numberOfLines = 0;
    [myDanWeiView addSubview:danweiLabel];
    danweiLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    danweiLabel.text =  kJL_TXT("单位设置");
    danweiLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UIButton *danweiBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-16-22,19,22,22)];
    [danweiBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [myDanWeiView addSubview:danweiBtn];
    myDanWeiView.backgroundColor = [UIColor whiteColor];
    
    danweiLabel2 = [[UILabel alloc] init];
//    if([kJL_GET hasPrefix:@"zh"]){
//        danweiLabel2.frame = CGRectMake(sw-16-22-30,20,50,18);
//    }else{
//        danweiLabel2.frame = CGRectMake(sw-16-22-80,20,100,18);
//    }
    danweiLabel2.numberOfLines = 0;
    [myDanWeiView addSubview:danweiLabel2];
    danweiLabel2.font =  [UIFont fontWithName:@"PingFang SC" size: 13];
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:UNITS_ALERT];
    if(unitStr.length == 0){
        danweiLabel2.text =  kJL_TXT("公制");
    }else{
        if([unitStr isEqualToString:@("公制")]){
            danweiLabel2.text = kJL_TXT("公制");
            unnitsIndex = 0;
        }
        if([unitStr isEqualToString:@("英制")]){
            danweiLabel2.text = kJL_TXT("英制");
            unnitsIndex = 1;
        }
    }
    [self changeUnitsFrame];
    danweiLabel2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    
    unitsView = [[UnitsView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    unitsView.delegate = self;
    unitsView.hidden = YES;
    
    languageView = [[UIView alloc] initWithFrame:CGRectMake(0, myDanWeiView.frame.origin.y+myDanWeiView.frame.size.height+8, sw, 60)];
    languageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:languageView];
    
    UITapGestureRecognizer *danweiGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(langagueClick)];
    [languageView addGestureRecognizer:danweiGestureRecognizer1];
    
    langagueLabel = [[UILabel alloc] init];
    langagueLabel.frame = CGRectMake(16,19,sw-70,21);
    langagueLabel.numberOfLines = 0;
    [languageView addSubview:langagueLabel];
    langagueLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    langagueLabel.text =  kJL_TXT("多语言");
    langagueLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UIButton *languageBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-16-22,19,22,22)];
    [languageBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [languageView addSubview:languageBtn];
    languageView.backgroundColor = [UIColor whiteColor];
    
    languageLabel2 = [[UILabel alloc] init];
    languageLabel2.frame = CGRectMake(sw-22-110-12,20,110,18);
    languageLabel2.textAlignment = NSTextAlignmentRight;
    languageLabel2.font =  [UIFont fontWithName:@"PingFang SC" size: 13];
    languageLabel2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    [languageView addSubview:languageLabel2];
    [self setlanguageLabel];
    
    cleanCacheView = [[UIView alloc] initWithFrame:CGRectMake(0, languageView.frame.origin.y+languageView.frame.size.height+8, sw, 60)];
    cleanCacheView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cleanCacheView];

    UITapGestureRecognizer *cleanGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cleanClick)];
    [cleanCacheView addGestureRecognizer:cleanGestureRecognizer];
    
    cleanLabel = [[UILabel alloc] init];
    cleanLabel.frame = CGRectMake(16,19,sw-70,21);
    cleanLabel.numberOfLines = 0;
    [cleanCacheView addSubview:cleanLabel];
    cleanLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    cleanLabel.text =  kJL_TXT("清理缓存");
    cleanLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UIButton *cleanBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-16-22,19,22,22)];
    [cleanBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [cleanCacheView addSubview:cleanBtn];
    
    [self.view addSubview:unitsView];
}

-(void)changeUnitsFrame{
    float sw = [DFUITools screen_2_W];
    
    CGFloat length = [self getWidthWithString:danweiLabel2.text font:[UIFont fontWithName:@"PingFang SC" size: 13]];
    danweiLabel2.frame = CGRectMake(sw-22-length-12,20,length,18);
}

-(double)getWidthWithString:(NSString*)str font:(UIFont*)font{
    NSDictionary *dict = @{NSFontAttributeName:font};
    CGSize detailSize = [str sizeWithAttributes:dict];
    return detailSize.width;
}

#pragma mark 进入账号与安全
-(void)accountClick{
    MyAccountVC *vc = [[MyAccountVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
}

#pragma mark 进入目标界面
-(void)muBiaoClick{
    MyTargetVC *vc = [[MyTargetVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
}

#pragma mark 进入单位设置界面
-(void)danweiClick{
    unitsView.hidden = NO;
    unitsView.selectValue = unnitsIndex;
}

-(void)langagueClick{
    LanguageViewController *vc = [[LanguageViewController alloc] init];
    [self.navigationController pushViewController:vc animated:true];
}

-(void)cleanClick{
    
}


- (IBAction)actionExit:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)didSelectUnits:(int )index{
    unnitsIndex = index;
    NSString *tempStr;
    if(index == 0){
        danweiLabel2.text = kJL_TXT("公制");
        tempStr = @"公制";
    }
    if(index == 1){
        danweiLabel2.text = kJL_TXT("英制");
        tempStr = @"英制";
    }
    [self changeUnitsFrame];
    
    [[NSUserDefaults standardUserDefaults] setValue:tempStr forKey:UNITS_ALERT];
}

-(void)setlanguageLabel{
    if ([kJL_GET isEqualToString:@"zh-Hans"]) {
        languageLabel2.text = kJL_TXT("简体中文");
    }else if ([kJL_GET isEqualToString:@"en-GB"]) {
        languageLabel2.text = kJL_TXT("英语");
    }else if ([kJL_GET hasPrefix:@"ja"]) {
        languageLabel2.text = kJL_TXT("日语");
    }else if ([kJL_GET hasPrefix:@"ko"]){
        languageLabel2.text = kJL_TXT("韩语");
    }else if ([kJL_GET hasPrefix:@"fr"]){
        languageLabel2.text = kJL_TXT("法语");
    }else if ([kJL_GET hasPrefix:@"de"]){
        languageLabel2.text = kJL_TXT("德语");
    }else if ([kJL_GET hasPrefix:@"it"]){
        languageLabel2.text = kJL_TXT("意大利语");
    }else if ([kJL_GET hasPrefix:@"pt"]){
        languageLabel2.text = kJL_TXT("葡萄牙语");
    }else if ([kJL_GET hasPrefix:@"es"]){
        languageLabel2.text = kJL_TXT("西班牙语");
    }else if ([kJL_GET hasPrefix:@"sv"]){
        languageLabel2.text = kJL_TXT("瑞典语");
    }else if ([kJL_GET hasPrefix:@"pl"]){
        languageLabel2.text = kJL_TXT("波兰语");
    }else if ([kJL_GET hasPrefix:@"ru"]){
        languageLabel2.text = kJL_TXT("俄语");
    }else if ([kJL_GET hasPrefix:@"tr"]){
        languageLabel2.text = kJL_TXT("土耳其语");
    }else if ([kJL_GET hasPrefix:@"vi"]){
        languageLabel2.text = kJL_TXT("越南语");
    }else if ([kJL_GET hasPrefix:@"he"]){
        languageLabel2.text = kJL_TXT("希伯来语");
    }else if ([kJL_GET hasPrefix:@"th"]){
        languageLabel2.text = kJL_TXT("泰语");
    }else if ([kJL_GET hasPrefix:@"ar"]){
        languageLabel2.text = kJL_TXT("阿拉伯语");
    }else if ([kJL_GET hasPrefix:@"id"]){
        languageLabel2.text = kJL_TXT("印尼语");
    }else if ([kJL_GET hasPrefix:@"ms"]){
        languageLabel2.text = kJL_TXT("马来语");
    }else if ([kJL_GET hasPrefix:@"fa"]){
        languageLabel2.text = kJL_TXT("波斯语");
    }else{
        languageLabel2.text = kJL_TXT("跟随系统");
    }
}

- (void)languageChange {
    [self setlanguageLabel];
    titleName.text = kJL_TXT("设置");
    accountLabel.text =  kJL_TXT("账号与安全");
    langagueLabel.text =  kJL_TXT("多语言");
    cleanLabel.text =  kJL_TXT("清理缓存");
    mubiaoLabel.text =  kJL_TXT("设置目标");
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:UNITS_ALERT];
    if(unitStr.length == 0){
        danweiLabel2.text =  kJL_TXT("公制");
    }else{
        if([unitStr isEqualToString:@("公制")]){
            danweiLabel2.text = kJL_TXT("公制");
            unnitsIndex = 0;
        }
        if([unitStr isEqualToString:@("英制")]){
            danweiLabel2.text = kJL_TXT("英制");
            unnitsIndex = 1;
        }
    }
    danweiLabel.text =  kJL_TXT("单位设置");
    
}



@end
