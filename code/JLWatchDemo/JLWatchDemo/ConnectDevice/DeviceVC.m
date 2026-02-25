//
//  DeviceVC.m
//  JLWatchDemo
//
//  Created by 杰理科技 on 2022/3/5.
//

#import "DeviceVC.h"
#import "JLHeadFile.h"
#import "TipView.h"

@interface DeviceVC ()<UITableViewDelegate,
                       UITableViewDataSource>
{
    __weak IBOutlet NSLayoutConstraint *H_TitleLb;
    __weak IBOutlet UITableView *subTableView;
    NSMutableArray  *bt_EntityList;
    JL_RunSDK       *bt_sdk;
    QCY_BLEApple    *bt_ble;
    JL_ManagerM     *mCmdManager;
}

@end

@implementation DeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bt_sdk = [JL_RunSDK sharedMe];
    bt_ble = bt_sdk.bt_ble;
    
    mCmdManager = bt_ble.mAssist.mCmdManager;
    
    [self setupUI];
    [self addNote];
}

-(void)setupUI{
    subTableView.tableFooterView = [UIView new];
    subTableView.dataSource = self;
    subTableView.delegate   = self;
    subTableView.rowHeight  = 50.0;
}


- (IBAction)refrash_btn:(id)sender {
    if (!_bt_status_phone) {
        [DFUITools showText:@"蓝牙没有打开" onView:self.view delay:1.0];
        return;
    }
    /*--- 提示【搜索设备...】 ---*/
    [TipView startLoadingView:@"搜索设备" Delay:2.0];
    /*--- 搜索蓝牙设备 ---*/
    [bt_ble startScanBLE];

    [DFAction delay:2.0 Task:^{
        [self->bt_ble stopScanBLE];
    }];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return bt_EntityList.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *IDCell = @"BTCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDCell];
    }
    cell.imageView.image = [UIImage imageNamed:@"ic_bluetooth"];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.backgroundColor = [UIColor whiteColor];
    
    QCY_Entity *entity = bt_EntityList[indexPath.row];
    CBPeripheral *item = entity.mPeripheral;
    cell.textLabel.text= entity.mName;
    
    if (item.state == CBPeripheralStateConnected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_bt_status_phone) {
        [DFUITools showText:@"蓝牙没有打开" onView:self.view delay:1.0];
        return;
    }
    if (bt_EntityList.count == 0) return;
    QCY_Entity *entity = bt_EntityList[indexPath.row];
    CBPeripheral *item = entity.mPeripheral;
    
    if (item.state == CBPeripheralStateDisconnected) {
        [bt_ble disconnectBLE];
        
        NSLog(@"蓝牙正在连接... ==> %@",entity.mName);
        [TipView startLoadingView:@"连接中..." Delay:5.0];
        [bt_ble connectBLE:item];
    }else{
        NSString *txt = [NSString stringWithFormat:@"你是否要断开设备【%@】？",item.name];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:txt
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"断开" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action)
        {
            [self->bt_ble disconnectBLE];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


-(void)allNoteListen:(NSNotification*)note{
    NSString *name = note.name;
        
    if ([name isEqual:kQCY_BLE_FOUND])
    {
        NSMutableArray *mArr = [NSMutableArray new];
        NSMutableArray *peripherals = [note object];
        
        for (NSDictionary *dic in peripherals)
        {
            CBPeripheral *item = dic[@"BLE"];
            NSNumber     *rssi = dic[@"RSSI"];
            NSString     *name = dic[@"NAME"];
            
            if ([rssi intValue] <= 0) {
                QCY_Entity *entity = [QCY_Entity new];
                entity.mRSSI       = rssi;
                entity.mPeripheral = item;
                entity.mName       = name;
                [mArr addObject:entity];
            }
        }
        
        /*--- 按信号强度排序 ---*/
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"mRSSI" ascending:NO];
        [mArr sortUsingDescriptors:@[sd]];
        bt_EntityList = [NSMutableArray arrayWithArray:mArr];
        
        [subTableView reloadData];
    }
    
    if ([name isEqual:kQCY_BLE_CONNECTED]) {
        _bt_status_phone   = YES;
        _bt_status_connect = YES;
        [subTableView reloadData];
    }
    
    if ([name isEqual:kQCY_BLE_PAIRED])
    {
        [TipView startLoadingView:@"连接成功." Delay:1.0];
        
        CBPeripheral *pl = [note object];

        _bt_status_phone   = YES;
        _bt_status_connect = YES;

        NSLog(@"BLE Paired ---> %@ UUID:%@",pl.name,pl.identifier.UUIDString);
        [subTableView reloadData];
        [TipView removeLoading];
        
        [JL_Tools delay:0.5 Task:^{
            [self getInfo];
        }];
    }
    
    if ([name isEqual:kQCY_BLE_DISCONNECTED]){
        _bt_status_connect = NO;
        [subTableView reloadData];
    }
    
    if ([name isEqual:kQCY_BLE_OFF]) {
        _bt_status_phone   = NO;
        _bt_status_connect = NO;
        
        [bt_EntityList removeAllObjects];
        [subTableView reloadData];
    }
    
    if ([name isEqual:kQCY_BLE_ON]) {
        _bt_status_phone = YES;
    }
}

-(void)addNote{
    [DFNotice add:nil Action:@selector(allNoteListen:) Own:self];
}

-(void)getInfo{
    [mCmdManager cmdTargetFeatureResult:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
        
        JLModel_Device *model = [self->mCmdManager outputDeviceModel];
        
        if (status == JL_CMDStatusSuccess) {
            JL_OtaStatus upSt = model.otaStatus;
            if (upSt == JL_OtaStatusForce) {
                NSLog(@"---> 进入强制升级.");
                [DFUITools showText:@"需要强制升级！" onView:self.view delay:1.0];
                [JL_Tools post:@"kJL_OTA_CONNECT" Object:nil];

                return;
            }else{
                if (model.otaHeadset == JL_OtaHeadsetYES) {
                    NSLog(@"---> 进入强制升级: OTA另一只耳机.");
                    [DFUITools showText:@"需要强制升级！" onView:self.view delay:1.0];
                    [JL_Tools post:@"kJL_OTA_CONNECT" Object:nil];
                    return;
                }
            }
            NSLog(@"---> 设备正常使用...");
            [JL_Tools mainTask:^{
                [DFUITools showText:@"设备正常使用" onView:self.view delay:1.0];
                
                /*--- 获取公共信息 ---*/
                [self->mCmdManager cmdGetSystemInfo:JL_FunctionCodeCOMMON Result:nil];
            }];
        }else{
            NSLog(@"---> ERROR：设备信息获取错误!");
        }
    }];
}


@end
