//
//  XinLvView.m
//  JieliJianKang
//
//  Created by 李放 on 2021/7/23.
//

#import "SleepHourMinutePickerView.h"
#import "JL_RunSDK.h"
#import "BRStringPickerView.h"

#define DATEPICKER_interval 1//设置分钟时间间隔

@interface SleepHourMinutePickerView(){
    float sw;
    float sh;
    
    UIView *bgView;
    UIView *view;
    UIView *containerView;
    
    UILabel *label1;
    UILabel *okLabel;
    UILabel *cancelLabel;
    
    UILabel *unitStartTimeLabel;
    UILabel *unitEndTimeLabel;

    UIButton *cancelBtn;
    UIButton *sureBtn;
    
    NSMutableArray *startTimeSelectArray;
    NSMutableArray *endTimeSelectArray;

    BRStringPickerView *startTimeStringPickerView;
    BRStringPickerView *endTimeStringPickerView;

    NSMutableArray *startTimeHourArray;
    NSMutableArray *startTimeMinuteArray;
    
    NSMutableArray *endTimeHourArray;
    NSMutableArray *endTimeMinuteArray;
}
@end

@implementation SleepHourMinutePickerView

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
    
    label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake((sw-30)/2-36/2,20,sw,25);
    label1.numberOfLines = 0;
    label1.font =  [UIFont fontWithName:@"PingFangSC" size:18];
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [view addSubview:label1];
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(38, label1.frame.origin.y+label1.frame.size.height+20, sw-30-76, 235)];
    [view addSubview:containerView];
    containerView.backgroundColor = [UIColor whiteColor];
    
    startTimeStringPickerView = [[BRStringPickerView alloc]init];
    startTimeStringPickerView.pickerMode = BRStringPickerComponentMulti;
    startTimeStringPickerView.type = 0;
    
    startTimeStringPickerView.isAutoSelect = YES;
    startTimeStringPickerView.resultModelArrayBlock = ^(NSArray <BRResultModel *> * _Nullable resultModelArr){
        NSMutableArray *startTimeModeArray = [[NSMutableArray alloc]init];
        for (BRResultModel *model in resultModelArr) {
            [startTimeModeArray addObject:model.value];
        }
        self->startTimeSelectArray = startTimeModeArray;
    };
    
    endTimeStringPickerView = [[BRStringPickerView alloc]init];
    endTimeStringPickerView.pickerMode = BRStringPickerComponentMulti;
    endTimeStringPickerView.type = 0;
    
    endTimeStringPickerView.isAutoSelect = YES;
    endTimeStringPickerView.resultModelArrayBlock = ^(NSArray <BRResultModel *> * _Nullable resultModelArr){
        NSMutableArray *endTimeModeArray = [[NSMutableArray alloc]init];
        for (BRResultModel *model in resultModelArr) {
            [endTimeModeArray addObject:model.value];
        }
        self->endTimeSelectArray = endTimeModeArray;
    };
    
    startTimeHourArray   = [self ishave:startTimeHourArray];
    startTimeMinuteArray = [self ishave:startTimeMinuteArray];
    for (int i= 0 ; i<60; i++)
    {
        if (i<24) {
            [startTimeHourArray addObject:[NSString stringWithFormat:@"%02d",i]];
        }
        if (i%DATEPICKER_interval==0) {
            [startTimeMinuteArray addObject:[NSString stringWithFormat:@"%02d",i]];
        }
    }
    startTimeStringPickerView.dataSourceArr = @[startTimeHourArray,startTimeMinuteArray];
    
    endTimeHourArray   = [self ishave:endTimeHourArray];
    endTimeMinuteArray = [self ishave:endTimeMinuteArray];
    for (int i= 0 ; i<60; i++)
    {
        if (i<24) {
            [endTimeHourArray addObject:[NSString stringWithFormat:@"%02d",i]];
        }
        if (i%DATEPICKER_interval==0) {
            [endTimeMinuteArray addObject:[NSString stringWithFormat:@"%02d",i]];
        }
    }
    endTimeStringPickerView.dataSourceArr = @[endTimeHourArray,endTimeMinuteArray];
    
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

- (NSMutableArray *)ishave:(id)mutableArray
{
    if (mutableArray)
        [mutableArray removeAllObjects];
    else
        mutableArray = [NSMutableArray array];
    return mutableArray;
}

#pragma mark 取消操作
-(void)cancelBtnAction:(UIButton *)btn{
    self.hidden = YES;
}

#pragma mark 确定操作
-(void)confirmBtnAction:(UIButton *)btn{
    self.hidden = YES;
    if(self.type == 0){
        if ([_delegate respondsToSelector:@selector(SleepHourMinutePickerStartTime:)]) {
            [_delegate SleepHourMinutePickerStartTime:startTimeSelectArray];
        }
    }
    if(self.type == 1){
        if ([_delegate respondsToSelector:@selector(SleepHourMinutePickerEndTime:)]) {
            [_delegate SleepHourMinutePickerEndTime:endTimeSelectArray];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.hidden = YES;
}

-(void)setStartTimeselectIndexs:(NSArray<NSNumber *> *)startTimeselectIndexs{
    if(self.type == 0){
        label1.text = kJL_TXT("开启时间");
    }
    if(self.type == 1){
        label1.text = kJL_TXT("结束时间");
    }
    
    startTimeStringPickerView.selectIndexs = startTimeselectIndexs;
    
    // 添加选择器到容器视图
    [startTimeStringPickerView addPickerToView:containerView];
    unitStartTimeLabel = [[UILabel alloc] init];
    unitStartTimeLabel.frame = CGRectMake(containerView.frame.size.width/2+15,startTimeStringPickerView.frame.size.height/2-21/2,100,21);
    unitStartTimeLabel.numberOfLines = 0;
    unitStartTimeLabel.text = kJL_TXT(":");
    unitStartTimeLabel.font =  [UIFont fontWithName:@"PingFangSC" size:24];
    unitStartTimeLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [containerView addSubview:unitStartTimeLabel];
}

-(void)setEndTimeselectIndexs:(NSArray<NSNumber *> *)endTimeselectIndexs{
    if(self.type == 0){
        label1.text = kJL_TXT("开启时间");
    }
    if(self.type == 1){
        label1.text = kJL_TXT("结束时间");
    }
    
    endTimeStringPickerView.selectIndexs = endTimeselectIndexs;
    
    // 添加选择器到容器视图
    [endTimeStringPickerView addPickerToView:containerView];
    unitEndTimeLabel = [[UILabel alloc] init];
    unitEndTimeLabel.frame = CGRectMake(containerView.frame.size.width/2+15,endTimeStringPickerView.frame.size.height/2-21/2,100,21);
    unitEndTimeLabel.numberOfLines = 0;
    unitEndTimeLabel.text = kJL_TXT(":");
    unitEndTimeLabel.font =  [UIFont fontWithName:@"PingFangSC" size:24];
    unitEndTimeLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [containerView addSubview:unitEndTimeLabel];
}

@end
