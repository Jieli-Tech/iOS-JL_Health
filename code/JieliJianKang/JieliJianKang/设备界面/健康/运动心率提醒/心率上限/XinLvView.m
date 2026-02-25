//
//  XinLvView.m
//  JieliJianKang
//
//  Created by 李放 on 2021/7/23.
//

#import "XinLvView.h"
#import "JL_RunSDK.h"
#import "BRStringPickerView.h"

@interface XinLvView(){
    float sw;
    float sh;
    
    UIView *bgView;
    UIView *view;
    UIView *containerView;
    
    DFLabel *label1;
    UILabel *okLabel;
    UILabel *cancelLabel;
    UILabel *unitLabel;
    
    UIButton *cancelBtn;
    UIButton *sureBtn;
    
    NSString  *selectValue;
    NSMutableArray *tempArr;
    BRStringPickerView *stringPickerView;
}
@end

@implementation XinLvView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        sw = frame.size.width;
        sh = frame.size.height;
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
    
    label1 = [[DFLabel alloc] init];
    if([kJL_GET hasPrefix:@"zh"] || [kJL_GET hasPrefix:@"en-GB"]){
        label1.frame = CGRectMake((sw-30)/2-72/2,20,72,25);
    }else{
        label1.frame = CGRectMake((sw-30)/2-180/2,20,180,25);
    }
    label1.labelType = DFLeftRight;
    label1.textAlignment = NSTextAlignmentLeft;
    label1.numberOfLines = 0;
    label1.text = kJL_TXT("心率上限");
    label1.font =  [UIFont fontWithName:@"PingFangSC" size:18];
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [view addSubview:label1];
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(38, label1.frame.origin.y+label1.frame.size.height+20, sw-30-76, 235)];
    [view addSubview:containerView];
    containerView.backgroundColor = [UIColor whiteColor];
    
    stringPickerView = [[BRStringPickerView alloc]init];
    stringPickerView.pickerMode = BRStringPickerComponentSingle;
    stringPickerView.type = 0;
    
    tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = 100; i <= 220; i++) {
        [tempArr addObject:[NSString stringWithFormat:@"%@", @(i)]];
    }
    selectValue = @"100";
    stringPickerView.isAutoSelect = YES;
    stringPickerView.resultModelBlock = ^(BRResultModel *resultModel) {
        self->selectValue = resultModel.value;
    };
    stringPickerView.dataSourceArr = [tempArr copy];
    
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
    if ([_delegate respondsToSelector:@selector(xinLvAction:)]) {
        [_delegate xinLvAction:selectValue];
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
    unitLabel.frame = CGRectMake(containerView.frame.size.width/2+30,stringPickerView.frame.size.height/2-21/2,100,21);
    unitLabel.numberOfLines = 0;
    unitLabel.text = kJL_TXT("次/分钟");
    unitLabel.font =  [UIFont fontWithName:@"PingFangSC" size:15];
    unitLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [containerView addSubview:unitLabel];
}

@end
