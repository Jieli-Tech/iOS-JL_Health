//
//  FunctionVC.m
//  JLWatchDemo
//
//  Created by 杰理科技 on 2022/3/5.
//

#import "FunctionVC.h"
#import "JLHeadFile.h"
#import "TipView.h"

#import "WatchOperationVC.h"
#import "CustomWatchVC.h"
#import "BigFileVC.h"
#import "ContactVC.h"
#import "FileBrowseVC.h"
#import "UpdateVC.h"
#import "BasicFuncVC.h"
#import "HealthSyncSportVC.h"
#import "HealthStatisticalVC.h"

@interface FunctionVC ()<UITableViewDelegate,
                         UITableViewDataSource>
{

    QCY_BLEApple    *bt_ble;
    JL_ManagerM     *mCmdManager;

    __weak IBOutlet UITableView *subTableView;
    __weak IBOutlet UIButton *btn_open;
    __weak IBOutlet UIButton *btn_update;
    
    NSArray         *itemArray;
    
}

@end

@implementation FunctionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI{
    itemArray = @[@"WatchOpertion",@"WatchFace",@"FileTransfer",@"ContactList",@"OtaUpdate",@"FileList",
                  @"SystemInfos",@"MotionData",@"HealthData",@"UUID Connect"];
    
    btn_open.layer.cornerRadius = 10.0;
    
    subTableView.tableFooterView = [UIView new];
    subTableView.dataSource = self;
    subTableView.delegate   = self;
    subTableView.rowHeight  = 50.0;
    subTableView.hidden     = NO;
}

- (IBAction)openWatchFile:(id)sender {
    
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    bt_ble = bleSDK.bt_ble;
    mCmdManager = bt_ble.mAssist.mCmdManager;
    
    /*--- BLE是否连接 ---*/
    BOOL isConnect = [JL_RunSDK isConnectDevice];
    if (isConnect == NO) return;
        
    /*--- 设备是否需要OTA ---*/
    BOOL isOTA = [JL_RunSDK isNeedUpdateOTA];
    if (isOTA == YES) return;
    
    
    [TipView startLoadingView:@"获取Flash信息..." Delay:30.0];
    [DialManager openDialFileSystemWithCmdManager:mCmdManager withResult:^(DialOperateType type, float progress) {
        if (type == DialOperateTypeUnnecessary) {
            [TipView setLoadingText:@"已开启!" Delay:1.0];
        }
        if (type == DialOperateTypeFail || type == DialOperateTypeCmdFail) {
            [TipView setLoadingText:@"获取失败!" Delay:1.0];
        }
        if (type == DialOperateTypeSuccess) {
            self->subTableView.hidden = NO;
            [TipView setLoadingText:@"获取成功!" Delay:1.0];
        }
    }];
}





-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return itemArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *IDCell = @"BTCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDCell];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.text= itemArray[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        CustomWatchVC *vc = [CustomWatchVC new];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
    
    if (indexPath.row == 9) {
        JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
        bt_ble = bleSDK.bt_ble;
        
        NSString *uuid = [JL_Tools getUserByKey:kUUID_BLE_LAST];
        [bt_ble connectPeripheralWithUUID:uuid];
    }
    
    /*--- BLE是否连接 ---*/
    BOOL isConnect = [JL_RunSDK isConnectDevice];
    if (isConnect == NO) return;
    
    if (indexPath.row == 2) {
        BigFileVC *vc = [BigFileVC new];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
    
    if (indexPath.row == 3) {
        ContactVC *vc = [ContactVC new];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
    
    if (indexPath.row == 5) {
        FileBrowseVC *vc = [FileBrowseVC new];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
    if (indexPath.row == 6) {
        BasicFuncVC *vc = [[BasicFuncVC alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
        vc.manager = bleSDK.bt_ble.mAssist.mCmdManager;
        [self presentViewController:vc animated:true completion:nil];
    }
    if (indexPath.row == 7) {
        HealthSyncSportVC *vc = [[HealthSyncSportVC alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
        vc.manager = bleSDK.bt_ble.mAssist.mCmdManager;
        [self presentViewController:vc animated:true completion:nil];
    }
    
    if (indexPath.row == 8) {
        HealthStatisticalVC *vc = [[HealthStatisticalVC alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
        vc.manager = bleSDK.bt_ble.mAssist.mCmdManager;
        [self presentViewController:vc animated:true completion:nil];
    }
    
    
    
    /*--- 升级特别点，提前 ---*/
    if (indexPath.row == 4) {
        
        /*--- 设备是否需要升级资源 ---*/
        BOOL isResource = [JL_RunSDK isNeedUpdateResource_1];
        if (isResource == YES) {
            
            /*--- 判断是否打开文件系统 ---*/
            BOOL isOpen = [JL_RunSDK isOpenFileSystem];
            if (isOpen == NO) return;
        }
        
        UpdateVC *vc = [UpdateVC new];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
    
    
    /*--- 设备是否需要OTA ---*/
    BOOL isOTA = [JL_RunSDK isNeedUpdateOTA];
    if (isOTA == YES) return;
    
    /*--- 设备是否需要升级资源 ---*/
    BOOL isResource = [JL_RunSDK isNeedUpdateResource];
    if (isResource == YES) return;
    
    //注意：只有无需升级的设备才能操作表盘功能！！！
    
    
    if (indexPath.row == 0) {
        BOOL isOpen = [JL_RunSDK isOpenFileSystem];
        if (isOpen == NO) return;
        
        WatchOperationVC *vc = [WatchOperationVC new];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
    
    if (indexPath.row == 1) {
        BOOL isOpen = [JL_RunSDK isOpenFileSystem];
        if (isOpen == NO) return;
        
        CustomWatchVC *vc = [CustomWatchVC new];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
    

}


-(void)addNote{
    [JL_Tools add:kQCY_BLE_DISCONNECTED Action:@selector(noteBleDisconnect:) Own:self];
    [JL_Tools add:kQCY_BLE_OFF Action:@selector(noteBleOff:) Own:self];
}

-(void)noteBleDisconnect:(NSNotification*)note{
    [TipView removeLoading];
    [DFUITools showText:@"设备已断开." onView:self.view delay:1.0];
}

-(void)noteBleOff:(NSNotification*)note{
    [TipView removeLoading];
    [DFUITools showText:@"蓝牙已关闭" onView:self.view delay:1.0];
}

@end
