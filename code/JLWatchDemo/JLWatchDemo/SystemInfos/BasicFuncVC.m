//
//  BasicFuncVC.m
//  JLWatchDemo
//
//  Created by EzioChan on 2022/4/14.
//

#import "BasicFuncVC.h"

@interface BasicFuncVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *funcTable;
@property (nonatomic,strong) NSArray *funcArray;
@end

@implementation BasicFuncVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.funcArray = @[@"设置设备时间",@"获取设备电量",@"天气设置",@"自定义命令",@"获取设备日志"];
    self.funcTable.delegate = self;
    self.funcTable.dataSource = self;
    self.funcTable.tableFooterView = [UIView new];
    self.funcTable.rowHeight = 40;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerAction:) name:kJL_MANAGER_CUSTOM_DATA object:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.funcArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    cell.textLabel.text = self.funcArray[indexPath.row];
    return  cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    switch (indexPath.row) {
        case 0:{
            NSLog(@"--->(2) SET Device time.");
            NSDate *date = [NSDate new];
            JL_SystemTime *systemTime = self.manager.mSystemTime;
            [systemTime cmdSetSystemTime:date];
            NSDateFormatter *dtfm = [[NSDateFormatter alloc] init];
            dtfm.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *str = [NSString stringWithFormat:@"已设置系统时间为：%@",[dtfm stringFromDate:date]];
            [DFUITools showText:str onView:self.view delay:2];
        }break;
        case 1:{
            [self.manager cmdGetSystemInfo:JL_FunctionCodeCOMMON SelectionBit:0x0001 Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                if (status == JL_CMDStatusSuccess) {
                    //电量
        //            int battery = (int)[JL_Tools dataToInt:data];
                    int battery = (int)self.manager.outputDeviceModel.battery;
                    NSString *str = [NSString stringWithFormat:@"电量:%d",battery];
                    [DFUITools showText:str onView:self.view delay:2];
                }
            }];
        }break;
        case 2:{
            JL_MSG_Weather *weather = [[JL_MSG_Weather alloc] init];
            weather.date = [NSDate date];
            weather.code = JLWeatherTypeHaze;
            weather.direction = JLWindDirectionTypeEast;
            weather.temperature = 20;
            weather.humidity = 65;
            weather.city = @"上海";
            weather.province = @"直辖市";
            [[JLWearable sharedInstance] w_syncWeather:weather withEntity:self.manager.mEntity result:^(BOOL succeed) {
                [DFUITools showText:@"天气已设置" onView:self.view delay:2];
            }];
        }break;
        case 3:{
            uint8_t data0[] = {0x00,0x01,0x02};
            NSData *data = [NSData dataWithBytes:data0 length:3];
            [self.manager.mCustomManager cmdCustomData:data Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                NSLog(@"custom recive data:%@",data);
            }];
        }break;
        case 4:{
            JLModel_Device *model = [self.manager outputDeviceModel];
            //判断是否支持日志获取
            if (model.isSupportLog) {
                
                //获取设备日志
                [self.manager.mDeviceLogs deviceLogDownload:^(DeviceLogType type, float progress, NSString * _Nullable tempSavePath) {
                    switch (type) {
                        case LogTypeDownloading:{
                            NSLog(@"progress:%.2f",progress);
                        }break;
                        case LogTypeSucceed:{
                            NSLog(@"device log get success! filePath:%@",tempSavePath);
                        }break;
                        case LogTypeFailed:{
                            NSLog(@"device log get falied! ");
                        }break;
                        case LogTypeNoLog:{
                            NSLog(@"device log not exit!");
                        }break;
                        default:
                            break;
                    }
                }];
            }else{
                NSLog(@"device is not support log download");
            }
        }
        default:
            break;
    }
}


- (IBAction)backBtnAction:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}



-(void)customerAction:(NSNotification *)note{
    NSLog(@"收到设备主动推送的信息：%@",note);
}


@end
