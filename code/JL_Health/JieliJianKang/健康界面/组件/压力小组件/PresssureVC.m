//
//  PresssureVC.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/29.
//

#import "PresssureVC.h"
#import "JL_RunSDK.h"
#import "DateLabelView.h"
#import "SelectTitleBar.h"
#import "EcDateSelectView.h"

#import "YaLiView.h"
#import "YaLiShow0.h"
#import "YaLiShow1.h"

#import "YaLiView2.h"

@interface PresssureVC ()<DateLabelViewDelegate,SelectActionDelegate,EcDtSltDelegate>{
    UIButton *leftBtn;
    UILabel *titleLab;
    UIButton *dayBtn;
    
    DateLabelView   *datelabView;
    SelectTitleBar  *selectView;
    YaLiView        *yaliView;
    YaLiShow0       *yaliShow_0;
    YaLiShow1       *yaliShow_1;
    
    YaLiView2       *yaliView2;
    
    EcDateSelectView *ecDtSltv;
}

@end

@implementation PresssureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat sH = [UIScreen mainScreen].bounds.size.height;
    float all_H = 850;
    
    UIScrollView *scView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, sH)];
    scView.contentSize = CGSizeMake(width, all_H);
    [scView setScrollEnabled:YES];
    scView.backgroundColor = [JLColor colorWithString:@"#E1966C"];
    [self.view addSubview:scView];
    
    leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(10,kJL_HeightNavBar-40, 40, 40)];
    [leftBtn setImage:[UIImage imageNamed:@"icon_return_nol_white"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBtn];
    
    titleLab = [[UILabel alloc] initWithFrame:CGRectMake(width/2-120, kJL_HeightNavBar-30, 240, 25)];
    titleLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = [UIColor whiteColor];
    titleLab.text = kJL_TXT("压力");
    [self.view addSubview:titleLab];
    
    dayBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-50, kJL_HeightNavBar-40, 40, 40)];
    [dayBtn setImage:[UIImage imageNamed:@"icon_calender_nol"] forState:UIControlStateNormal];
    [dayBtn addTarget:self action:@selector(dayBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dayBtn];
    
    
    selectView = [[SelectTitleBar alloc] initWithFrame:CGRectMake(16, kJL_HeightNavBar, width-32, 34)];
    selectView.delegate = self;
    selectView.selectColor = kDF_RGBA(241, 135, 83, 1);
    [self.view addSubview:selectView];
    
    UIView *subView_0 = [UIView new];
    subView_0.frame = CGRectMake(0, 0, width, all_H);
    [self colorWear:subView_0];
    [scView addSubview:subView_0];
    
    
    float mHeight = selectView.frame.origin.y+selectView.frame.size.height+12;
    datelabView = [[DateLabelView alloc] initWithFrame:CGRectMake(16, mHeight, width-32, 80)];
    datelabView.delegate = self;
    [subView_0 addSubview:datelabView];
    
    yaliView = [[YaLiView alloc] initWithFrame:CGRectMake(0, 230, width, 250)];
    yaliView.hidden = YES;
    [subView_0 addSubview:yaliView];
    
    yaliView2 = [[YaLiView2 alloc] initWithFrame:CGRectMake(0, 230, width, 250)];
    yaliView2.hidden = YES;
    [subView_0 addSubview:yaliView2];
    
    [self barDidSelectIndex:0];
    
    
    UIView *subView_1 = [UIView new];
    subView_1.frame = CGRectMake(0, 230+250, width, 405);
    subView_1.backgroundColor = kDF_RGBA(246, 247, 248, 1);
    subView_1.layer.cornerRadius = 25.0;
    [subView_0 addSubview:subView_1];
    
    CGRect rect_0 = CGRectMake(16, 16, width-32.0, 107);
    yaliShow_0 = [[YaLiShow0 alloc] initByFrame:rect_0];
    [subView_1 addSubview:yaliShow_0];
    
    CGRect rect_1 = CGRectMake(16, 140, width-32.0, 218);
    yaliShow_1 = [[YaLiShow1 alloc] initByFrame:rect_1];
    [subView_1 addSubview:yaliShow_1];

    yaliShow_1.subValue_0 = 0.2;
    yaliShow_1.subValue_1 = 0.5;
    yaliShow_1.subValue_2 = 0.1;
    yaliShow_1.subValue_3 = 0.2;
    [yaliShow_1 updateUI];
    
    [self DateLabTestData:39];
    
    ecDtSltv = [[EcDateSelectView alloc] initWithFrame:CGRectMake(0, 0, width, [UIScreen mainScreen].bounds.size.height)];
    ecDtSltv.delegate = self;
    ecDtSltv.hidden = YES;
    [self.view addSubview:ecDtSltv];
}

-(void)leftBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dayBtnAction{
    ecDtSltv.hidden = NO;
}

//MARK:日历选择回调
-(void)ecDidDateSelected:(NSDate *)date{
    [ecDtSltv setHidden:YES];
}

///MARK: 日期前后回调
-(void)dateLabelViewNextBtnAction{
    
}

-(void)dateLabelViewPreviousBtnAction{
    
}

//MARK: 日期选择回调
-(void)barDidSelectIndex:(NSInteger)index{
    kJLLog(JLLOG_DEBUG, @"日期选择回调 ---> %ld",(long)index);
    
    if(index == 0 || index == 2){
        yaliView.hidden = YES;
        yaliView2.hidden = NO;
        
        if (index == 0) {
            yaliView2.dataArray = @[@(40.0),@(20.0),@(40.0),@(80.0),@(60.0),@(90.0),
                                    @(40.0),@(20.0),@(40.0),@(80.0),@(60.0),@(90.0),
                                    @(40.0),@(20.0),@(40.0),@(80.0),@(60.0),@(90.0),
                                    @(40.0),@(20.0),@(40.0),@(80.0),@(60.0),@(90.0)];
        }

        if (index == 2) {
            yaliView2.dataArray = @[@(40.0),@(20.0),@(40.0),@(80.0),@(60.0),@(90.0),
                                    @(40.0),@(20.0),@(40.0),@(80.0),@(60.0),@(90.0),
                                    @(40.0),@(20.0),@(40.0),@(80.0),@(60.0),@(90.0),
                                    @(40.0),@(20.0),@(40.0),@(80.0),@(60.0),@(90.0),
                                    @(40.0),@(20.0),@(40.0),@(80.0),@(60.0),@(90.0),@(90.0)];
        }
        [yaliView2 loadUI];
    }
    if(index == 1 || index == 3){
        yaliView2.hidden = YES;
        
        yaliView.hidden = NO;
        yaliView.textArray = @[kJL_TXT("我的周一"),kJL_TXT("我的周二"),kJL_TXT("我的周三"),kJL_TXT("我的周四"),kJL_TXT("我的周五"),kJL_TXT("我的周六"),kJL_TXT("我的周日")];
        yaliView.dataArray = @[@(40.0),@(20.0),@(40.0),@(80.0),@(60.0),@(90.0),@(0.0)];
        [yaliView loadUI];
    }
}

-(void)DateLabTestData:(int)step{
    [datelabView setTitleLab:@"2021年2月22日-2021年3月3日" SecondLabel:@"2/23"];
    
    // 属性文本生成器
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    NSString *stepStr = [NSString stringWithFormat:@"%d%@",step,@"正常"];
    textContainer.text = stepStr;
    
    // 整体设置属性
    textContainer.linesSpacing = 2;
    textContainer.paragraphSpacing = 5;
    textContainer.textAlignment = kCTTextAlignmentCenter;
    // 文字样式
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [stepStr rangeOfString:[NSString stringWithFormat:@"%d",step]];
    textStorage.font = [UIFont fontWithName:@"PingFangSC-Medium" size:30];
    textStorage.textColor = kDF_RGBA(255, 255, 255, 1);
    [textContainer addTextStorage:textStorage];

    // 文字样式
    TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
    textStorage2.range = [stepStr rangeOfString:@"正常"];
    textStorage2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    textStorage2.textColor = kDF_RGBA(255, 255, 255, 0.7);
    [textContainer addTextStorage:textStorage2];
    
    [datelabView setTextWithContainer:textContainer];
}

-(void)colorWear:(UIView *)view{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame =CGRectMake(0,0,view.frame.size.width,view.frame.size.height);
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[JLColor colorWithString:@"#E1966C"].CGColor,
                       (id)[JLColor colorWithString:@"#F18753"].CGColor,
                       nil];
    [view.layer insertSublayer:gradient atIndex:0];
}

@end
