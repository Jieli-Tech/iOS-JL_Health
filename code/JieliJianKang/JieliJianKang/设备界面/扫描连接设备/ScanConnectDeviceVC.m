//
//  ScanConnectDeviceVC.m
//  JieliJianKang
//
//  Created by 李放 on 2021/4/1.
//

#import "ScanConnectDeviceVC.h"

@interface ScanConnectDeviceVC (){
    float sw;
    float sh;
    
    __weak IBOutlet NSLayoutConstraint *titleView_H;
    
    __weak IBOutlet UILabel *titleText;
    __weak IBOutlet UILabel *label_0;
    __weak IBOutlet UILabel *label_1;
    __weak IBOutlet UILabel *label_2;
    __weak IBOutlet UIImageView *subImage_0;
    NSString *edrText;
    NSString *nameText;
    
}
@property (weak,nonatomic) NSMutableArray *foundArray;
@property (weak,nonatomic) JL_EntityM  *scanEntity;
@property (weak,nonatomic) JL_EntityM  *setEntity;

@end

@implementation ScanConnectDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.foundArray = kJL_BLE_Multiple.blePeripheralArr;
    [self addNote];
    [self initUI];
}

-(void)initUI{
    sw = [UIScreen mainScreen].bounds.size.width;
    sh = [UIScreen mainScreen].bounds.size.height;
    
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    titleView_H.constant = kJL_HeightNavBar;
    
    titleText.text = kJL_TXT("连接设备");
    label_0.font =  [UIFont fontWithName:@"PingFang SC" size: 20];
    label_0.text =  kJL_TXT("正在配对");
    label_1.font =  [UIFont fontWithName:@"PingFang SC" size: 16];
    label_1.text =  kJL_TXT("请在设备上进行配对确认");
    label_2.font =  [UIFont fontWithName:@"PingFang SC" size: 16];
    label_2.text =  [NSString stringWithFormat:@"%@%@",kJL_TXT("当前配对设备"),@"JieLi Watch"];
    subImage_0.image = [UIImage imageNamed:@"img_connect"];;
}

-(void)setScanDict:(NSDictionary*)dict{
    [JL_Tools delay:1.0 Task:^{
        self.mScanDict = dict;
        self->edrText    = dict[@"edrAddr"];
        self->nameText   = dict[@"name"];
        self->label_2.text= [NSString stringWithFormat:@"%@%@",kJL_TXT("当前配对设备"),self->nameText];
        [JL_Tools post:kUI_JL_BLE_SCAN_OPEN Object:nil];
    }];

}

//搜索edr连接
-(void)noteBleFoundDevice:(NSNotification*)note{
    
    JL_EntityM *mEntity = nil;
    for (JL_EntityM *entity in self.foundArray) {
        NSString *edr =  [[edrText lowercaseString] stringByReplacingOccurrencesOfString:@":" withString:@""];
        if ([entity.mEdr isEqual:edr]) {
            NSLog(@"QR Scan To ---> %@",entity.mItem);
            mEntity = entity;
            break;
        }
    }
    if (mEntity == nil) return;
    [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];
    
    
    /*--- 判断经典蓝牙是否连接 ---*/
    if ([JL_RunSDK isConnectEdr:mEntity.mEdr]) {
        self.scanEntity = mEntity;
        NSLog(@"QR Scan Conecting ---> %@",self.scanEntity.mItem);
        
        [kJL_BLE_Multiple connectEntity:self.scanEntity Result:^(JL_EntityM_Status status) {
            [JL_Tools mainTask:^{
                if (status == JL_EntityM_StatusPaired) {
                    [self showUIConnectOK];
                }else{
                    [self showUIConnectFail];
                }
                [JL_Tools delay:1.0 Task:^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [JLApplicationDelegate.tabBarController setSelectedIndex:2];
                }];
            }];
        }];
    }else{
        
        if (mEntity.mSpecialType == JLDevSpecialType_Reconnect) {
            if (mEntity.mProtocolType == 0) {
                [JL_Tools post:kUI_SHOW_EDR_VIEW Object:nil];
            }
            if (mEntity.mProtocolType == 1) {
                self.scanEntity = mEntity;
                NSLog(@"QR Scan Conecting ---> %@",self.scanEntity.mItem);
                
                [kJL_BLE_Multiple connectEntity:self.scanEntity Result:^(JL_EntityM_Status status) {
                    [JL_Tools mainTask:^{
                        if (status == JL_EntityM_StatusPaired) {
                            [self showUIConnectOK];
                        }else{
                            [self showUIConnectFail];
                        }
                        [JL_Tools delay:1.0 Task:^{
                            [self.navigationController popToRootViewControllerAnimated:YES];
                            [JLApplicationDelegate.tabBarController setSelectedIndex:2];
                        }];
                    }];
                }];
            }
        }else{
            /*--- 正常设备需要提示用户连接经典蓝牙 ---*/
            //            [JL_Tools post:kUI_SHOW_EDR_VIEW Object:nil];
            
            //            if(mEntity.mProtocolType == 0x00){
            //                [JL_Tools post:kUI_SHOW_EDR_VIEW Object:nil];
            //            }else {
            //if(mEntity.mProtocolType == 0x01)
            self.scanEntity = mEntity;
            NSLog(@"QR Scan Conecting ---> %@",self.scanEntity.mItem);
            
            [kJL_BLE_Multiple connectEntity:self.scanEntity Result:^(JL_EntityM_Status status) {
                [JL_Tools mainTask:^{
                    if (status == JL_EntityM_StatusPaired) {
                        [self showUIConnectOK];
                    }else{
                        [self showUIConnectFail];
                    }
                    [JL_Tools delay:1.0 Task:^{
                        [self.navigationController popToRootViewControllerAnimated:YES];
                        [JLApplicationDelegate.tabBarController setSelectedIndex:2];
                    }];
                }];
            }];
            //            }
        }
        
        [JL_Tools delay:1.5 Task:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
            [JLApplicationDelegate.tabBarController setSelectedIndex:2];
        }];
    }
}

//指定设备连接
-(void)setConnectDevice:(JL_EntityM*)entity{
    [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];
    
    [JL_Tools delay:1.0 Task:^{
        self.setEntity = entity;
        self->label_2.text= [NSString stringWithFormat:@"%@%@",kJL_TXT("当前配对设备"),self.setEntity.mItem];
        
        [kJL_BLE_Multiple connectEntity:self.setEntity Result:^(JL_EntityM_Status status) {
            [JL_Tools mainTask:^{
                if (status == JL_EntityM_StatusPaired) {
                    [self showUIConnectOK];
                }else{
                    [self showUIConnectFail];
                }
                [JL_Tools delay:1.0 Task:^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [JLApplicationDelegate.tabBarController setSelectedIndex:2];
                }];
            }];
        }];
    }];
}


-(void)showUIConnectOK{
    subImage_0.image = [UIImage imageNamed:@"img_connect_success"];
    label_0.text = kJL_TXT("设备配对成功");
    label_1.text =  @"";
}

-(void)showUIConnectFail{
    subImage_0.image = [UIImage imageNamed:@"img_connect_fair"];
    label_0.text = kJL_TXT("设备配对失败");
    label_1.text = kJL_TXT("请重新扫码连接或者手动添加设备");
}

- (IBAction)backBtn:(UIButton *)sender {
    JL_EntityM *cutEntity = nil;
    if (self.scanEntity) cutEntity = self.scanEntity;
    if (self.setEntity ) cutEntity = self.setEntity;
    
    if (cutEntity && kJL_BLE_Multiple.BLE_IS_CONNECTING) {
        NSLog(@"--->Cut connecting scan device:%@",cutEntity.mItem);
        [kJL_BLE_Multiple disconnectEntity:cutEntity Result:^(JL_EntityM_Status status) {}];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addNote{
    [JL_Tools add:kJL_BLE_M_FOUND Action:@selector(noteBleFoundDevice:) Own:self];

}

-(void)removeNote{
    [JL_Tools remove:kJL_BLE_M_FOUND Own:self];
    [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];
}

-(void)dealloc{
    [self removeNote];
}

@end
