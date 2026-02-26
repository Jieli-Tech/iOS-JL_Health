//
//  FunctionView.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/2/23.
//

#import "FunctionView.h"
#import "MyHealthVC.h"
#import "DeviceMusicVC.h"
#import "AlarmClockVC.h"
#import "MyContactsVC.h"
#import "BtCallViewController.h"
#import "OtaUpdateVC.h"
#import "DeviceMoreVC.h"
#import "SpeechRecognitionVC.h"

@interface FunctionView()<JLConfigPtl>{
    NSMutableArray *btnArray;
    NSMutableArray *viewControllers;
    
}
@end

@implementation FunctionView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        btnArray = [NSMutableArray new];
        viewControllers = [NSMutableArray new];
        [self initByArray];
        [[JLDeviceConfig share] addDelegate:self];
        [self addNote];
    }
    return self;
}


-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

- (void)noteDeviceChange:(NSNotification*)note {
    [self initByArray];
}

-(void)initByArray{
    float gap = 52.0;
    float sW = [DFUITools screen_2_W];
    JLDeviceConfigModel *model = [[JLDeviceConfig share] deviceGetConfigWithUUID:kJL_BLE_EntityM.mPeripheral.identifier.UUIDString];
    [btnArray removeAllObjects];
    [viewControllers removeAllObjects];
    
    if(model.healthFunc.spComprehensive.spHealthMonitor){
        [btnArray addObject:@{@"ITEM_0":@"icon_health_nol",@"ITEM_1":kJL_TXT("健康")}];
        MyHealthVC *vc = [[MyHealthVC alloc] init];
        [viewControllers addObject:vc];
    }
    
    if(model.exportFunc.spMusicFileBrows){
        JLModel_Device *deviceModel = [kJL_BLE_CmdManager outputDeviceModel];
        if([deviceModel.cardArray containsObject:@(JL_CardTypeSD_0)]){
            [btnArray addObject:@{@"ITEM_0":@"icon_music_nol",@"ITEM_1":kJL_TXT("音乐管理")}];
            DeviceMusicVC *vc = [[DeviceMusicVC alloc] init];
            vc.type = JLDeviceMusicVCTypeSD;
            NSLog(@"card list:%@",deviceModel.cardArray);
            vc.devel = deviceModel;
            [viewControllers addObject:vc];
        }
    }
    
    if(model.exportFunc.spAlarmSettings){
        [btnArray addObject:@{@"ITEM_0":@"icon_clock_nol",@"ITEM_1":kJL_TXT("闹钟")}];
        AlarmClockVC *vc = [[AlarmClockVC alloc] init];
        [viewControllers addObject:vc];
    }
    
    if(model.exportFunc.spTopContacts){
        [btnArray addObject:@{@"ITEM_0":@"icon_contecter_nol",@"ITEM_1":kJL_TXT("常用联系人")}];
        MyContactsVC *vc = [[NSBundle mainBundle] loadNibNamed:@"MyContactsVC" owner:nil options:nil].lastObject;
        [viewControllers addObject:vc];
    }
        
    if(model.exportFunc.spAiCloud){
        [btnArray addObject:@{@"ITEM_0":@"icon_ai_nol",@"ITEM_1":kJL_TXT("AI云服务")}];
        SpeechRecognitionVC *vc =  [[SpeechRecognitionVC alloc] init];
        [viewControllers addObject:vc];
    }
    
    [btnArray addObject:@{@"ITEM_0":@"icon_bt_nol",@"ITEM_1":kJL_TXT("手表蓝牙通话")}];
    BtCallViewController *vc = [[BtCallViewController alloc] init];
    [viewControllers addObject:vc];
    
    if(model.basicFunc.spOTA){
        [btnArray addObject:@{@"ITEM_0":@"icon_update_nol",@"ITEM_1":kJL_TXT("设备版本更新")}];
        OtaUpdateVC *vc = [[OtaUpdateVC alloc] init];
        [viewControllers addObject:vc];
    }
        
    [btnArray addObject:@{@"ITEM_0":@"icon_device_more_nol",@"ITEM_1":kJL_TXT("更多")}];
    DeviceMoreVC *vc1 = [[DeviceMoreVC alloc] init];
    [viewControllers addObject:vc1];
    
    
    [self removeSubviews];
    self.viewHeight = btnArray.count*gap;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sW, 52*gap);
    for (int i = 0 ; i < btnArray.count; i++) {
        NSDictionary *model = btnArray[i];
                    
        UIImageView *imageView_0 = [[UIImageView alloc] init];
        imageView_0.image = [UIImage imageNamed:model[@"ITEM_0"]];
        imageView_0.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView_0];
        
        UIButton *btn_1 = [[UIButton alloc] init];
        btn_1.tag = i;
        [btn_1 setTitle:model[@"ITEM_1"] forState:UIControlStateNormal];
        [btn_1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn_1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self addSubview:btn_1];
        [btn_1 addTarget:self action:@selector(onBtnTap:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *imageView_2 = [[UIImageView alloc] init];
        imageView_2.image = [UIImage imageNamed:@"icon_next_nol"];
        imageView_2.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView_2];
        
        CGRect rect_0 = CGRectMake(0, i*gap, gap, gap);
        CGRect rect_1 = CGRectMake(gap, i*gap, sW - gap*2, gap);
        CGRect rect_2 = CGRectMake(sW-gap, i*gap, gap, gap);
        
        imageView_0.frame = rect_0;
        btn_1.frame       = rect_1;
        imageView_2.frame = rect_2;
    }
}







-(void)onBtnTap:(UIButton*)btn{
    if(viewControllers.count>btn.tag){
        [self.subView cutEntityConnecting];//关闭正在连接的设备
        /*--- 检查是否处于强制升级 ---*/
        NSString *name = [NSString stringWithUTF8String:object_getClassName(viewControllers[btn.tag])];
        
        if (kJL_BLE_EntityM.mBLE_NEED_OTA == YES  && [name isEqualToString:@"OtaUpdateVC"]){
            /*--- OTA界面需要弹出来 ---*/
            [DFUITools showText:@"需要强制升级" onView:self.superview delay:1.0];
            return;
        }
        
        [JLApplicationDelegate.navigationController pushViewController:viewControllers[btn.tag] animated:YES];
    }else{
        NSLog(@"__ Error for out of array");
    }
}


//MARK: - handel with config ptl
- (void)deviceConfigWith:(JLDeviceConfigModel *)configModel{
    [self initByArray];
}


@end
