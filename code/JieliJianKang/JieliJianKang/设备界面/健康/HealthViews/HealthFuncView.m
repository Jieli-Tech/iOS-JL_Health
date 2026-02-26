//
//  HealthFuncView.m
//  JieliJianKang
//
//  Created by EzioChan on 2022/11/2.
//

#import "HealthFuncView.h"
#import "HealthFuncCell.h"

#import "HealthXinLvVC.h"
#import "HealthYaLiVC.h"
#import "HealthYunDongVC.h"
#import "DevicePersonInfoVC.h"
#import "SleepDetectionVC.h"
#import "JiuZuoVC.h"
#import "DieDaoVC.h"

@interface HealthFuncView()<UITableViewDelegate,UITableViewDataSource,JL_WatchProtocol>{
    UITableView *funcTable;
    NSMutableArray *itemArrays;
    NSMutableDictionary *statusDict;
    int mMaxRate;
}
@end

@implementation HealthFuncView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        statusDict = [NSMutableDictionary new];
        mMaxRate = 120;
        [self initData];
        [self initUI];
        [self addWatchObjc];
    }
    return self;
}

-(void)addWatchObjc{
    JLWearable *w = [JLWearable sharedInstance];
    [w w_addDelegate:self];
}




-(void)initData{
    itemArrays = [NSMutableArray new];
    JLDeviceConfigModel *model = [[JLDeviceConfig share] deviceGetConfigWithUUID:kJL_BLE_EntityM.mPeripheral.identifier.UUIDString];
    ///支持个人信息
    if(model.healthFunc.spComprehensive.spPersonInfo){
        HealthCellObj *objc = [HealthCellObj initBasic:kJL_TXT("个人信息") Sec:@""];
        DevicePersonInfoVC *vc = [[DevicePersonInfoVC alloc] init];
        objc.vc = vc;
        NSArray *array = @[objc];
        [itemArrays addObject:array];
    }
    
    NSMutableArray *funcArray = [NSMutableArray new];
    //检测睡眠检测
    if(model.healthFunc.spComprehensive.spSleepMonitor){
        HealthCellObj *objc = [HealthCellObj initBasic:kJL_TXT("睡眠检测") Sec:@""];
        SleepDetectionVC *vc = [[SleepDetectionVC alloc] init];
        objc.vc = vc;
        [funcArray addObject:objc];
    }
    //久坐提醒
    if(model.healthFunc.spComprehensive.spSedentaryRemind){
        HealthCellObj *objc = [HealthCellObj initBasic:kJL_TXT("久坐提醒") Sec:kJL_TXT("久坐超过一小时提醒")];
        JiuZuoVC *vc = [[JiuZuoVC alloc] init];
        objc.vc = vc;
        [funcArray addObject:objc];
    }
    
    if(model.healthFunc.spHeartRate.spSerialTest){
        HealthCellObj *objc = [HealthCellObj initBasic:kJL_TXT("连续测量心率") Sec:@""];
        HealthXinLvVC *vc = [[HealthXinLvVC alloc] init];
        objc.vc = vc;
        [funcArray addObject:objc];
    }
    
    //运动心率提醒
    if(model.healthFunc.spComprehensive.spSportHeartRateRemind){
        NSMutableAttributedString * tempString;
        NSString *labelSportText;
        NSString *maxRateStr = [[NSString alloc] initWithFormat:@"%d",mMaxRate];
        labelSportText =   [NSString stringWithFormat:@"%@ %d %@", kJL_TXT("心率高于"),mMaxRate,kJL_TXT("次/分钟时提醒")];
        NSDictionary *dict = [self titleTextAttributesWithTitleColor:kDF_RGBA(128, 91, 235, 1.0) WithTiteleFont:[UIFont fontWithName:@"PingFang SC" size: 12]];
        tempString = [[NSMutableAttributedString alloc] initWithString: labelSportText];
        NSRange range = [labelSportText rangeOfString:maxRateStr];
        [tempString addAttributes:dict range:range];
        
        //labelSport.attributedText = tempString;
        HealthCellObj *objc = [HealthCellObj initBasic:kJL_TXT("运动心率提醒") Sec:labelSportText];
        objc.secStrAttr = tempString;
        HealthYunDongVC *vc = [[HealthYunDongVC alloc] init];
        objc.vc = vc;
        [funcArray addObject:objc];
    }
    //压力自动检测
    if(model.healthFunc.spComprehensive.spStressDetection){
        HealthCellObj *objc = [HealthCellObj initBasic:kJL_TXT("压力自动检测") Sec:@""];
        HealthYaLiVC *vc = [[HealthYaLiVC alloc] init];
        objc.vc = vc;
        [funcArray addObject:objc];
    }
    
    //跌倒检测
    if(model.healthFunc.spComprehensive.spFallDetection){
        HealthCellObj *objc = [HealthCellObj initBasic:kJL_TXT("跌倒检测") Sec:@""];
        DieDaoVC *vc = [[DieDaoVC alloc] init];
        objc.vc = vc;
        [funcArray addObject:objc];
    }
    
    [itemArrays addObject:funcArray];
    
}

-(void)initUI{
    self.backgroundColor = [JLColor colorWithString:@"#F6F7F8"];
    funcTable = [UITableView new];
    funcTable.delegate = self;
    funcTable.dataSource = self;
    funcTable.rowHeight = 62;
    funcTable.backgroundColor = [UIColor clearColor];
    funcTable.tableFooterView = [UIView new];
    funcTable.separatorColor = [JLColor colorWithString:@"#F7F7F7"];
    funcTable.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    [funcTable registerClass:[HealthFuncCell class] forCellReuseIdentifier:@"healthCell"];
    [self addSubview:funcTable];
    [funcTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return itemArrays.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = itemArrays[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HealthFuncCell *cell = [HealthFuncCell cellWithTable:tableView];
    HealthCellObj *item = itemArrays[indexPath.section][indexPath.row];
    cell.mainLab.text = item.mainStr;
    [cell weatherHaveDetail:item.supportSec];
    cell.rightLab.text = [statusDict objectForKey:item.mainStr];
    cell.secLab.text = item.secStr;
    if([item.mainStr isEqualToString:kJL_TXT("运动心率提醒")]){
        cell.secLab.attributedText = item.secStrAttr;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    HealthCellObj *item = itemArrays[indexPath.section][indexPath.row];
    [JLApplicationDelegate.navigationController pushViewController:item.vc animated:YES];
}




#pragma mark 久坐提醒
-(void)jlWatchSetSedentaryRmd:(JLSedentaryRmdModel *)model{
    if(model.status){
        [statusDict setValue:kJL_TXT("已开启") forKey:kJL_TXT("久坐提醒")];
    }else{
        [statusDict setValue:kJL_TXT("已关闭") forKey:kJL_TXT("久坐提醒")];
    }
    [funcTable reloadData];
}

#pragma mark 心率测量功能
-(void)jlWatchSetConsequentHeartRate:(JLConsequentHeartRateModel *)model{
    if(model.status){
        [statusDict setValue:kJL_TXT("已开启") forKey:kJL_TXT("连续测量心率")];
    }else{
        [statusDict setValue:kJL_TXT("已关闭") forKey:kJL_TXT("连续测量心率")];
    }
    [funcTable reloadData];
}

#pragma mark自动压力测试
-(void)jlWatchSetAutoPressure:(JLAutoPressureModel *)model{
    if(model.status){
        [statusDict setValue:kJL_TXT("已开启") forKey:kJL_TXT("压力自动检测")];
    }else{
        [statusDict setValue:kJL_TXT("已关闭") forKey:kJL_TXT("压力自动检测")];
    }
    [funcTable reloadData];
}

#pragma mark 睡眠监测
-(void)jlWatchSetSleepMonitor:(JLSleepMonitorModel *)model{
    if(model.status == WatchSwitchType_Close){
        [statusDict setValue:kJL_TXT("已关闭") forKey:kJL_TXT("睡眠检测")];
    }
    if(model.status == WatchSwitchType_AllDay){
        [statusDict setValue:kJL_TXT("全天开启") forKey:kJL_TXT("睡眠检测")];
    }
    if(model.status == WatchSwitchType_Customer){
        [statusDict setValue:kJL_TXT("定时开启") forKey:kJL_TXT("睡眠检测")];
    }
    [funcTable reloadData];
}

#pragma mark 跌倒检测
-(void)jlWatchSetFallDetectionModel:(JLFallDetectionModel *)model{
    if(model.status){
        [statusDict setValue:kJL_TXT("已开启") forKey:kJL_TXT("跌倒检测")];
    }else{
        [statusDict setValue:kJL_TXT("已关闭") forKey:kJL_TXT("跌倒检测")];
    }
    [funcTable reloadData];
}

#pragma mark 运动心率测试功能
-(void)jlWatchSetExerciseHeartRateRemind:(JLExerciseHeartRateRemindModel *)model{
    
    if(model.status){
        [statusDict setValue:kJL_TXT("已开启") forKey:kJL_TXT("运动心率提醒")];
    }else{
        [statusDict setValue:kJL_TXT("已关闭") forKey:kJL_TXT("运动心率提醒")];
    }
    
    if(model.maxRate !=0){
       mMaxRate = model.maxRate;
    }
    [self initData];
    [funcTable reloadData];
}


- (NSMutableDictionary *)titleTextAttributesWithTitleColor:(UIColor *)titleColor WithTiteleFont:(UIFont *)titleFont{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = titleColor;
    dict[NSFontAttributeName] = titleFont;
    return dict;
}




@end
