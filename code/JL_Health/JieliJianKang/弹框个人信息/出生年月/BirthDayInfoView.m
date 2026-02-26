//
//  BirthDayInfoView.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/5.
//

#import "BirthDayInfoView.h"
#import "JL_RunSDK.h"
#import "BRDatePickerView.h"

@interface BirthDayInfoView()<LanguagePtl>{
    float sw;
    float sh;
    
    UIView *bgView;
    UIView *view;
    UIView *containerView; //出生年月容器View
    
    UILabel *okLabel;      //确定
    UILabel *cancelLabel;  //取消
    
    UIButton *cancelBtn;
    UIButton *sureBtn;
    
    NSString *mSelectValue; //选择的年月日
    
    BRDatePickerView *datePickerView;
}
@end

@implementation BirthDayInfoView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        sw = frame.size.width;
        sh = frame.size.height;
        [[LanguageCls share] add:self];
        [self initUI];
    }
    return self;
}

-(void)initUI{
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self addSubview:bgView];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.2;
    
    view = [[UIView alloc] initWithFrame:CGRectMake(15, 160, sw-30, 370)];
    [self addSubview:view];
    view.backgroundColor = kDF_RGBA(255, 255, 255, 1);
    view.layer.shadowColor = kDF_RGBA(205, 230, 251, 0.4).CGColor;
    view.layer.shadowOffset = CGSizeMake(0,1);
    view.layer.shadowOpacity = 1;
    view.layer.shadowRadius = 10;
    view.layer.cornerRadius = 16;
    
    _labelTitleName = [[UILabel alloc] init];
    _labelTitleName.frame = CGRectMake((sw-30)/2-72/2,20,150,25);
    _labelTitleName.numberOfLines = 0;
    _labelTitleName.font =  [UIFont fontWithName:@"PingFangSC" size:18];
    _labelTitleName.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [view addSubview:_labelTitleName];
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(38, _labelTitleName.frame.origin.y+_labelTitleName.frame.size.height+20, sw-30-76, 235)];
    [view addSubview:containerView];
    containerView.backgroundColor = [UIColor whiteColor];
    
    datePickerView = [[BRDatePickerView alloc]init];
    datePickerView.pickerMode = BRDatePickerModeYMD;
    datePickerView.maxDate = [NSDate date];
    datePickerView.isAutoSelect = YES;
    datePickerView.showUnitType = BRShowUnitTypeOnlyCenter;
    datePickerView.resultBlock = ^(NSDate *selectDate, NSString *selectValue) {
        self->mSelectValue = selectValue;
    };
    NSDate *date = [NSDate date];
    mSelectValue = [NSString stringWithFormat:@"%04d%@%02d%@%02d%@", (int)date.br_year,kJL_TXT("年"),(int)date.br_month,kJL_TXT("月"), (int)date.br_day, kJL_TXT("日")];
    // 自定义选择器主题样式
    BRPickerStyle *customStyle = [[BRPickerStyle alloc]init];
    customStyle.pickerColor = containerView.backgroundColor;
    datePickerView.pickerStyle = customStyle;
    
    // 添加选择器到容器视图
    [datePickerView addPickerToView:containerView];
    
    cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,containerView.frame.origin.y+containerView.frame.size.height+5,view.frame.size.width/2,55)];
    [cancelBtn setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:kDF_RGBA(85.0, 140.0, 255.0, 1.0) forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC" size:18];
    [view addSubview:cancelBtn];
    
    sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width/2,containerView.frame.origin.y+containerView.frame.size.height+5,view.frame.size.width/2,55)];
    [sureBtn setTitle:kJL_TXT("确定") forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(confirmBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitleColor:kDF_RGBA(85.0, 140.0, 255.0, 1.0) forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC" size:18];
    [view addSubview:sureBtn];
}

-(void)setSelectValue:(NSString *)selectValue{
    NSString *str1 = [selectValue stringByReplacingOccurrencesOfString:kJL_TXT("年") withString:@"-"];
    NSString *str2 = [str1 stringByReplacingOccurrencesOfString:kJL_TXT("月") withString:@"-"];
    NSString *str3 = [str2 stringByReplacingOccurrencesOfString:kJL_TXT("日") withString:@""];

    datePickerView.selectValue = str3;
}

#pragma mark 取消操作
-(void)cancelBtnAction:(UIButton *)btn{
    self.hidden = YES;
}

#pragma mark 确定操作
-(void)confirmBtnAction:(UIButton *)btn{
    self.hidden = YES;
    if ([_delegate respondsToSelector:@selector(birthdayAction:Month:Day:SelectDate:)]) {
        NSString *str1 = [mSelectValue stringByReplacingOccurrencesOfString:kJL_TXT("年") withString:@""];
        NSString *str2 = [str1 stringByReplacingOccurrencesOfString:kJL_TXT("月") withString:@""];
        NSString *str3 = [str2 stringByReplacingOccurrencesOfString:kJL_TXT("日") withString:@""];
        [_delegate birthdayAction:[str1 substringWithRange:NSMakeRange(0, 4)]
                            Month:[str2 substringWithRange:NSMakeRange(4, 2)]
                              Day:[str3 substringWithRange:NSMakeRange(6, 2)]
                       SelectDate:self->mSelectValue];
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.hidden = YES;
}

- (void)languageChange {
    [cancelBtn setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
    [sureBtn setTitle:kJL_TXT("确定") forState:UIControlStateNormal];
}


@end
