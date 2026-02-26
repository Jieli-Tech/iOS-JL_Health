//
//  DevicesSubView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/21.
//

#import "DevicesSubView.h"
#import "DevicesViewCell.h"
#import "JLUI_Effect.h"
#import "JLColor.h"
#import "JLDeviceSqliteManager.h"
#import "UserDeviceModel.h"
#import "DeviceHttp.h"
#import "DeviceHttpModel.h"
#import "User_Http.h"
#import "SyncDataManager.h"
#import "JLSqliteHeartRate.h"
#import "JLSqliteOxyhemoglobinSaturation.h"
#import "JLSqliteSleep.h"
#import "JLSqliteStep.h"


@interface DevicesSubView ()<devCellDelegate,LanguagePtl>{
    UIView *noOneView;
    NSMutableArray *locateArray;
    UserDeviceModel *saveModel;
    DFTips *tipsView;
    NSTimer *connectTimer;
    NSInteger timerCount;
    
    NSInteger connectTimeOut;
    JL_EntityM *cutEntity;

    UILabel *noDevicelab;
    UIButton *addBtn;
    
    BOOL     isReconnecting;
}
@end

@implementation DevicesSubView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        isReconnecting = NO;
        connectTimeOut = 15;

        [[LanguageCls share] add:self];
        
        locateArray = [NSMutableArray new];
        self.backgroundColor = [UIColor clearColor];
        
        UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc]init];
        fl.itemSize = CGSizeMake(self.width, self.frame.size.height-20);
        fl.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        fl.minimumLineSpacing = 0;
        fl.minimumInteritemSpacing = 0;
        
        self.colView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:fl];
        self.colView.backgroundColor = [UIColor clearColor];
        [self.colView registerNib:[UINib nibWithNibName:@"DevicesViewCell" bundle:nil] forCellWithReuseIdentifier:@"DevicesViewCell"];
        self.colView.showsHorizontalScrollIndicator = false;
        self.colView.delegate = self;
        self.colView.dataSource = self;
        self.colView.pagingEnabled = YES;
        [self addSubview:self.colView];
        
        [self addNoneView];
        noOneView.hidden = true;
        [DeviceHttp checkList:^(NSArray<DeviceHttpResp *> * _Nullable array) {
            for (DeviceHttpResp *item in array) {
                [[JLDeviceSqliteManager share] update:[item beUdm] Time:item.updateTime];
                //NSLogEx(@"Devices service:%@ idStr:%@",item.mac,item.idStr);
            }
            [self refreshUI];
        }];
        [self addNote];
        tipsView = [DFUITools showHUDOnWindowWithLabel:kJL_TXT("正在连接")];
        [tipsView hide:false];
        
        
    }
    return self;
}



-(void)shouldUpdateBattery{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.colView reloadData];
    });
}

-(void)refreshUI{
    NSLog(@"-------------> refreshUI 0 ");

    NSString *identify = User_Http.shareInstance.userPfInfo.identify;
    if (identify.length == 0) {
        [[User_Http shareInstance] requestGetUserConfigInfo:^(JLUser * _Nonnull userInfo) {
            NSString *identify_1 = User_Http.shareInstance.userPfInfo.identify;
            NSLog(@"-------------> refreshUI 1 ");
            [self checkoutBy:identify_1];
        }];
    }else{
        NSLog(@"-------------> refreshUI 2 ");
        [self checkoutBy:identify];
    }
}

-(void)checkoutBy:(NSString*)identify{
    [[JLDeviceSqliteManager share] checkoutBy:identify result:^(NSArray<UserDeviceModel *> * _Nonnull resultArray) {
        //[self->locateArray removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resultArray.count==0 && self->locateArray.count == 0) {
                self->noOneView.hidden = false;
            }else{
                self->noOneView.hidden = true;
                for (UserDeviceModel *item in resultArray)
                {
                    if ([item.uuidStr isEqualToString:kJL_BLE_EntityM.mPeripheral.identifier.UUIDString]) {
                        [self updateLocateArray:item AtIndex:0];
                    }else{
                        [self updateLocateArray:item AtIndex:-1];
                    }
                    //NSLog(@"Devices service:%ld name:%@",(long)item.identifier,item.devName);
                }
            }
            [self.colView reloadData];
            [self.colView setContentOffset:CGPointMake(0, 0) animated:YES];
        });
    }];
}



-(void)refreshUIWithOTADevice:(UserDeviceModel*)model{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->noOneView.hidden = true;
        [self updateLocateArray:model AtIndex:0];
        [self.colView reloadData];
        [self.colView setContentOffset:CGPointMake(0, 0) animated:YES];
    });
    //NSLog(@"Devices service:OTA name:%@",model.devName);
}


-(void)updateLocateArray:(UserDeviceModel*)model AtIndex:(NSInteger)index{
    
    for (UserDeviceModel *md in locateArray) {
        if ([md.mac isEqual:model.mac]) {
            
            if (index == 0) {
                NSLog(@"--->Take First Device：%@",model.devName);
                [locateArray insertObject:model atIndex:index];
                [locateArray removeObject:md];
            }
            return;
        }
    }
    
    if (index >= 0) {
        NSLog(@"--->Take First Device：%@",model.devName);
        [locateArray insertObject:model atIndex:index];
    }else{
        NSLog(@"--->Take Other Device：%@",model.devName);
        [locateArray addObject:model];
    }
}




-(void)addNoneView{
    noOneView = [[UIView alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width-40, self.frame.size.height-20)];
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 157, noOneView.frame.size.height)];
    imgv.contentMode = UIViewContentModeScaleAspectFit;
    imgv.image = [UIImage imageNamed:@"product_img_empty"];
    [noOneView addSubview:imgv];
    
    if([DFUITools screen_2_W] == 320){
        noDevicelab = [[UILabel alloc] initWithFrame:CGRectMake(145, 60, 160, 20)];
    }else{
        noDevicelab = [[UILabel alloc] initWithFrame:CGRectMake(182, 60, 160, 20)];
    }
    noDevicelab.font = [UIFont systemFontOfSize:14];
    noDevicelab.textColor = [JLColor colorWithString:@"#919191"];
    noDevicelab.text = kJL_TXT("您还未添加任何设备");
    [noOneView addSubview:noDevicelab];
    
    if([DFUITools screen_2_W] == 320){
        addBtn = [[UIButton alloc] initWithFrame:CGRectMake(172, 85, 70, 26)];
    }else{
        addBtn = [[UIButton alloc] initWithFrame:CGRectMake(209, 85, 70, 26)];
    }
    addBtn.layer.cornerRadius = 13;
    addBtn.layer.borderColor = [JLColor colorWithString:@"#805BEB"].CGColor;
    addBtn.layer.masksToBounds = true;
    addBtn.layer.borderWidth = 1;
    addBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [addBtn setTitle:kJL_TXT("添加") forState:UIControlStateNormal];
    [addBtn setTitleColor:[JLColor colorWithString:@"#805BEB"] forState:UIControlStateNormal];
    [addBtn setTitleColor:[JLColor colorWithString:@"#919191"] forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(addBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [noOneView addSubview:addBtn];
    [JLUI_Effect addShadowOnView_2:noOneView];
    [self addSubview:noOneView];
}

-(void)addBtnAction{
    if ([_delegate respondsToSelector:@selector(devSubViewAddBtnAction)]) {
        [_delegate devSubViewAddBtnAction];
    }
}


//MARK:- collectionView Delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return locateArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DevicesViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DevicesViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    UserDeviceModel *model = locateArray[indexPath.row];

    
    cell.nameLab.text = model.devName;
    cell.delegate = self;
    cell.itemIndex = indexPath.row;
    cell.statusLab.textColor = [UIColor blackColor];
    //JL_EntityM *entity = kJL_BLE_EntityM;
    //NSLog(@"--->EDR %@ %@",entity.mEdr,model.mac);
    //NSLog(@"--->BLEADDR %@ %@",entity.mBleAddr,model.bleAddr);

    JLModel_Device *deviceModel = [kJL_BLE_CmdManager outputDeviceModel];
    cell.deviceUUID = deviceModel.mBLE_UUID;
    
    NSString *string = [[AutoProductIcon share] checkImgUrl:model.vid :model.pid];
    [cell.watchImgv sd_setImageWithURL:[NSURL URLWithString:string] placeholderImage:[UIImage imageNamed:@"img_watch_128_2"]];
    
    if ([deviceModel.btAddr isEqualToString:model.mac] ||
        [kJL_BLE_EntityM.mBleAddr isEqualToString:model.bleAddr]){
        cell.statusLab.text = kJL_TXT("已连接");
        cell.reConnectBtn.hidden = true;
        cell.powerLab.hidden = false;
        cell.watchImgv.alpha = 1;
    }else{
        cell.statusLab.text = kJL_TXT("未连接");
        cell.reConnectBtn.hidden = false;
        cell.powerLab.hidden = true;
        cell.watchImgv.alpha = 0.42;
    }
    
    
    
    if ([model.uuidStr isEqualToString:kJL_BLE_EntityM.mPeripheral.identifier.UUIDString]) {
        cell.powerLab.text = [NSString stringWithFormat:@"%@:%d%%",kJL_TXT("电量"),(int)deviceModel.battery];
    }else{
        cell.powerLab.text = [NSString stringWithFormat:@"%@:0%%",kJL_TXT("电量")];
    }
    [JLUI_Effect addShadowOnView_2:cell.bgView];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UserDeviceModel *model = locateArray[indexPath.row];
    if ([_delegate respondsToSelector:@selector(devSubViewscrollToSomeModel:)]) {
        [_delegate devSubViewscrollToSomeModel:model];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    int contentOffsetX = scrollView.contentOffset.x;
//    int w = self.frame.size.width;
//    int index = contentOffsetX / w;
//    NSLog(@"scrollView.contentOffset:%f index:%d",scrollView.contentOffset.x,index);
}

#pragma mark 监听通知
-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JL_Tools add:@"kUI_DELETE_DEVICE_MODEL" Action:@selector(noteDeleteModel:) Own:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldUpdateBattery) name:@"JL_BATTERY" object:nil];
}

- (void)noteDeviceChange:(NSNotification*)note {
    JLDeviceChangeType type = [[note object] integerValue];
    if (type == JLDeviceChangeTypeSomethingConnected) {
        
        JLModel_Device *deviceModel = [kJL_BLE_CmdManager outputDeviceModel];
        NSString *strPid = nil;
        NSString *strVid = nil;
        if (deviceModel.pidvid.length >0) {
            strPid = [deviceModel.pidvid substringWithRange:NSMakeRange(0, 4)];
            strVid = [deviceModel.pidvid substringWithRange:NSMakeRange(4, 4)];
        }
        
        UserDeviceModel *model  = [[UserDeviceModel alloc] init];
        model.devName           = kJL_BLE_EntityM.mItem;
        model.pid               = strPid?:kJL_BLE_EntityM.mPID;
        model.vid               = strVid?:kJL_BLE_EntityM.mVID;
        model.uuidStr           = kJL_BLE_EntityM.mPeripheral.identifier.UUIDString;
        model.mac               = deviceModel.btAddr?:kJL_BLE_EntityM.mEdr;
        model.userID            = [[User_Http shareInstance] userPfInfo].identify;
        model.advData           = kJL_BLE_EntityM.mAdvData;
        model.type              = @"手表";
        model.deviceID          = @"";
        model.androidConfig     = @"";
        model.explain           = @"";
        if (!model.uuidStr) {
            NSLog(@"缺乏基础信息，不能进行设备信息数据存储/备份操作");
            return;
        }
        
        /*--- OTA通过广播包回连的方式，会生成零时UUID和ble地址用于iphone回连，
              所以不用存储处于OTA的设备model，因为升级完成后会使用原来的UUID连接。 ---*/
        if (kJL_BLE_EntityM.mSpecialType == JLDevSpecialType_Reconnect) {
            model.bleAddr = kJL_BLE_EntityM.mBleAddr;
            model.mac     = kJL_BLE_EntityM.mBleAddr;
            model.isTemporary = YES;
            [self refreshUIWithOTADevice:model];
            return;
        }
       
        
        //备份/同步数据到服务器
        NSLog(@"-------------> checkoutBy000");
        [[JLDeviceSqliteManager share] checkoutBy:model.userID result:^(NSArray<UserDeviceModel *> * _Nonnull resultArray) {
            NSLog(@"-------------> checkoutBy:%@",model.userID);
            if (![self comePare:model WithList:resultArray]) {
                NSLog(@"-------------> 11111111");
                [DeviceHttp bind:^(JLHttpResponse * _Nonnull response) {
                    if (response.code == 0) {
                        NSLog(@"服务器绑定设备成功");
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response.data options:NSJSONReadingMutableLeaves error:nil];
                        model.deviceID = dict[@"id"];
                        model.androidConfig = dict[@"androidCoinfgiData"];
                        model.explain = dict[@"explain"];
                        [[JLDeviceSqliteManager share] update:model];
                    }else{
                        NSLog(@"服务器绑定失败，设备已被其他人绑定");
                        [[JLDeviceSqliteManager share] update:model];
                        [[JLDeviceSqliteManager share] checkoutAll:^(NSArray<UserDeviceModel *> * _Nonnull resultArray) {
                            
                        }];
                    }
                    NSLog(@"-------------> 2222222");

                    [self refreshUI];
                }];
            }else{
                UserDeviceModel *md = resultArray.firstObject;
                md.devName = kJL_BLE_EntityM.mItem;
                md.pid = strPid?:kJL_BLE_EntityM.mPID;
                md.vid = strVid?:kJL_BLE_EntityM.mVID;
                md.uuidStr = kJL_BLE_EntityM.mPeripheral.identifier.UUIDString;
                md.mac = deviceModel.btAddr?:kJL_BLE_EntityM.mEdr;
                if (kJL_BLE_EntityM.mAdvData) {
                    md.advData = kJL_BLE_EntityM.mAdvData;
                }
                md.userID = [[User_Http shareInstance] userPfInfo].identify;
                
                NSLog(@"-------------> update 0:%@",model);
                [DeviceHttp updateConfig:[md beDeviceHttpBody] Result:^(JLHttpResponse * _Nonnull response) {
                    if (response.code == 0) {
                        NSLog(@"服务器更新设备成功");
                        [[JLDeviceSqliteManager share] update:md];
                        [[JLDeviceSqliteManager share] checkoutAll:^(NSArray<UserDeviceModel *> * _Nonnull resultArray) {
                        }];
                        
                    }else{
                        NSLog(@"服务器更新设备信息时错误");
                    }
                    [self refreshUI];
                }];
            }
        }];
        NSLog(@"-------------> update 1:%@",model);
        [[JLDeviceSqliteManager share] update:model];
        [self refreshUI];
    }
    if (type == JLDeviceChangeTypeInUseOffline) {
        
    }
    if (type == JLDeviceChangeTypeBleOFF) {
        
    }
}

-(void)noteDeleteModel:(NSNotification*)note{
    UserDeviceModel *mac = note.object;
    for (UserDeviceModel *md in locateArray) {
        if ([md.mac isEqual:mac]) {
            [locateArray removeObject:md];
            break;
        }
    }
    [self.colView reloadData];
    [self.colView setContentOffset:CGPointMake(0, 0) animated:YES];
}


-(BOOL)comePare:(UserDeviceModel*)model WithList:(NSArray<UserDeviceModel*> *)models{
    
    for (UserDeviceModel *item in models) {
        //根据是不是相同的mac地址以及UserID，以及判断deviceID是否为空，因为deviceIID只有在绑定成功之后才不会为空
        //所以这里会每次连接上了之后都判断是否已经绑定了，不然就去绑定服务器。
        if ([item.mac isEqualToString:model.mac] && [item.userID isEqualToString:model.userID] && ![item.deviceID isEqualToString:@""]) {
            return YES;
        }
    }
    return NO;
}

//MARK: - cell delegate
-(void)cellDidSelect:(NSInteger)itemIndex{
   

    if (kJL_BLE_Multiple.bleManagerState == CBManagerStatePoweredOff) {
        [DFUITools showText:kJL_TXT("蓝牙没有打开") onView:self delay:1.0];
        return;
    }
    NSLog(@"--->手动回连设备.");
    
    if (locateArray.count > itemIndex) {
        saveModel = locateArray[itemIndex];
        
        [self showConnectUI];
        [self reconnectDeviceUuidOfModel:saveModel];

    }
}



-(void)reconnecLastDevice{
    
    if (kJL_BLE_Multiple.bleManagerState == CBManagerStatePoweredOff) {
        [DFUITools showText:kJL_TXT("蓝牙没有打开") onView:self delay:1.0];
        return;
    }
    //NSLog(@"--->无感回连设备.");
    
    if (locateArray.count > 0) {
        /*--- 避免回连临时变地址OTA设备 ---*/
        NSMutableArray *newLocateArray = [NSMutableArray new];
        for (UserDeviceModel *md in locateArray) {
            if (md.isTemporary == NO) {
                [newLocateArray addObject:md];
            }
        }
        locateArray = newLocateArray;
        [self.colView reloadData];
        [self.colView setContentOffset:CGPointMake(0, 0) animated:YES];
        
        if (locateArray.count > 0) {
            self->saveModel = locateArray.firstObject;
            [self reconnectDeviceUuidOfModel:self->saveModel];
        }else{
            NSLog(@"No device to connect.");
        }

        
//        NSString *identify = User_Http.shareInstance.userPfInfo.identify;
//        [[JLDeviceSqliteManager share] checkoutBy:identify result:^(NSArray<UserDeviceModel *> * _Nonnull resultArray) {
//            if (resultArray.count>0) {
//
//                /*--- 避免回连临时变地址OTA设备 ---*/
//                for (UserDeviceModel *md in resultArray) {
//                    if (md.isTemporary == NO) {
//                        self->saveModel = md;
//                        break;
//                    }
//                }
//
//                [self reconnectDeviceUuidOfModel:self->saveModel];
//
//
//            }
//        }];
    }
}

-(void)timerAction{
    
    if (timerCount>connectTimeOut) {
        tipsView.labelText = kJL_TXT("连接超时");
        self->isReconnecting = NO;
        [self cancelSearch];
        [self closeConnectTimer];
        [self dismissConnectUI];
        NSLog(@"---> Search Close Scan!");
        return;
    }
    timerCount+=1;
}

-(void)startConnectTimer{
    timerCount = 0;
    if (connectTimer == nil) {
        connectTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                                      selector:@selector(timerAction)
                                                      userInfo:nil repeats:true];
    }
    [JL_Tools timingContinue:connectTimer];
}

-(void)closeConnectTimer{
    [JL_Tools timingPause:connectTimer];
    timerCount = 0;
}


-(void)showConnectUI{
    tipsView.labelText = kJL_TXT("正在连接");
    [tipsView show:true];
}

-(void)dismissConnectUI{
    [tipsView hide:false];
}


-(void)searchConnect{
    NSLog(@"--->开始搜索设备...");
    [JL_Tools add:kJL_BLE_M_FOUND_SINGLE Action:@selector(searchEntity:) Own:self];
    [JL_Tools post:kUI_JL_BLE_SCAN_OPEN Object:nil];
}

-(void)cancelSearch{
    //NSLog(@"--->停止搜索设备...");
    [JL_Tools remove:kJL_BLE_M_FOUND_SINGLE Own:self];
    [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];
}



-(void)reconnectDeviceUuidOfModel:(UserDeviceModel*)model{
    if (isReconnecting == YES) {
        NSLog(@"UI拒绝重复回连设备...");
        return;
    }
    isReconnecting = YES;
        
    if ([model.uuidStr isEqualToString:@""]) {
        [self cancelSearch];
        [self closeConnectTimer];

        [kJL_BLE_Multiple connectEntityForMac:model.mac Result:^(JL_EntityM_Status status) {
            [JL_Tools mainTask:^{
                if (status == JL_EntityM_StatusPaired) {
                    NSLog(@"----> MAC回连设备成功.");
                    [JL_Tools delay:2.0 Task:^{
                        self->isReconnecting = NO;
                        [self dismissConnectUI];
                        [self refreshUI];
                    }];

                }else{
                    /*--- 2、UUID连接失败，用BLE搜索连接方式 ---*/
                    NSLog(@"----> 正在搜索BLE回连...0");
                    [self searchConnect];
                    [self startConnectTimer];
                }
            }];
        }];
        return;
    }
    cutEntity = [kJL_BLE_Multiple makeEntityWithUUID:model.uuidStr];
    
    [self cancelSearch];
    [self closeConnectTimer];

    /*--- 1、直接UUID连接设备 ---*/
    //[[JL_RunSDK sharedMe] setAncsUUID:cutEntity.mPeripheral.identifier.UUIDString];
    [kJL_BLE_Multiple connectEntity:cutEntity Result:^(JL_EntityM_Status status) {
        [JL_Tools mainTask:^{
            if (status == JL_EntityM_StatusPaired) {
                NSLog(@"----> UUID回连设备成功.");
                [JL_Tools delay:2.0 Task:^{
                    self->isReconnecting = NO;
                    [self dismissConnectUI];
                    [self refreshUI];
                }];
            }else{
                /*--- 2、UUID连接失败，用BLE搜索连接方式 ---*/
                NSLog(@"----> 正在搜索BLE回连...1");
                [self searchConnect];
                [self startConnectTimer];
            }
        }];
    }];
}


//ce7c44df9b8a
-(void)searchEntity:(NSNotification *)note{
    JL_EntityM *entity = note.object;
    if ([entity.mEdr isEqualToString:saveModel.mac]) {
        [self cancelSearch];
        [self closeConnectTimer];
        
        cutEntity = entity;
        
        //[[JL_RunSDK sharedMe] setAncsUUID:cutEntity.mPeripheral.identifier.UUIDString];
        [kJL_BLE_Multiple connectEntity:entity Result:^(JL_EntityM_Status status) {
            if (status == JL_EntityM_StatusPaired) {
                NSLog(@"----> 搜索回连成功.");
                [JL_Tools delay:2.0 Task:^{
                    self->isReconnecting = NO;
                    [self dismissConnectUI];
                    [self refreshUI];
                }];
            }
        }];
    }
}

-(void)cutEntityConnecting{
    self->isReconnecting = NO;
    [self cancelSearch];
    [self closeConnectTimer];
    [self dismissConnectUI];
    
    /*--- 是否有设备正在连接中，但是又没有连接上 ---*/
    if (cutEntity && kJL_BLE_Multiple.BLE_IS_CONNECTING) {
        NSLog(@"--->Cut connecting device:%@",cutEntity.mItem);
        [kJL_BLE_Multiple disconnectEntity:cutEntity Result:^(JL_EntityM_Status status) {}];
    }
}

- (void)languageChange {
    [addBtn setTitle:kJL_TXT("添加") forState:UIControlStateNormal];
    noDevicelab.text = kJL_TXT("您还未添加任何设备");
}

@end
