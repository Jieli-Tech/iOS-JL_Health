//
//  AddDeviceVC.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/2/18.
//

#import "AddDeviceVC.h"
#import "MJRefresh.h"
#import "JL_RunSDK.h"

#import "DeviceCell.h"
#import "JLUI_Effect.h"
#import "JLAnimationTool.h"
#import "DeleteView.h"
#import "QRScanVC.h"
#import "ScanConnectDeviceVC.h"


@interface AddDeviceVC ()<UITableViewDelegate,
                          UITableViewDataSource,
                          DeviceCellDelegate,DeleteViewDelegate>
{
    __weak IBOutlet NSLayoutConstraint *subTitle_H;
    __weak IBOutlet UITableView *subTableView;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIView *midView;
    
    NSMutableArray *deviceArray;
    

    BOOL        isConnectOK;
    DeleteView  *deleteView;
    JL_Timer    *connectTimer;
    
    NSTimer     *searchTimer;
    NSInteger   searchTimeout;
    NSInteger   searchSeek;

    
    __weak IBOutlet UILabel *lbNoDev_0;
    __weak IBOutlet UILabel *lbNoDev_1;
    __weak IBOutlet UIButton *btnNoDev;
    
    
    __weak IBOutlet UILabel *lbNoDev_3;
    __weak IBOutlet UIButton *btnNoDev_1;
    
}
@property (weak,nonatomic) NSMutableArray *foundArray;
@property (weak,nonatomic) NSMutableArray *linkedArray;
@end

@implementation AddDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNote];
    [self setupUI];
    [self setDeviceSearchTimer];
    [self searchAllDevice];
}

-(void)setupUI{
    isConnectOK = YES;
    

    self.foundArray = kJL_BLE_Multiple.blePeripheralArr;
    self.linkedArray= kJL_BLE_Multiple.bleConnectedArr;
    
    connectTimer    = [[JL_Timer alloc] init];
    searchTimeout   = 30;
    searchSeek      = 0;
    
    titleName.text = kJL_TXT("添加设备");
    subTitle_H.constant = kJL_HeightNavBar;
    
    subTableView.delegate = self;
    subTableView.dataSource = self;
    subTableView.tableFooterView = [UIView new];
    subTableView.rowHeight = 100.0;
    subTableView.allowsSelection = NO;
    
    deleteView = [[DeleteView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    deleteView.titleLab.numberOfLines = 2;
    deleteView.type = 1;
    deleteView.delegate = self;
    deleteView.titleLab.text = kJL_TXT("未发现手表，请确保手表有电并且贴近手机");
    [self.view addSubview:deleteView];
    deleteView.hidden = YES;
    
    [JLAnimationTool loadImageResource];

    
    lbNoDev_0.text = kJL_TXT("未找到设备？");
    lbNoDev_1.text = kJL_TXT("添加");
    lbNoDev_3.text = kJL_TXT("未找到目标设备？");
    
    /*--- 扫一扫 ---*/
    NSMutableAttributedString* txt_0 = [self lineString:kJL_TXT("扫一扫")];
    [btnNoDev setAttributedTitle:txt_0 forState:UIControlStateNormal];
    
    /*--- 重新搜索 ---*/
    NSMutableAttributedString* txt_1 = [self lineString:kJL_TXT("重新搜索")];
    [btnNoDev_1 setAttributedTitle:txt_1 forState:UIControlStateNormal];
    
    [self showSaoYiSao:1.0 Reflash:0.0];
}

-(NSMutableAttributedString*)lineString:(NSString*)string{
    NSMutableAttributedString* tncString = [[NSMutableAttributedString alloc] initWithString:string];
    [tncString addAttribute:NSUnderlineStyleAttributeName
                      value:@(NSUnderlineStyleSingle)
                      range:(NSRange){0,[tncString length]}];
    //此时如果设置字体颜色要这样
    [tncString addAttribute:NSForegroundColorAttributeName value:kDF_RGBA(8, 116, 251, 1)  range:NSMakeRange(0,[tncString length])];
    //设置下划线颜色...
    [tncString addAttribute:NSUnderlineColorAttributeName value:kDF_RGBA(8, 116, 251, 1) range:(NSRange){0,[tncString length]}];
    return tncString;
}


- (IBAction)btn_saoYiSao:(id)sender {
    NSLog(@"---> 扫一扫.");
    QRScanVC *vc = [[QRScanVC alloc] init];
    vc.formRoot = 1;
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btn_Reflash:(id)sender {
    NSLog(@"---> 重新搜索.");
    [self searchAllDevice];
}

-(void)showSaoYiSao:(float)alpha_0 Reflash:(float)alpha_1{
    if (btnNoDev.alpha == alpha_0 &&
        btnNoDev_1.alpha == alpha_1) return;
    
    [UIView animateWithDuration:0.2 animations:^{
        self->lbNoDev_0.alpha = alpha_0;
        self->lbNoDev_1.alpha = alpha_0;
        self->btnNoDev.alpha  = alpha_0;
        
        self->lbNoDev_3.alpha = alpha_1;
        self->btnNoDev_1.alpha= alpha_1;
    }];
}




-(void)setDeviceSearchTimer{
    if (searchTimer == nil) {
        searchTimer = [DFAction timingStart:@selector(searchTimerAction) target:self Time:1.0];
    }
    [DFAction timingPause:searchTimer];
}

-(void)searchAllDevice{
    NSLog(@"Search Device...");
    searchSeek = 0;
    [DFAction timingPause:searchTimer];
    
    //NSLog(@"---> to close 3");
    [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];
    
    subTableView.hidden = YES;
    [JLAnimationTool startSearchAnimationTime:searchTimeout];
    
    [JL_Tools delay:2.0 Task:^{
        [DFAction timingContinue:self->searchTimer];
        [JL_Tools post:kUI_JL_BLE_SCAN_OPEN Object:nil];
    }];
}

-(void)searchTimerAction{
    
    if (searchSeek == searchTimeout)
    {
        [DFAction timingPause:searchTimer];
        
        NSLog(@"---> to close 2");
        [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];

        [self timerEndUI];
        return;
    }else{
        [self timerRunningUI];
    }
    searchSeek++;
}

-(void)timerRunningUI{
//    NSLog(@"---> timerRunningUI.");
    NSInteger count = self.linkedArray.count + self.foundArray.count;
    if (count > 0) {
        [self showSaoYiSao:0.0 Reflash:1.0];
        [JLAnimationTool stopSearchAnimation];
        
        [subTableView reloadData];
        self->subTableView.hidden = NO;
    }
    for (JL_EntityM *item in self.foundArray) {
        [[AutoProductIcon share] getDeviceProductUrlWithPid:item.mPID vid:item.mVID];
//        [[AutoProductIcon share] getDeviceProductUrlWithPid:@"0130" vid:@"0002"];
//        [[AutoProductIcon share] getDeviceProductUrlWithPid:@"0001" vid:@"0003"];
    }
}

-(void)timerEndUI{
    NSLog(@"---> timerEndUI.");
    NSInteger ct = self.foundArray.count + self.linkedArray.count;
    NSLog(@"Loading END~ %ld",(long)ct);
    if (ct == 0) {
        self->deleteView.hidden = NO;
        [self showSaoYiSao:1.0 Reflash:0];
    }else{
        [self showSaoYiSao:0.0 Reflash:1.0];
    }
    [JLAnimationTool stopSearchAnimation];
}



- (IBAction)btn_back:(id)sender {
    NSLog(@"---> back");
    [self closeAll];
    [self removeNote];
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.linkedArray.count + self.foundArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *IDCell = @"WATCH_CELL";

    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:IDCell];
    if (cell == nil) {
        cell = [[DeviceCell alloc] init];
    }
    JL_EntityM *entity = nil;
    NSInteger row = indexPath.row;
    if (row < self.linkedArray.count) {
        entity = self.linkedArray[row];
        NSLog(@"Linked Edr ---> %@(%@)",entity.mEdr,entity.mItem);
    }else{
        if (self.foundArray.count > 0) {
            entity = self.foundArray[row - self.linkedArray.count];
            //NSLog(@"Found Edr ---> %@(%@)",entity.mEdr,entity.mItem);
        }
    }
    
    cell.isConnect = entity.isCMD_PREPARED;
    cell.subIndex = indexPath.row;
    cell.subLabel.text = entity.mItem;
    cell.delegate = self;
    
    NSString *string = [[AutoProductIcon share] checkImgUrl:entity.mPID :entity.mVID];
    [cell.subImageView sd_setImageWithURL:[NSURL URLWithString:string] placeholderImage:[UIImage imageNamed:@"img_watch_128_2"]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)onDeviceCellSelectIndex:(NSInteger)index{

    if (kJL_BLE_Multiple.bleManagerState == CBManagerStatePoweredOff) {
        [DFUITools showText:kJL_TXT("蓝牙没有打开") onView:self.view delay:1.0];
        return;
    }
        
    JL_EntityM *bleEntity = nil;
    NSInteger row = index;
    if (row < self.linkedArray.count) {
        bleEntity = self.linkedArray[row];
    }else{
        if(self.foundArray.count>0){
            bleEntity = self.foundArray[row - self.linkedArray.count];
        }
    }

    if (bleEntity.isCMD_PREPARED) {
        [self disconnectDevice:bleEntity];
    }else{
        
        NSLog(@"---> 搜索界面，连接设备：%@",bleEntity.mItem);
        [JL_Tools setUser:bleEntity.mUUID forKey:@"Entity"];
        
        [DFAction timingPause:searchTimer];
        NSLog(@"---> to close 1");
        [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];
        
        //先断开上一个连接
        if (kJL_BLE_EntityM) {
            NSLog(@"---> 断开上一个连接:%@",kJL_BLE_EntityM.mItem);
            [kJL_BLE_Multiple disconnectEntity:kJL_BLE_EntityM
                                           Result:^(JL_EntityM_Status status) {
                if (status == JL_EntityM_StatusDisconnectOk) {
                    [self connectRuler:bleEntity];
                }
            }];
        }else{
            [self connectRuler:bleEntity];
        }
    }
}

-(void)connectRuler:(JL_EntityM *)bleEntity{
    /*--- 判断经典蓝牙是否连接 ---*/
    if ([JL_RunSDK isConnectEdr:bleEntity.mEdr]) {
        [self connectToDevice:bleEntity];
    }else{
        if (bleEntity.mSpecialType == JLDevSpecialType_Reconnect) {
            if (bleEntity.mProtocolType == 0) {
                [self showConnectEdrView];
            }
            if (bleEntity.mProtocolType == 1) {
                [self connectToDevice:bleEntity];
            }
        }else{
            /*--- 正常设备需要提示用户连接经典蓝牙 ---*/
//            if(bleEntity.mProtocolType == 0x00){
//                [self showConnectEdrView];
//            }else if(bleEntity.mProtocolType == 0x02){
//            }
            [self connectToDevice:bleEntity];
        }
    }
}

#pragma - 经典蓝牙提示
-(void)showConnectEdrView{
    NSString *text;
    if([kJL_GET hasPrefix:@"zh"]){
        text = @"先在手机\"设置\"->\"蓝牙\"中选择您的设备进行连接。";
    }else{
        text = @"First, select your device in the phone \" Settings \"->\" Bluetooth \"";
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *endAction = [UIAlertAction actionWithTitle:kJL_TXT("好的") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self searchAllDevice];
    }];
    [alertController addAction:endAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)connectToDevice:(JL_EntityM*)bleEntity{
    ScanConnectDeviceVC *vc = [[ScanConnectDeviceVC alloc] init];
    [vc setConnectDevice:bleEntity];
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];

}

-(void)disconnectDevice:(JL_EntityM*)entity{

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:kJL_TXT("提示") message:nil
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:kJL_TXT("取消") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *btnConfirm = [UIAlertAction actionWithTitle:kJL_TXT("断开设备") style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"---> 断开连接:%@",entity.mItem);
        [kJL_BLE_Multiple disconnectEntity:entity Result:^(JL_EntityM_Status status) {
            if (status == JL_EntityM_StatusDisconnectOk) {
                NSLog(@"点击了取消");
                [JL_Tools mainTask:^{
                    [self->subTableView reloadData];
                }];
            }
        }];;
    }];
    [btnCancel setValue:kDF_RGBA(152, 152, 152, 1.0) forKey:@"_titleTextColor"];
    [actionSheet addAction:btnCancel];
    [actionSheet addAction:btnConfirm];
    [self presentViewController:actionSheet animated:YES completion:nil];
}





-(void)viewWillDisappear:(BOOL)animated{
    [JL_Tools remove:kJL_BLE_M_FOUND Own:self];
}

-(void)addNote{
    NSLog(@"AddNote");
    [JL_Tools add:@"kUI_RELOAD_ADD_VC" Action:@selector(noteCloseAddVC:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JL_Tools add:@"AutoProductImgv" Action:@selector(noteRefreshData) Own:self];
}

-(void)noteDeviceChange:(NSNotification*)note{
    NSLog(@"---> Device change.");
    [subTableView reloadData];
    
    JLDeviceChangeType type = [[note object] integerValue];
    if (type == JLDeviceChangeTypeInUseOffline || type == JLDeviceChangeTypeBleOFF) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)noteCloseAddVC:(NSNotification*)note{
    NSLog(@"---> noteCloseAddVC.");
    [subTableView reloadData];
}

-(void)noteRefreshData{
    [subTableView reloadData];
}


-(void)removeNote{
    [JL_Tools remove:@"kUI_RELOAD_ADD_VC" Own:self];
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

//重试
-(void)didCancelAction:(UIButton *)btn{
    NSLog(@"Reloading Start...");
    [self searchAllDevice];
}

//暂不绑定
-(void)didDeleteAction:(UIButton *)btn{
    
}


-(void)closeAll{
    [JLAnimationTool stopSearchAnimation];
    [DFAction timingStop:searchTimer];
    searchTimer = nil;
    
    NSLog(@"---> to close 0");
    [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];
}

-(void)dealloc{
    //[self closeAll];
    [JLAnimationTool unloadImageResource];
    [self removeNote];
}


@end
