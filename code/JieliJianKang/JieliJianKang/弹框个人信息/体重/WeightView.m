//
//  WeightView.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/8.
//

#import "WeightView.h"
#import "JL_RunSDK.h"
#import "BRStringPickerView.h"

@interface WeightView()<LanguagePtl>{
    float sw;
    float sh;
    
    UIView *bgView;
    UIView *view;
    UIView *containerView;
    
    UILabel *label1;
    UILabel *okLabel;
    UILabel *cancelLabel;
    UILabel *unitLabel;
    
    UIButton *cancelBtn;
    UIButton *sureBtn;
    
    NSString  *selectValue;
    NSMutableArray *tempArr;
    BRStringPickerView *stringPickerView;
    
    NSString *unitStr;
}
@end

@implementation WeightView

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
    
    label1 = [[UILabel alloc] init];
    if([kJL_GET hasPrefix:@"zh"]){
        label1.frame = CGRectMake((sw-30)/2-36/2,20,36,25);
    }else{
        label1.frame = CGRectMake((sw-30)/2-72/2,20,sw,25);
    }
    label1.numberOfLines = 0;
    label1.text = kJL_TXT("体重");
    label1.font =  [UIFont fontWithName:@"PingFangSC" size:18];
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [view addSubview:label1];
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(38, label1.frame.origin.y+label1.frame.size.height+20, sw-30-76, 235)];
    [view addSubview:containerView];
    containerView.backgroundColor = [UIColor whiteColor];
    
    stringPickerView = [[BRStringPickerView alloc]init];
    stringPickerView.pickerMode = BRStringPickerComponentSingle;
    stringPickerView.type = 1;
    
    unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    int originIndex = 0;
    int totalCount = 0;
    if([unitStr isEqualToString:@("英制")]){
        originIndex = 10*2.205;
        totalCount  = 250*2.205;
    }else{
        originIndex = 10;
        totalCount  = 250;
    }
    tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = originIndex; i <= totalCount; i++) {
        [tempArr addObject:[NSString stringWithFormat:@"%@", @(i)]];
    }
    selectValue = @"10";
    stringPickerView.isAutoSelect = YES;
    stringPickerView.resultModelBlock = ^(BRResultModel *resultModel) {
        self->selectValue = resultModel.value;
    };
    stringPickerView.dataSourceArr = [tempArr copy];
    // 添加选择器到容器视图
    [stringPickerView addPickerToView:containerView];
    
    unitLabel = [[UILabel alloc] init];
    unitLabel.frame = CGRectMake(containerView.frame.size.width-100-30,stringPickerView.frame.size.height/2-21/2,30,21);
    unitLabel.numberOfLines = 0;
    
    if([unitStr isEqualToString:@("英制")]){
        unitLabel.text = kJL_TXT("磅");
    }else{
        unitLabel.text = kJL_TXT("公斤");
    }
    unitLabel.font =  [UIFont fontWithName:@"PingFangSC" size:15];
    unitLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [containerView addSubview:unitLabel];
    
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

#pragma mark 取消操作
-(void)cancelBtnAction:(UIButton *)btn{
    self.hidden = YES;
}

#pragma mark 确定操作
-(void)confirmBtnAction:(UIButton *)btn{
    self.hidden = YES;
    if ([_delegate respondsToSelector:@selector(weightAction:)]) {
        [_delegate weightAction:selectValue];
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.hidden = YES;
}

-(void)setSelectMValue:(NSString *)selectMValue{
    int index = (int)[[tempArr copy] indexOfObject:selectMValue];
    stringPickerView.selectIndex = index;
    // 添加选择器到容器视图
    [stringPickerView addPickerToView:containerView];
    
    unitLabel = [[UILabel alloc] init];
    unitLabel.frame = CGRectMake(containerView.frame.size.width/2+30,stringPickerView.frame.size.height/2-21/2,containerView.frame.size.width/2,21);
    unitLabel.numberOfLines = 0;
    if(unitStr.length == 0){ //公制
        unitLabel.text = kJL_TXT("公斤");
    }else{
        if([unitStr isEqualToString:@("公制")]){
            unitLabel.text = kJL_TXT("公斤");
        }
        if([unitStr isEqualToString:@("英制")]){
            unitLabel.text = kJL_TXT("磅");
        }
    }
    unitLabel.font =  [UIFont fontWithName:@"PingFangSC" size:15];
    unitLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [containerView addSubview:unitLabel];
}

- (void)languageChange {
    
    if([kJL_GET hasPrefix:@"zh"]){
        label1.frame = CGRectMake((sw-30)/2-36/2,20,36,25);
    }else{
        label1.frame = CGRectMake((sw-30)/2-72/2,20,sw,25);
    }
    label1.numberOfLines = 0;
    label1.text = kJL_TXT("体重");
    
    [cancelBtn setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
    [sureBtn setTitle:kJL_TXT("确定") forState:UIControlStateNormal];
    if(unitStr.length == 0){ //公制
        unitLabel.text = kJL_TXT("公斤");
    }else{
        if([unitStr isEqualToString:@("公制")]){
            unitLabel.text = kJL_TXT("公斤");
        }
        if([unitStr isEqualToString:@("英制")]){
            unitLabel.text = kJL_TXT("磅");
        }
    }
}

/// 计算宽度
/// @param text 文字
/// @param height 高度
/// @param font 字体
- (CGFloat)getWidthWithText:(NSString *)text height:(CGFloat)height font:(CGFloat)font{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil];
    return rect.size.width;
}


@end

