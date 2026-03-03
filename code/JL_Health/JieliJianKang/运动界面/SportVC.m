//
//  SportVC.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/2/18.
//

#import "SportVC.h"
#import "JLPagerView.h"
#import "JLPopMenuView.h"
#import "AddDeviceVC.h"
#import "QRScanVC.h"

@interface SportVC () <LanguagePtl,JLConfigPtl>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong,nonatomic) JLPopMenuView *popMenuView;

@end

@implementation SportVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSArray *titleArray = @[kJL_TXT("户外跑步"), kJL_TXT("室内跑步")];
        NSArray *vcsArray = @[@"JLOutdoorSportThumbnailViewController", @"JLIndoorSportsThumbnailViewController"];
        NSArray *colorArray = @[
            [JLColor colorWithString:@"#805BEB"], /**< 选中的标题颜色 Title SelectColor  **/
            [JLColor colorWithString:@"#919191"], /**< 未选中的标题颜色  Title UnselectColor **/
            [JLColor colorWithString:@"#805BEB"], /**< 下划线颜色 Underline Color   **/
        ];
        JLPagerView *pagerView = [[JLPagerView alloc] initWithTitles:titleArray WithVCs:vcsArray WithColorArrays:colorArray];
        self.pagerView = pagerView;
        [[LanguageCls share] add:self];
        [[JLDeviceConfig share] setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.text = kJL_TXT("运动");
    
    if (self.pagerView) {
        [self.containerView addSubview:_pagerView];
    }
    [self addNote];
    JLDeviceConfigModel *configModel = [[JLDeviceConfig share] deviceGetConfigWithUUID:kJL_BLE_EntityM.mUUID];
    [self deviceConfigWith:configModel];
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

- (void)noteDeviceChange:(NSNotification*)note {
    JLDeviceConfigModel *configModel = [[JLDeviceConfig share] deviceGetConfigWithUUID:kJL_BLE_EntityM.mUUID];
    [self deviceConfigWith:configModel];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
}




- (IBAction)moreBtnFunc:(UIButton *)sender {
    NSArray<JLPopMenuViewItemObject *> *arr = @[
        [[JLPopMenuViewItemObject alloc] initWithName:kJL_TXT("扫一扫") withImageName:@"icon_scan_nol" withTapBlock:^{
            QRScanVC *vc = [[QRScanVC alloc] init];
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];

        }],
        [[JLPopMenuViewItemObject alloc] initWithName:kJL_TXT("添加设备") withImageName:@"icon_add_nol-1" withTapBlock:^{
            AddDeviceVC *vc = [[AddDeviceVC alloc] init];
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];

        }],
    ];
    self.popMenuView = [[JLPopMenuView alloc] initWithStartPoint:CGPointMake(sender.x + sender.width - 150, sender.y + sender.height - 10) withItemObjectArray:arr];
    [self.view addSubview:self.popMenuView];
    self.popMenuView.hidden = NO;
}

#pragma mark - LanguagePtl

- (void)languageChange {
    self.titleLabel.text = kJL_TXT("运动");
    [self.popMenuView setTitleName:@[kJL_TXT("扫一扫"),kJL_TXT("添加设备")]];
    
    NSMutableArray *titleArray = [[NSMutableArray alloc] init];
    JLDeviceConfigModel *configModel = [[JLDeviceConfig share] deviceGetConfigWithUUID:kJL_BLE_EntityM.mUUID];
    if(configModel.healthFunc.spSportModel.spOutdoor){
        [titleArray addObject:kJL_TXT("户外跑步")];
    }
    if(configModel.healthFunc.spSportModel.spIndoor){
        [titleArray addObject:kJL_TXT("室内跑步")];
    }
    if(titleArray.count == 0){
        [titleArray addObject:kJL_TXT("户外跑步")];
    }
    [self.pagerView setTitles:@[kJL_TXT("户外跑步"), kJL_TXT("室内跑步")]];
}

//MARK: - Config ptl
- (void)deviceConfigWith:(JLDeviceConfigModel *)configModel{
    
    kJLLog(JLLOG_DEBUG, @"%s:%@",__func__,kJL_BLE_EntityM.mPeripheral.identifier.UUIDString);
    
    if(![configModel.mbleIdentifyStr isEqualToString:kJL_BLE_EntityM.mPeripheral.identifier.UUIDString] && kJL_BLE_EntityM.mPeripheral.identifier.UUIDString != nil){
        return;
    }
    
    NSMutableArray *titleArray = [[NSMutableArray alloc] init];
    NSMutableArray *vcsArray = [[NSMutableArray alloc] init];

    NSArray *colorArray = @[
        [JLColor colorWithString:@"#805BEB"], /**< 选中的标题颜色 Title SelectColor  **/
        [JLColor colorWithString:@"#919191"], /**< 未选中的标题颜色  Title UnselectColor **/
        [JLColor colorWithString:@"#805BEB"], /**< 下划线颜色 Underline Color   **/
    ];
    if(configModel.healthFunc.spSportModel.spOutdoor){
        [titleArray addObject:kJL_TXT("户外跑步")];
        [vcsArray addObject:@"JLOutdoorSportThumbnailViewController"];
    }
    if(configModel.healthFunc.spSportModel.spIndoor){
        [titleArray addObject:kJL_TXT("室内跑步")];
        [vcsArray addObject:@"JLIndoorSportsThumbnailViewController"];
    }
    if(titleArray.count == 0){
        [titleArray addObject:kJL_TXT("户外跑步")];
        [vcsArray addObject:@"JLOutdoorSportThumbnailViewController"];
    }
    [self.pagerView reCreatePagerView:titleArray WithVCs:vcsArray WithColors:colorArray];
}

@end
