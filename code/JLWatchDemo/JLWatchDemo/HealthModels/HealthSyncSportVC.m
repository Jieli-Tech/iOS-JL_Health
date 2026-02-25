//
//  HealthSyncSportVC.m
//  JLWatchDemo
//
//  Created by EzioChan on 2022/4/14.
//


/**
 运动强度状态
 
 运动强度状态表还根据心率模式的不同而有所变化
 
 * 0 - 最大心率模式
 
 | 类型 | 名称     | 占比时长(单位：秒) |
 | ---- | -------- | ------------------ |
 | 0    | 非运动   | 不占时间           |
 | 1    | 热身     | 4 Bytes            |
 | 2    | 燃脂     | 4 Bytes            |
 | 3    | 有氧耐力 | 4 Bytes            |
 | 4    | 无氧耐力 | 4 Bytes            |
 | 5    | 极限     | 4 Bytes            |
 
 * 1 - 储备心率模式
 
 | 类型 | 名称     | 占比时间(单位：秒) |
 | ---- | -------- | ------------------ |
 | 0    | 非运动   | 不占时间           |
 | 1    | 有氧基础 | 4 Bytes            |
 | 2    | 有氧进阶 | 4 Bytes            |
 | 3    | 乳酸阈值 | 4 Bytes            |
 | 4    | 无氧基础 | 4 Bytes            |
 | 5    | 无氧进阶 | 4 Bytes            |

 时间结构包的解析
 | 意义        | 年            | 月       | 日             | 时       | 分         | 秒        |
 | ----------- | ------------- | -------- | -------------- | -------- | ---------- | --------- |
 | 位置        | Bit31-26      | Bit25-22 | &nbsp;Bit21-17 | Bit16-12 | Bit11-Bit6 | Bit5-Bit0 |
 | 长度（bit） | 6             | 4        | 5              | 5        | 6          | 6         |
 | 备注        | 起始时间:2010 | yu       |                |          |            |           |
 
 举例：
 2021-08-02 10:10:10
 2E04A28A
 00 1011   1000  00010     01010    001010    001010
     年      月        天             时        分            秒
 */

#import "HealthSyncSportVC.h"

@interface HealthSyncSportVC ()<UITableViewDelegate,UITableViewDataSource,JLWearSyncCustomPtl>

@property (weak, nonatomic) IBOutlet UITableView *syncTable;
@property(nonatomic,strong)JLWearSyncCustom *syncCustom;
@property(nonatomic,strong)NSArray *itemArray;
@end

@implementation HealthSyncSportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.itemArray = @[@"读取信息",@"开始运动",@"停止运动",@"暂停运动",@"继续运动",@"读取运动实时内容"];
    
    self.syncTable.delegate = self;
    self.syncTable.dataSource = self;
    self.syncTable.rowHeight = 40;
    self.syncTable.tableFooterView = [UITableView new];
    
    self.syncCustom = [[JLWearSyncCustom alloc] init];
    self.syncCustom.delegate = self;
    
    
}
- (IBAction)backBtnAction:(id)sender {
    
    [self dismissViewControllerAnimated:true completion:nil];
    
}

//MARK: - tableview Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"syncCellid";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    cell.textLabel.text = self.itemArray[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    switch (indexPath.row) {
        case 0:{
            [self.syncCustom w_requireSportInfoWith:self.manager.mEntity Block:^(JLWearSyncDataModel *infoModel) {
               //JLWearSyncDataModel 是父类，当使用的数据定义是属于自定义时，需要自行进行解析
                //此外还可以通过代理的方法进行监听该内容
                //这里默认的跑步时数据结构如下：
                /**
                 Byte0:运动模式：
                 Byte1:运动状态:0x00:暂停，0x01：运动中
                 Byte2-5:运动Id（用开始时间代替）
                 Byte:6:是否需要APP记录GPS
                 Byte7:0x00:最大心率模式，0x01：存储心率模式
                 Byte8-Byte9:建议实时数据读取时间间隔，单位：ms
                 */
                JLWearSyncInfoModel *model = [JLWearSyncInfoModel initWithData:infoModel.basicData];
                NSLog(@"JLWearSyncInfoModel:%@",model);
                //TODO: to do...
            
            }];
        }break;
        case 1:{
            
             /**
              这里所使用的运动类型是可以自定义也可以根据已有表填写
              已有表：
              非运动模式: 0x00
              室外跑步: 0x01
              室内跑步: 0x02
              */
            [self.syncCustom w_SportStart:0x00 With:self.manager.mEntity Block:^(BOOL succeed) {
                NSLog(@"回调开启运动是否成功");
                //TODO: to do...
            }];
            
        }break;
        case 2:{
            //手机端停止运动，该内容的回调通过代理
            [self.syncCustom w_SportFinishWith:self.manager.mEntity];
            
        }break;
            
        case 3:{
            [self.syncCustom w_SportPauseWith:self.manager.mEntity Block:^(BOOL succeed) {
               //TODO: to do...
                NSLog(@"回调暂停是否成功");
            }];
        }break;
        case 4:{
            [self.syncCustom w_SportContinueWith:self.manager.mEntity Block:^(BOOL succeed) {
                //TODO: to do...
                NSLog(@"回调继续运动是否成功");
            }];
            
        }break;
        case 5:{
            /**
             实时查询设备运动信息
             该内容只会通过代理回调
             */
            [self.syncCustom w_requireRealTimeSportInfoWith:self.manager.mEntity];
            
        }break;
            
        default:
            break;
    }
}

//MARK: - 运动信息代理回调

- (void)jlWearSyncRealTimeData:(JLWearSyncRealTimeData * _Nonnull)model With:(JL_EntityM * _Nonnull)entity {
    /**
     这里回调的model只是一个父类，其中只包含一个属性，就是裸数据的内容，需要根据实际情况进行解析
     下面是针对跑步默认的解析方案
     默认的方案数据结构如下：
     Byte0:类型，跑步类型=0
     Byte1-4:运动步数
     Byte5-6:运动距离，单位：0.01公里
     Byte7-10:运动时长：单位：秒
     Byte11-12：速度，单位0：0.01公里/小时，（倒数为配速，单位：秒/公里）
     Byte13-14:热量，单位：千卡
     Byte15-16:步频，单位：步/分钟
     Byte17-18:步幅,单位:厘米
     Byte19:实时运动强度状态:
     最大心率模式 = {0非运动、1热身、2燃脂、3有氧耐力、4无氧耐力、5极限}
     储备心率模式 = {0非运动、1有氧基础、2有氧进阶、3乳酸阈值、4无氧基础、5无氧进阶}
     Byte20:运动实时心率
     */
    JLWearSyncRealTimeModel *md = [JLWearSyncRealTimeModel initWithData:model.basicData];
    
    NSLog(@"实时运动代理回调:%@",md);
    
}

- (void)jlWearSyncSportInfo:(JLWearSyncDataModel * _Nonnull)model With:(JL_EntityM * _Nonnull)entity {
    //JLWearSyncDataModel 是父类，当使用的数据定义是属于自定义时，需要自行进行解析
     //此外还可以通过代理的方法进行监听该内容
     //这里默认的跑步时数据结构如下：
     /**
      Byte0:运动模式：
      Byte1:运动状态:0x00:暂停，0x01：运动中
      Byte2-5:运动Id（用开始时间代替）
      Byte:6:是否需要APP记录GPS
      Byte7:0x00:最大心率模式，0x01：存储心率模式
      Byte8-Byte9:建议实时数据读取时间间隔，单位：ms
      */
     JLWearSyncInfoModel *md = [JLWearSyncInfoModel initWithData:model.basicData];
     NSLog(@"读取运动信息代理回调:%@",md);
}

- (void)jlWearSyncStartMotionWith:(JL_EntityM * _Nonnull)entity {

    //WARNING: 设备有可能出现主动退送上来的情况
    NSLog(@"开始运动，代理回调");
    
}

- (void)jlWearSyncStatusContiuneWith:(JL_EntityM * _Nonnull)entity {
    
    //WARNING: 设备有可能出现主动退送上来的情况
    NSLog(@"继续运动，代理回调");
}

- (void)jlWearSyncStatusPauseWith:(JL_EntityM * _Nonnull)entity {
    
    //WARNING: 设备有可能出现主动退送上来的情况
    NSLog(@"暂停运动，代理回调");
}

- (void)jlWearSyncStopMotion:(JLWearSyncFinishDataModel * _Nonnull)model With:(JL_EntityM * _Nonnull)entity {
    /**
     这里回调的model是一个父类，当使用数据是自定义时，可进行自定义的解释
     下面是默认跑步结束时的内容回调，它的结构如下：
    
     Byte0-3:结束时间
     Byte4-7:运动恢复时间（Byte4-5:hour  Byte6-7:min）
     Byte8-9:运动记录id （需要通过小文件的方式进行文件下载）
     Byte10-11:运动记录文件大小
     Byte12-31:运动强度状态占比时长(4Byte一组，从非0模式开始)，单位：秒
     
     */
    JLWearSyncFinishModel *md = [JLWearSyncFinishModel initWithData:model.basicData];
    NSLog(@"结束运动时的内容：%@",md);
    //TODO: to do...
}


@end
