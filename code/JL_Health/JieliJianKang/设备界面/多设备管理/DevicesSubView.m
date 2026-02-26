//
//  DevicesSubView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/21.
//

#import "DevicesSubView.h"
#import "DevicesViewCell.h"
#import "JLColor.h"
#import "UserDeviceModel.h"


@interface DevicesSubView ()<devCellDelegate,LanguagePtl>{
    UIView *noOneView;
    NSMutableArray *locateArray;
    JL_EntityM *cutEntity;
    UILabel *noDevicelab;
    UIButton *addBtn;
    
}
@end

@implementation DevicesSubView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
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
        
        [DeviceSubViewModel shared].updateListCallBack = ^(NSArray<UserDeviceModel *> * _Nonnull list) {
            if (list){
                self->locateArray = [NSMutableArray arrayWithArray:list];
            }else{
                self->locateArray = [NSMutableArray new];
            }
            if (self->locateArray.count == 0) {
                self->noOneView.hidden = false;
            }else{
                self->noOneView.hidden = true;
            }
            [self->_colView reloadData];
            [self->_colView setContentOffset:CGPointMake(0, 0) animated:YES];
        };
    }
    return self;
}



-(void)refreshUIWithOTADevice:(UserDeviceModel*)model{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->noOneView.hidden = true;
        [self updateLocateArray:model];
        [self.colView reloadData];
        [self.colView setContentOffset:CGPointMake(0, 0) animated:YES];
    });
    //kJLLog(JLLOG_DEBUG, @"Devices service:OTA name:%@",model.devName);
}


-(void)updateLocateArray:(UserDeviceModel*)model {
    
    for (UserDeviceModel *md in locateArray) {
        if ([md.mac isEqual:model.mac]) {
            [locateArray removeObject:md];
            [locateArray insertObject:model atIndex:0];
            return;
        }
    }
    kJLLog(JLLOG_DEBUG, @"--->Take Other Device：%@",model.devName);
    [locateArray addObject:model];
    
}

-(void)addNoneView{
    noOneView = [[UIView alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width-40, self.frame.size.height-20)];
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 157, noOneView.frame.size.height)];
    imgv.contentMode = UIViewContentModeScaleAspectFit;
    imgv.image = [UIImage imageNamed:@"product_img_empty"];
    [noOneView addSubview:imgv];
    
    if([UIScreen mainScreen].bounds.size.width == 320){
        noDevicelab = [[UILabel alloc] initWithFrame:CGRectMake(145, 60, 160, 20)];
    }else{
        noDevicelab = [[UILabel alloc] initWithFrame:CGRectMake(182, 60, 160, 20)];
    }
    noDevicelab.font = [UIFont systemFontOfSize:14];
    noDevicelab.textColor = [JLColor colorWithString:@"#919191"];
    noDevicelab.text = kJL_TXT("您还未添加任何设备");
    [noOneView addSubview:noDevicelab];
    
    if([UIScreen mainScreen].bounds.size.width == 320){
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
    //kJLLog(JLLOG_DEBUG, @"--->EDR %@ %@",entity.mEdr,model.mac);
    //kJLLog(JLLOG_DEBUG, @"--->BLEADDR %@ %@",entity.mBleAddr,model.bleAddr);

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
    [JLUI_Effect addShadowOnView:cell.bgView];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UserDeviceModel *model = locateArray[indexPath.row];
    if ([_delegate respondsToSelector:@selector(devSubViewscrollToSomeModel:)]) {
        [_delegate devSubViewscrollToSomeModel:model];
    }
}





//MARK: - cell delegate
-(void)cellDidSelect:(NSInteger)itemIndex{

    if (kJL_BLE_Multiple.bleManagerState == CBManagerStatePoweredOff) {
        [DFUITools showText:kJL_TXT("蓝牙没有打开") onView:self delay:1.0];
        return;
    }
    if ([BridgeHelper isConnecting]) {
        return;
    }
    kJLLog(JLLOG_DEBUG, @"--->手动回连设备.");
    [AlertViewOnWindows showConnectingWithTips:kJL_TXT("正在连接") timeout:10];
    if (locateArray.count > itemIndex) {
        UserDeviceModel *saveModel = locateArray[itemIndex];
        if (kJL_BLE_EntityM){
            [kJL_BLE_Multiple disconnectEntity:kJL_BLE_EntityM Result:^(JL_EntityM_Status status) {
                if (status == JL_EntityM_StatusDisconnectOk) {
                    //执行一个延时函数，目的是为了能让 block 回调执行完之后（清理 Block），再去执行下一个语句
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self connectDevice:saveModel];
                    });
                }
            }];
        }else{
           [self connectDevice:saveModel];
        }
    }
}

-(void)connectDevice:(UserDeviceModel *)model{
    
    if([JL_RunSDK getStatusUUID:model.uuidStr] != JLUuidTypeDisconnected){
        kJLLog(JLLOG_WARN, @"尝试去连接一个已连接的对象");
        return;
    }
    JL_EntityM * entity = [kJL_BLE_Multiple makeEntityWithUUID:model.uuidStr];
    if (entity){
        kJLLog(JLLOG_DEBUG, @"本地存在已连接的对象");
        [[JL_RunSDK sharedMe] connectDevice:entity callBack:^(BOOL status) {
        }];
    }else{
        kJLLog(JLLOG_DEBUG, @"本地不存在已连接的对象");
        [[JL_RunSDK sharedMe] connectDeviceMac:model.mac callBack:^(BOOL callback) {
        }];
    }
}


-(void)cutEntityConnecting{
    /*--- 是否有设备正在连接中，但是又没有连接上 ---*/
    if (cutEntity && kJL_BLE_Multiple.BLE_IS_CONNECTING) {
        kJLLog(JLLOG_DEBUG, @"--->Cut connecting device:%@",cutEntity.mItem);
        [kJL_BLE_Multiple disconnectEntity:cutEntity Result:^(JL_EntityM_Status status) {}];
    }
}

- (void)languageChange {
    [addBtn setTitle:kJL_TXT("添加") forState:UIControlStateNormal];
    noDevicelab.text = kJL_TXT("您还未添加任何设备");
    [self->_colView reloadData];
}

@end
