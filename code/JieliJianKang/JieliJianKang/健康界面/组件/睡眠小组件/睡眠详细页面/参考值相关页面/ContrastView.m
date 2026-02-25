//
//  ContrastView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/29.
//

#import "ContrastView.h"
#import "SleepDetailCell.h"
#import "JL_RunSDK.h"

@interface ContrastView ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *subTableView;
    NSMutableArray *dataArray;
}
@end

@implementation ContrastView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        dataArray = [NSMutableArray new];
        subTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        subTableView.tableFooterView = [UIView new];
        subTableView.rowHeight = 75;
        subTableView.delegate = self;
        subTableView.dataSource = self;
        subTableView.backgroundColor = [UIColor clearColor];
        [subTableView registerNib:[UINib nibWithNibName:@"SleepDetailCell" bundle:nil] forCellReuseIdentifier:@"SleepDetailCell"];
        [self addSubview:subTableView];
        self.layer.cornerRadius = 16;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)setDataArray:(NSArray *)array{
    [dataArray removeAllObjects];
    [dataArray setArray:array];
    [subTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SleepDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SleepDetailCell" forIndexPath:indexPath];
    ContrastData *item = dataArray[indexPath.row];
    cell.ReferenceLab.text = item.reference;
    cell.actualLab.text = item.actural;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *tmpStr;
    UIColor *color;
    switch (item.interval) {
        case SleepData_Normal:{
            tmpStr = kJL_TXT("正常");
            color = kDF_RGBA(119, 206, 64, 1);
        }break;
        case SleepData_Hight:{
            tmpStr = kJL_TXT("睡眠偏高");
            color = kDF_RGBA(224, 109, 99, 1);
        }break;
        case SleepData_Low:{
            tmpStr = kJL_TXT("偏低");
            color = kDF_RGBA(253, 184, 90, 1);
        }break;
        default:
            break;
    }
    cell.statusLab.textColor = color;
    cell.statusLab.text = tmpStr;
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_delegate respondsToSelector:@selector(contrastViewDidSelect:)]) {
        [_delegate contrastViewDidSelect:indexPath.row];
    }
}


@end




@implementation ContrastData

+(ContrastData *)make:(NSString *)act with:(NSString*)ref interval:(SleepData_Interval)interval{
    ContrastData *objc = [[ContrastData alloc] init];
    objc.actural = act;
    objc.reference = ref;
    objc.interval = interval;
    return objc;
}

+(NSArray *_Nonnull)makeDataByType:(DateType)type allTime:(int) sleepHour WithMin:(int ) sleepMin WithDeepPercentage:(NSString* _Nonnull)deep WithShallowPercentage:(NSString * _Nonnull)shallow WithRem:(NSString* _Nonnull)rem DeepSleepScre:(NSInteger)deepSleepScre WithWakeCount:(int)awakeCount{
    switch (type) {
        case  DateType_Day:{
            return [self makeTestData:sleepHour WithMin:sleepMin WithDeepPercentage:deep WithShallowPercentage:shallow WithRem:rem DeepSleepScre:deepSleepScre WithWakeCount:awakeCount];
        }
        default:{
            return [self makeTestData2:sleepHour WithMin:sleepMin WithDeepPercentage:deep WithShallowPercentage:shallow WithRem:rem DeepSleepScre:deepSleepScre WithWakeCount:awakeCount];
            break;
        }
            
    }
    return [self makeTestData:sleepHour WithMin:sleepMin WithDeepPercentage:deep WithShallowPercentage:shallow WithRem:rem DeepSleepScre:deepSleepScre WithWakeCount:awakeCount];
}

+(NSArray *_Nonnull)makeTestData:(int) sleepHour WithMin:(int ) sleepMin WithDeepPercentage:(NSString* _Nonnull)deep WithShallowPercentage:(NSString * _Nonnull)shallow WithRem:(NSString* _Nonnull)rem DeepSleepScre:(NSInteger)deepSleepScre WithWakeCount:(int)awakeCount{
    NSMutableArray *tmpArray = [NSMutableArray new];
    ContrastData *objc = [[ContrastData alloc] init];
    objc.actural = [NSString stringWithFormat:@"%@ %d%@%d%@",kJL_TXT("夜间睡眠时间"),sleepHour,kJL_TXT("小时"),sleepMin,kJL_TXT("分钟")];//@"夜间睡眠时间6小时39分钟";
    objc.reference = [NSString stringWithFormat:@"%@ %@%@",kJL_TXT("参考值"),@"6-10",kJL_TXT("小时")];//@"参考值：6-10小时";
    objc.interval = [self allTime:sleepHour];
    [tmpArray addObject:objc];
    
    ContrastData *objc1 = [[ContrastData alloc] init];
    objc1.actural = [NSString stringWithFormat:@"%@ %@",kJL_TXT("深睡比例"),deep];//@"深睡比例27%";
    objc1.reference = [NSString stringWithFormat:@"%@ %@",kJL_TXT("参考值"),@"20-60%"];//@"参考值：20-60%";
    double k = (double)[[deep stringByReplacingOccurrencesOfString:@"%" withString:@""] intValue]/100.0;
    objc1.interval = [self deepTime:k];
    [tmpArray addObject:objc1];
    
    ContrastData *objc2 = [[ContrastData alloc] init];
    objc2.actural = [NSString stringWithFormat:@"%@ %@",kJL_TXT("浅睡比例"),shallow];//@"浅睡比例60%";
    objc2.reference = [NSString stringWithFormat:@"%@ %@",kJL_TXT("参考值"),@"<55%"];//@"参考值：<55%";
    double k1 = (double)[[shallow stringByReplacingOccurrencesOfString:@"%" withString:@""] intValue]/100.0;
    objc2.interval = [self shallowTime:k1];
    [tmpArray addObject:objc2];
    
    ContrastData *objc3 = [[ContrastData alloc] init];
    objc3.actural = [NSString stringWithFormat:@"%@ %@",kJL_TXT("快速眼动比例"),rem];//@"快速眼动比例13%";
    objc3.reference = [NSString stringWithFormat:@"%@ %@",kJL_TXT("参考值"),@"10-30%"];//@"参考值：10-30%";
    double k2 = (double)[[rem stringByReplacingOccurrencesOfString:@"%" withString:@""] intValue]/100.0;
    objc3.interval = [self remTime:k2];
    [tmpArray addObject:objc3];
    
    ContrastData *objc5 = [[ContrastData alloc] init];
    objc5.actural = [NSString stringWithFormat:@"%@ %d%@",kJL_TXT("清醒次数"),awakeCount,kJL_TXT("次")];//@"清醒次数0次";
    objc5.reference = [NSString stringWithFormat:@"%@ %@%@",kJL_TXT("参考值"),@"0-2",kJL_TXT("次")];//@"参考值：0-2次";
    objc5.interval = [self awakeTime:awakeCount];
    [tmpArray addObject:objc5];
    
    ContrastData *objc6 = [[ContrastData alloc] init];
    objc6.actural = [NSString stringWithFormat:@"%@ %d",kJL_TXT("深睡连续性"),(int)deepSleepScre];//@"深睡连续性";
    objc6.reference = [NSString stringWithFormat:@"%@ 80~100",kJL_TXT("参考值")];
    objc6.interval = [self deepSleepScre:deepSleepScre];
    [tmpArray addObject:objc6];
    
    return tmpArray;
}

+(NSArray *_Nonnull)makeTestData2:(int) sleepHour WithMin:(int ) sleepMin WithDeepPercentage:(NSString* _Nonnull)deep WithShallowPercentage:(NSString * _Nonnull)shallow WithRem:(NSString* _Nonnull)rem DeepSleepScre:(NSInteger)deepSleepScre WithWakeCount:(int)awakeCount{
    NSMutableArray *tmpArray = [NSMutableArray new];
    ContrastData *objc = [[ContrastData alloc] init];
    objc.actural = [NSString stringWithFormat:@"%@ %d%@%d%@",kJL_TXT("平均夜间睡眠时间"),sleepHour,kJL_TXT("小时"),sleepMin,kJL_TXT("分钟")];//@"夜间睡眠时间6小时39分钟";
    objc.reference = [NSString stringWithFormat:@"%@ %@%@",kJL_TXT("参考值"),@"6-10",kJL_TXT("小时")];//@"参考值：6-10小时";
    objc.interval = [self allTime:sleepHour];
    [tmpArray addObject:objc];
    
    ContrastData *objc1 = [[ContrastData alloc] init];
    objc1.actural = [NSString stringWithFormat:@"%@ %@",kJL_TXT("平均深睡比例"),deep];//@"深睡比例27%";
    objc1.reference = [NSString stringWithFormat:@"%@ %@",kJL_TXT("参考值"),@"20-60%"];//@"参考值：20-60%";
    double k = (double)[[deep stringByReplacingOccurrencesOfString:@"%" withString:@""] intValue]/100.0;
    objc1.interval = [self deepTime:k];
    [tmpArray addObject:objc1];
    
    ContrastData *objc2 = [[ContrastData alloc] init];
    objc2.actural = [NSString stringWithFormat:@"%@ %@",kJL_TXT("平均浅睡比例"),shallow];//@"浅睡比例60%";
    objc2.reference = [NSString stringWithFormat:@"%@ %@",kJL_TXT("参考值"),@"<55%"];//@"参考值：<55%";
    double k1 = (double)[[shallow stringByReplacingOccurrencesOfString:@"%" withString:@""] intValue]/100.0;
    objc2.interval = [self shallowTime:k1];
    [tmpArray addObject:objc2];
    
    ContrastData *objc3 = [[ContrastData alloc] init];
    objc3.actural = [NSString stringWithFormat:@"%@ %@",kJL_TXT("平均快速眼动比例"),rem];//@"快速眼动比例13%";
    objc3.reference = [NSString stringWithFormat:@"%@ %@",kJL_TXT("参考值"),@"10-30%"];//@"参考值：10-30%";
    double k2 = (double)[[rem stringByReplacingOccurrencesOfString:@"%" withString:@""] intValue]/100.0;
    objc3.interval = [self remTime:k2];
    [tmpArray addObject:objc3];
    
    ContrastData *objc5 = [[ContrastData alloc] init];
    objc5.actural = [NSString stringWithFormat:@"%@ %d%@",kJL_TXT("平均清醒次数"),awakeCount,kJL_TXT("次")];//@"清醒次数0次";
    objc5.reference = [NSString stringWithFormat:@"%@ %@%@",kJL_TXT("参考值"),@"0-2",kJL_TXT("次")];//@"参考值：0-2次";
    objc5.interval = [self awakeTime:awakeCount];
    [tmpArray addObject:objc5];
    
    ContrastData *objc6 = [[ContrastData alloc] init];
    objc6.actural = [NSString stringWithFormat:@"%@ %d",kJL_TXT("深睡连续性"),(int)deepSleepScre];//@"深睡连续性";
    objc6.reference = [NSString stringWithFormat:@"%@ 80~100",kJL_TXT("参考值")];
    objc6.interval = [self deepSleepScre:deepSleepScre];
    [tmpArray addObject:objc6];
    return tmpArray;
}

+(SleepData_Interval)allTime:(NSInteger)length{
    if (length>10) {
        return SleepData_Hight;
    }else if (length<6){
        return SleepData_Low;
    }else{
        return SleepData_Normal;
    }
}

+(SleepData_Interval)deepTime:(double)length{
    if (length>0.6) {
        return SleepData_Hight;
    }else if (length<0.2){
        return SleepData_Low;
    }else{
        return SleepData_Normal;
    }
}

+(SleepData_Interval)shallowTime:(double)length{
    if (length>0.55) {
        return SleepData_Hight;
    }else if (length<0.01){
        return SleepData_Low;
    }else{
        return SleepData_Normal;
    }
}

+(SleepData_Interval)remTime:(double)length{
    if (length>0.3) {
        return SleepData_Hight;
    }else if (length<0.1){
        return SleepData_Low;
    }else{
        return SleepData_Normal;
    }
}
+(SleepData_Interval)awakeTime:(NSInteger)length{
    if (length>2) {
        return SleepData_Hight;
    }else{
        return SleepData_Normal;
    }
}

+(SleepData_Interval)deepSleepScre:(NSInteger)scre{
    if (scre < 80) {
        return SleepData_Low;
    }else{
        return SleepData_Normal;
    }
}


@end
