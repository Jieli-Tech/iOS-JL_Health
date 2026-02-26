//
//  DeviceDetailViewController.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/26.
//

#import "DeviceDetailViewController.h"
#import "UserDeviceModel.h"
#import "DeviceHttp.h"
#import "DeviceHttpModel.h"
#import "JLDeviceSqliteManager.h"

static NSInteger TimeOut = 10;
@interface DeviceDetailViewController (){
    NSTimer *connectTimer;
    NSInteger timerCount;
    DFTips *tipsView;
}
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIButton *reConnectBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headHeight;

@end

@implementation DeviceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNote];

    _headHeight.constant = kJL_HeightNavBar;
    self.titleLab.text = self.mainModel.devName;
    _reConnectBtn.layer.cornerRadius = 24;
    _reConnectBtn.layer.masksToBounds = true;
    _deleteBtn.layer.cornerRadius = 24;
    _deleteBtn.layer.masksToBounds = true;
    [_deleteBtn setTitle:kJL_TXT("删除设备") forState:UIControlStateNormal];
    [_reConnectBtn setTitle:kJL_TXT("重新连接") forState:UIControlStateNormal];
    JL_BLEMultiple *mtpl = [[JL_RunSDK sharedMe] mBleMultiple];
    BOOL t = [[mtpl connectingEntity].mPeripheral.identifier.UUIDString isEqualToString:self.mainModel.uuidStr];
    if ([[JL_RunSDK getLinkedArray] containsObject:self.mainModel.uuidStr] || (mtpl.BLE_IS_CONNECTING == YES && t == YES)) {
        [_reConnectBtn setTitle:kJL_TXT("断开连接") forState:UIControlStateNormal];
        self.reConnectBtn.hidden = true;
    }
    tipsView = [DFUITools showHUDOnWindowWithLabel:kJL_TXT("正在连接")];
    [tipsView hide:false];
    
    NSString *string = [[AutoProductIcon share] checkImgUrl:_mainModel.vid :_mainModel.pid];
    [_bgImageView sd_setImageWithURL:[NSURL URLWithString:string] placeholderImage:[UIImage imageNamed:@"img_watch_128_2"]];
}





- (IBAction)backBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)reConnectBtnAction:(id)sender {

    if (kJL_BLE_Multiple.bleManagerState == CBManagerStatePoweredOff) {
        [DFUITools showText:kJL_TXT("蓝牙没有打开") onView:self.view delay:1.0];
        return;
    }
    
    if ([[JL_RunSDK getLinkedArray] containsObject:self.mainModel.uuidStr]) {
        
        [kJL_BLE_Multiple disconnectEntity:kJL_BLE_EntityM Result:^(JL_EntityM_Status status) {
            NSLog(@"%s:status:%ld",__func__,(long)status);
            if (status == JL_EntityM_StatusDisconnectOk) {
                [DFUITools showText:kJL_TXT("连接已断开") onView:self.view delay:1.5];
                [DFAction delay:1.5 Task:^{
                    [self.navigationController popViewControllerAnimated:true];
                }];
            }
        }];
    }else{
        
        JL_EntityM * cutEntity = [kJL_BLE_Multiple makeEntityWithUUID:self.mainModel.uuidStr];
        [self connectWithEntity:cutEntity];
        /*--- 判断经典蓝牙是否连接 ---*/
//        if ([JL_RunSDK isConnectEdr:self.mainModel.mac]) {
//            [self connectWithEntity:cutEntity];
//        }else{
//            uint8_t *version = (uint8_t *)[[cutEntity.mAdvData subdataWithRange:NSMakeRange(6, 1)] bytes];
//            if (version == NULL) {
//                [JL_Tools post:kUI_SHOW_EDR_VIEW Object:nil];
//                return;
//            }
//            if((version[0]&0x0F) == 0x00){
//                [JL_Tools post:kUI_SHOW_EDR_VIEW Object:nil];
//            }else{
//                [self connectWithEntity:cutEntity];
//            }
//        }
    }
}

-(void)connectWithEntity:(JL_EntityM *)cutEntity{
    /*--- 1、直接UUID连接设备 ---*/
    tipsView.labelText = kJL_TXT("正在连接");
    [tipsView show:true];

    //[[JL_RunSDK sharedMe] setAncsUUID:cutEntity.mPeripheral.identifier.UUIDString];
    [kJL_BLE_Multiple connectEntity:cutEntity Result:^(JL_EntityM_Status status) {
        [JL_Tools mainTask:^{
            if (status == JL_EntityM_StatusPaired) {
                NSLog(@"----> UUID回连设备成功.");
                self->tipsView.labelText = kJL_TXT("连接成功");
                [JL_Tools delay:2.0 Task:^{
                    [self->tipsView hide:true];
                    [self.navigationController popViewControllerAnimated:true];
                }];
            }else{
                /*--- 2、UUID连接失败，用BLE搜索连接方式 ---*/
                NSLog(@"----> 正在搜索BLE回连...1");
                [self searchConnect];
            }
        }];
    }];
}




- (IBAction)deleteBtnAction:(id)sender {

    NSString *message = [NSString stringWithFormat:@"%@“%@”%@",kJL_TXT("请前往设置蓝牙"),self.mainModel.devName,kJL_TXT("忽略此设备")];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:kJL_TXT("是否解除此设备") message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kJL_TXT("取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:kJL_TXT("确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [JL_Tools post:kUI_DELETE_DEVICE_MODEL Object:self.mainModel.mac];

        if ([kJL_BLE_EntityM.mEdr isEqualToString:self.mainModel.mac]) {
            //NSLog(@"unbindId：%@",self.mainModel.deviceID);
            [DeviceHttp unBinding:self.mainModel.deviceID result:^(JLHttpResponse *response) {
                if (response.code == 0) {
                   
                }else{
                    NSLog(@"删除设备失败：%@",response.msg);
//                    [DFUITools showText:response.msg onView:self.view delay:2];
                }
            }];
            [[AutoProductIcon share] saveToLocal:self.mainModel.vid :self.mainModel.pid :nil];
            [[JLDeviceSqliteManager share] deleteBy:self.mainModel];
            [kJL_BLE_Multiple disconnectEntity:kJL_BLE_EntityM Result:^(JL_EntityM_Status status) {
                if (status == JL_EntityM_StatusDisconnectOk) {
                    [self.navigationController popViewControllerAnimated:true];
                }
            }];
            
        }else{
            [DeviceHttp unBinding:self.mainModel.deviceID result:^(JLHttpResponse *response) {
                if (response.code == 0) {
                }else{
                    NSLog(@"删除设备失败：%@",response.msg);
//                    [DFUITools showText:response.msg onView:self.view delay:2];
                }
            }];
            [[JLDeviceSqliteManager share] deleteBy:self.mainModel];
            [[AutoProductIcon share] saveToLocal:self.mainModel.vid :self.mainModel.pid :nil];
            [self.navigationController popViewControllerAnimated:true];
        }
    }];
    
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)timerAction{
    timerCount+=1;
    if (timerCount>TimeOut) {
        tipsView.labelText = kJL_TXT("连接超时");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self cancelSearch];
        });
    }
}
-(void)searchConnect{
    timerCount = 0;
    tipsView.labelText = kJL_TXT("正在连接");
    [tipsView show:true];
    connectTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:true];
    [connectTimer fire];
    [JL_Tools post:kUI_JL_BLE_SCAN_OPEN Object:nil];

}

-(void)cancelSearch{
    [tipsView hide:true];
    [connectTimer invalidate];
    [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];

    [self removeNote];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [[note object] intValue];
    if (tp == JLDeviceChangeTypeBleOFF ||
        tp == JLDeviceChangeTypeInUseOffline) {
        [self.navigationController popViewControllerAnimated:true];
    }
}

-(void)addNote{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchEntity:) name:kJL_BLE_M_FOUND_SINGLE object:nil];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)removeNote{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJL_BLE_M_FOUND_SINGLE object:nil];
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

-(void)dealloc{
    [self removeNote];
}

-(void)searchEntity:(NSNotification *)note{
    JL_EntityM *entity = note.object;
    if ([entity.mEdr isEqualToString:self.mainModel.mac]) {
        [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];

        //[[JL_RunSDK sharedMe] setAncsUUID:entity.mPeripheral.identifier.UUIDString];
        [kJL_BLE_Multiple connectEntity:entity Result:^(JL_EntityM_Status status) {
            if (status == JL_EntityM_StatusPaired) {
                [self cancelSearch];
                [DFUITools showText:kJL_TXT("连接成功") onView:self.view delay:1.5];
                [DFAction delay:1.5 Task:^{
                    [self.navigationController popViewControllerAnimated:true];
                }];
            }
        }];
    }
}

@end
