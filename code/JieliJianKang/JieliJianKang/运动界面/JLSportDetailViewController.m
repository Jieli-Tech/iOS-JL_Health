//
//  JLSportDetailViewController.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/8.
//

#import "JLSportDetailViewController.h"
#import "UIView+CBFrameHelpers.h"
#import "JLTapView.h"
#import "JLGPSView.h"
#import "NSString+Time.h"
#import "JLUnlockSliderView.h"
#import "JLSportMapViewController.h"
#import "JLOutdoorSportThumbnailViewController.h"
#import "Masonry.h"
#import "JLAudioToolBox.h"
#import "JLSportHistoryDetailViewController.h"
#import "JLSqliteSportLocation.h"
#import "JLCoreMotionManager.h"
#import "JLSqliteSportSpeedPerKm.h"
#import "SyncDataManager.h"
#import "UserDataSync.h"

#define PROGRESSLINEWIDTH 3
#define TIMER_INTERVAL 0.01f                                        // 定时器记录长按按钮时间间隔
#define LONGPRESS_MAX_TIME 1.5f                                     // 长按最大时长 (单位/秒)

@interface JLSportDetailViewController () <JLWearSyncProtocol, JLUnlockSliderViewDelegate, JLCoreMotionManagerDelegate>

@property (strong, nonatomic) IBOutlet UIView *animateView;
@property (weak, nonatomic) IBOutlet UIImageView *animateImageView;     // 动画界面
@property (assign, nonatomic) bool isPlayAnimation;     // 只允许播放一次动画

// GPS强度监测
@property (weak, nonatomic) IBOutlet UIView *gpsIntensityContainerView;
@property (strong, nonatomic) JLGPSView *gpsView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceUnitLabel;

@property (weak, nonatomic) IBOutlet UIView *sportStatusView;
@property (weak, nonatomic) IBOutlet UILabel *sportStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartRateUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepNumberUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepFrequencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepFrequencyUnitLabel;

@property (weak, nonatomic) IBOutlet UIButton *lockBtn;
@property (weak, nonatomic) IBOutlet UIView *unlockSliderContainerView;
@property (strong, nonatomic) JLUnlockSliderView *unlockSliderView;
@property (weak, nonatomic) IBOutlet UIButton *goMapBtn;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet UIImageView *endBtnTipImageView;
@property (weak, nonatomic) IBOutlet UILabel *endBtnTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *endBtn;
@property (strong, nonatomic) UIView *endBtnBackgroundView;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (strong, nonatomic) CAShapeLayer *progressBackgroundLayer;
@property (strong, nonatomic) NSTimer *endTimer;
@property (assign, nonatomic) CGFloat endTimeCount;
@property (assign, nonatomic) Boolean isLongPressEndBtn;

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) Boolean isTimerRun;
@property (assign, nonatomic) CGFloat sportTime;
@property (strong, nonatomic) JLSportMapViewController *doingSportMapViewController;
@property (weak, nonatomic) JLSportHistoryDetailViewController *sportHistoryDetailViewController;

/// 运动状态，暂停，运动中
@property (assign, nonatomic) WatchSportStatus status;
/// 运动Id
@property (assign, nonatomic) double sportID;
/// 设备是否包含GPS
@property (assign, nonatomic) BOOL hasGPS;
/// 心率模式
@property (assign, nonatomic) WatchHeartRateType heartRateType;
/// 请求实时运动数据的时间间隔
@property (assign, nonatomic) NSTimeInterval requireRealTimeSportInfoInterval;
@property (strong, nonatomic) NSTimer *realTimeSportInfoTimer;

/// 计算每公里配速
@property (assign, nonatomic) double localDistance;             // 本地统计的距离
@property (assign, nonatomic) double perKmIndex;                  // 公里数
@property (strong, nonatomic) NSDate *perKmStartTime;           // 每公里开始时间

@property (assign, nonatomic) Boolean isOut;                  // 是否已经退出

@end

@implementation JLSportDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.animateView];
    
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    
    self.distanceUnitLabel.text = kJL_TXT("公里");
    self.distanceUnitLabel.numberOfLines=2;
    self.speedUnitLabel.text = kJL_TXT("配速");
    self.speedUnitLabel.numberOfLines=2;
    self.timeUnitLabel.text = kJL_TXT("运动时长");
    self.timeUnitLabel.numberOfLines=2;
    self.calorieUnitLabel.text = kJL_TXT("消耗（千卡）");
    self.calorieUnitLabel.numberOfLines=2;
    self.heartRateUnitLabel.text = kJL_TXT("心率（次/分钟）");
    self.heartRateUnitLabel.numberOfLines=2;
    self.stepNumberUnitLabel.text = kJL_TXT("步数（步）");
    self.stepNumberUnitLabel.numberOfLines=2;
    self.stepFrequencyUnitLabel.text = kJL_TXT("步频（步/分钟）");
    self.stepFrequencyUnitLabel.numberOfLines=2;
    self.endBtnTipLabel.text = kJL_TXT("长按结束");
    self.endBtnTipLabel.numberOfLines =2;
    self.sportStatusLabel.text = kJL_TXT("非运动");
    self.sportStatusLabel.numberOfLines =2;
    
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    self.distanceUnitLabel.text = kJL_TXT("公里");
    if ([unitStr isEqualToString:@("英制")]){
        self.distanceUnitLabel.text = kJL_TXT("英里");
    }
    
    [self.animateImageView setHidden:YES];
    self.animateImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
//    [self.titleLabel setHidden:YES];
//    [self.gpsIntensityContainerView setHidden:YES];
//    [self.goMapBtn setHidden:YES];
    
    self.sportStatusView.layer.cornerRadius = self.sportStatusView.width / 2;
    
    self.continueBtn.layer.cornerRadius = self.continueBtn.width / 2;
    self.continueBtn.backgroundColor = [JLColor colorWithString:@"#6FCE7C"];
    [self.continueBtn setTitle:kJL_TXT("sports_resume") forState:UIControlStateNormal];
    self.continueBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.endBtn.layer.cornerRadius = self.endBtn.width / 2;
    self.endBtn.backgroundColor = [JLColor colorWithString:@"#E47771"];
    [self.endBtn setTitle:kJL_TXT("sports_stop") forState:UIControlStateNormal];
    self.endBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.isLongPressEndBtn = NO;
    
    [self initializeEndBtnFunc];
    
    self.gpsView = [JLGPSView gpsView];
    [self.gpsIntensityContainerView addSubview:self.gpsView];
    [self.gpsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.continueBtn setHidden:YES];
    [self.endBtn setHidden:YES];
    [self.endBtnTipLabel setHidden:YES];
    [self.endBtnTipImageView setHidden:YES];
    [self.unlockSliderContainerView setHidden:YES];
    self.unlockSliderContainerView.layer.backgroundColor = [JLColor colorWithString:@"#805BEB"].CGColor;
    self.unlockSliderContainerView.layer.cornerRadius = self.unlockSliderContainerView.height / 2;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setSportTypeInterface];
    
//    [JLCoreMotionManager sharedInstance].delegate = self;
    if (!self.needStartAnimation) {
        [self.animateImageView removeFromSuperview];
        [self.animateView removeFromSuperview];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.gpsView resetIntensityManagerDelegate];
    if (self.needStartAnimation) {
        [self startAnimationWithCompletion:^() {
            [self.animateImageView removeFromSuperview];
            [self.animateView removeFromSuperview];
            [self startTimer];
            // 通知固件开始室外运动
            if (kJL_BLE_EntityM) {
                [[JLWearSync share] addProtocol:self];
                NSLog(@"[JLWearSync share] w_SportStart:");
                [[JLWearSync share] w_SportStart:self.sportType With:kJL_BLE_EntityM Block:^(BOOL succeed) {
                    if (succeed) {
                        NSLog(@"[JLWearSync share] w_SportStart: succeed");
                        // 固件开始运动
                        [[JLWearSync share] w_requireSportInfoWith:kJL_BLE_EntityM Block:^(JLWearSyncInfoModel *infoModel) {
                            if ((infoModel.sportID > 0) && (infoModel.status == WatchSportStatus_Motion)) {
                                self.wearSyncInfoModel = infoModel;
                                [self initializeDoingSportMapViewController];
                            } else {
                                // 本地开始运动
                                [self startLocalSport];
                            }
                        }];
                    } else {
                        // 本地开始运动
                        [self startLocalSport];
                    }
                }];
            } else {
                // 本地开始运动
                [self startLocalSport];
            }
        }];
    } else {
        // 获取当前运动实时信息
        NSLog(@"viewDidAppear needStartAnimation no!");
        if (self.wearSyncInfoModel.status == WatchSportStatus_Pause) {
            [self continueUI];
        }
        [[JLWearSync share] w_requireRealTimeSportInfoWith:kJL_BLE_EntityM];
        [[JLWearSync share] addProtocol:self];
        [self initializeDoingSportMapViewController];
        [self startTimer];
    }
}

- (void)dealloc {
    NSLog(@"JLSportDetailViewController dealloc");
    [self timerInvalidate];
    [self realTimeSportInfoTimerInvalidate];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    JLApplicationDelegate.sportDetailVC = nil;
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
    [self.outdoorSportThumbnailViewController resetGpsViewIntensityManagerDelegate];
}

/**
 *  开启本地运动
 */
- (void)startLocalSport {
    [self.navigationController popToRootViewControllerAnimated:YES];
    return;
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval sportID = [currentDate timeIntervalSince1970];
    self.sportID = sportID;
    
//    [[JLCoreMotionManager sharedInstance] startPedometerUpdatesFromNow];
    [self initializeDoingSportMapViewController];
}

//@interface JL_SRM_DataFormat : NSObject
///// 数据包类型
//@property(nonatomic,assign)JL_SRMDataType type;
///// 开始运动时间
//@property(nonatomic,strong)NSDate *startDate;
///// 暂停时间包
//@property(nonatomic,strong)NSDate *pauseDate;
///// 结束时间包
//@property(nonatomic,strong)NSDate *endDate;
///// 心率
//@property(nonatomic,assign)NSInteger heartRate;
///// 速度
//@property(nonatomic,assign)NSInteger speed;
///// 步频
//@property(nonatomic,assign)NSInteger stride;
/////原始数据长度
//@property(nonatomic,assign)NSInteger length;
//@end


/**
 *  结束本地运动
 */
- (void)finishLocalSport {
    [self.navigationController popToRootViewControllerAnimated:YES];
    return;
    if (kJL_BLE_EntityM) return;
    JLSportRecordModel *model = [[JLSportRecordModel alloc] init];
    model.modelType = self.sportType;
    JL_SRM_DataFormat *dataFormat = [[JL_SRM_DataFormat alloc] init];
    dataFormat.startDate = [NSDate dateWithTimeIntervalSince1970:self.sportID];
    model.dataArray = [NSArray arrayWithObject:dataFormat];
    [JLSqliteSportRunningRecord s_update:model];
    [JLSqliteSportRunningRecord s_checkoutWithSportID:self.sportID Result:^(JL_SportRecord_Chart * _Nullable chart) {
        if (chart) {
            JLSportHistoryDetailViewController *detailViewController = [[JLSportHistoryDetailViewController alloc] init];
            detailViewController.chart = chart;
            detailViewController.needPopToRootViewController = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
//    @interface JL_SportRecord_Chart : JLSportRecordModel
//    ///运动id
//    @property (nonatomic, assign) NSInteger sport_id;
//    @end
//    @interface JLSportRecordModel : NSObject
//    /// 运动模式
//    @property(nonatomic,assign)WatchSportType modelType;
//    /// 版本号
//    @property(nonatomic,assign)UInt8 version;
//    ///保留位2
//    @property(nonatomic,strong)NSData *reservedBit2;
//    ///间隔
//    ///有效范围:1~180 , 单位是秒
//    @property(nonatomic,assign)NSInteger interval;
//    /// 保留位
//    @property(nonatomic,strong)NSData *reservedBit;
//    ///运动数据列表
//    @property(nonatomic,strong)NSArray<JL_SRM_DataFormat*> *dataArray;
//    /// 运动时长
//    ///有效范围: 1-28800，单位是秒
//    @property(nonatomic,assign)NSInteger duration;
//    /// 距离
//    /// 有效范围: 1- 65535，单位是0.01公里（10米）
//    @property(nonatomic,assign)NSInteger distance;
//    /// 热量
//    ///有效范围: 1- 65535 ,  单位是千卡，Kcal
//    @property(nonatomic,assign)NSInteger calories;
//    ///步数
//    ///有效范围: 0 - 200000, 单位是步
//    @property(nonatomic,assign)NSInteger step;
//    /// 恢复时间
//    /// 时间格式是：HH:mm
//    @property(nonatomic,strong)NSString *recoveryTime;
//    /// 源数据
//    @property(nonatomic,strong)NSData *sourceData;
//    /// 初始化一个运动记录数据
//    /// @param data 数据内容
//    -(instancetype)initWithData:(NSData *)data;
//    /// 用于检查数据中的开始时间
//    /// @param data 文件数据
//    +(NSDate *)startDate:(NSData *)data;
//    @end
}

#pragma mark - Controls Method

- (IBAction)pauseBtnFunc:(id)sender {
    [[JLWearSync share] w_SportPauseWith:kJL_BLE_EntityM Block:^(BOOL succeed) {
        NSLog(@"w_SportPauseWith: %d", succeed);
    }];
}

- (void)pauseUI {
    self.isTimerRun = NO;
    [self.pauseBtn setHidden:YES];
    [self.continueBtn setHidden:NO];
    [self.endBtn setHidden:NO];
    [self.endBtnBackgroundView setHidden:NO];
}

- (IBAction)lockBtnFunc:(id)sender {
    if (!self.unlockSliderView) {
        self.unlockSliderView = [[JLUnlockSliderView alloc] initWithFrame:CGRectMake(0, 0, 295, 48)];
        self.unlockSliderView.layer.cornerRadius = self.unlockSliderContainerView.height / 2;
        [self.unlockSliderContainerView addSubview:self.unlockSliderView];
        self.unlockSliderView.text = kJL_TXT("滑动解锁");
        [self.unlockSliderView setThumbBeginImage:[UIImage imageNamed:@"run_icon_slide_nol-1"] finishImage:[UIImage imageNamed:@"run_icon_slide_nol-1"]];
        [self.unlockSliderView setColorForBackgroud:[JLColor colorWithString:@"#805BEB"] foreground:[UIColor clearColor] imageBackgroundColor:[UIColor clearColor] border:[UIColor clearColor] textColor:[UIColor whiteColor]];
        self.unlockSliderView.delegate = self;
    }
    [self.pauseBtn setHidden:YES];
    [self.continueBtn setHidden:YES];
    [self.endBtn setHidden:YES];
    [self.endBtnTipLabel setHidden:YES];
    [self.endBtnTipImageView setHidden:YES];
    [self.endBtnBackgroundView setHidden:YES];
    [self.lockBtn setHidden:YES];
    [self.goMapBtn setHidden:YES];
    [self.unlockSliderContainerView setHidden:NO];
}

- (IBAction)goMapBtnFunc:(id)sender {
    if (self.timer == nil) return;
    if (self.doingSportMapViewController)
    [self.navigationController pushViewController:self.doingSportMapViewController animated:YES];
}

- (IBAction)continueBtnFunc:(id)sender {
    [[JLWearSync share] w_SportContinueWith:kJL_BLE_EntityM Block:^(BOOL succeed) {
        NSLog(@"w_SportContinueWith: %d", succeed);
    }];
}

- (void)continueUI {
    self.isTimerRun = YES;
    [self.continueBtn setHidden:YES];
    [self.endBtn setHidden:YES];
    [self.endBtnTipLabel setHidden:YES];
    [self.endBtnTipImageView setHidden:YES];
    [self.endBtnBackgroundView setHidden:YES];
    [self.pauseBtn setHidden:NO];
}

- (IBAction)touchDownEndBtnFunc:(id)sender {
    if (self.timer == nil) return;
    [self startEndPressTimer];
}

- (IBAction)touchUpInsideEndBtnFunc:(id)sender {
    if (self.isLongPressEndBtn) {
        self.isLongPressEndBtn = NO;
        [self endTimerInvalidate];
    }
}

#pragma mark - Private Method

/////运动模式类型
//@property(nonatomic,assign)WatchSportType sportType;
///// 运动状态
//@property(nonatomic,assign)WatchSportStatus status;
/////运动Id
//@property(nonatomic,strong)NSData *sportID;
/////设备是否包含GPS
//@property(nonatomic,assign)BOOL  hasGPS;
/////心率模式
//@property(nonatomic,assign)WatchHeartRateType heartRateType;
/////建议实时数据读取时间间隔，单位：ms
//@property(nonatomic,assign)UInt16   interval;
/**
 *  查询固件当前运动信息
 */
- (void)setWearSyncInfoModel:(JLWearSyncInfoModel *)wearSyncInfoModel {
    if (wearSyncInfoModel == nil) return;
    _wearSyncInfoModel = wearSyncInfoModel;
    self.sportType = wearSyncInfoModel.sportType;
    NSLog(@"wearSyncInfoModel.sportID : %f", wearSyncInfoModel.sportID);
    self.sportID = wearSyncInfoModel.sportID;
    self.heartRateType = wearSyncInfoModel.heartRateType;
    self.requireRealTimeSportInfoInterval = (double)wearSyncInfoModel.interval / 1000;
    if (self.requireRealTimeSportInfoInterval <= 0 || self.requireRealTimeSportInfoInterval > 5) {
        self.requireRealTimeSportInfoInterval = 5.0f;
    }
    NSLog(@"requireRealTimeSportInfoInterval:%f", self.requireRealTimeSportInfoInterval);
    [self initializeDoingSportMapViewController];
    [self realTimeSportInfoTimerInvalidate];
    self.realTimeSportInfoTimer = [NSTimer timerWithTimeInterval:self.requireRealTimeSportInfoInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        [[JLWearSync share] w_requireRealTimeSportInfoWith:kJL_BLE_EntityM];
    }];
    [[NSRunLoop currentRunLoop] addTimer:_realTimeSportInfoTimer forMode:NSRunLoopCommonModes];
}

- (void)realTimeSportInfoTimerInvalidate {
    if (_realTimeSportInfoTimer) {
        [_realTimeSportInfoTimer invalidate];
        _realTimeSportInfoTimer = nil;
    }
}

/**
 * 设置当前运动类型
 */
- (void)setSportType:(WatchSportType)sportType {
    _sportType = sportType;
    [self setSportTypeInterface];
}

- (void)setSportTypeInterface {
    [self.titleLabel setHidden:NO];
    if (_sportType == WatchSportType_InDoor) {
        self.titleLabel.text = kJL_TXT("室内跑步");
        [self.goMapBtn setHidden:YES];
        [self.gpsIntensityContainerView setHidden:YES];
    } else {
        self.titleLabel.text = kJL_TXT("户外跑步");
        [self.goMapBtn setHidden:NO];
        [self.gpsIntensityContainerView setHidden:NO];
    }
}

/**
 *  初始化运动轨迹界面
 */
- (void)initializeDoingSportMapViewController {
    if ((self.sportType != WatchSportType_InDoor) && (self.doingSportMapViewController == nil) && self.sportID) {
        self.doingSportMapViewController = [[JLSportMapViewController alloc] init];
        NSLog(@"doingSportMapViewController.sportID : %f", self.sportID);
        self.doingSportMapViewController.sportID = self.sportID;
        [self.doingSportMapViewController initMapView];
    }
}

/**
 *  初始化运动结束按钮
 */
- (void)initializeEndBtnFunc {
    // 创建结束按钮动画轨迹
    self.endBtnBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.endBtn.width + 12, self.endBtn.height + 12)];
    [self.endBtn.superview addSubview:self.endBtnBackgroundView];
    [self.endBtn.superview sendSubviewToBack:self.endBtnBackgroundView];
    [self.endBtnBackgroundView centerWith:self.endBtn];
    [self.endBtnBackgroundView setHidden:YES];
    float centerX = self.endBtnBackgroundView.width / 2.0;
    float centerY = self.endBtnBackgroundView.height / 2.0;
    //半径
    float radius = (self.endBtnBackgroundView.width - PROGRESSLINEWIDTH) / 2.0;
    //创建贝塞尔路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY) radius:radius startAngle:(-0.5f * M_PI) endAngle:(1.5f * M_PI) clockwise:YES];
    //创建进度背景layer
    _progressBackgroundLayer = [CAShapeLayer layer];
    _progressBackgroundLayer.frame = self.endBtnBackgroundView.bounds;
    _progressBackgroundLayer.fillColor = [[UIColor clearColor] CGColor];
    //指定path的渲染颜色
    _progressBackgroundLayer.strokeColor = [[UIColor blackColor] CGColor];
    _progressBackgroundLayer.lineCap = kCALineCapSquare;//kCALineCapRound;
    _progressBackgroundLayer.lineWidth = PROGRESSLINEWIDTH;
    _progressBackgroundLayer.path = [path CGPath];
    _progressBackgroundLayer.strokeEnd = 1.0f;
    //设置渐变颜色
    CAGradientLayer *gradientLayer =  [CAGradientLayer layer];
    gradientLayer.frame = self.endBtnBackgroundView.bounds;
    // 渐变颜色
    [gradientLayer setColors:[NSArray arrayWithObjects:(id)[[JLColor colorWithString:@"#DEDEDE"] CGColor], (id)[[JLColor colorWithString:@"#DEDEDE"] CGColor],  nil]];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    [gradientLayer setMask:_progressBackgroundLayer];     //用progressLayer来截取渐变层
    [self.endBtnBackgroundView.layer addSublayer:gradientLayer];
    //创建进度背景layer
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = self.endBtnBackgroundView.bounds;
    _progressLayer.fillColor =  [[UIColor clearColor] CGColor];
    //指定path的渲染颜色
    _progressLayer.strokeColor  = [[UIColor blackColor] CGColor];
    _progressLayer.lineCap = kCALineCapSquare;//kCALineCapRound;
    _progressLayer.lineWidth = PROGRESSLINEWIDTH;
    _progressLayer.path = [path CGPath];
    _progressLayer.strokeEnd = 0.0f;
    //设置渐变颜色
    gradientLayer =  [CAGradientLayer layer];
    gradientLayer.frame = self.endBtnBackgroundView.bounds;
    // 渐变颜色
    [gradientLayer setColors:[NSArray arrayWithObjects:(id)[[JLColor colorWithString:@"#E47771"] CGColor], (id)[[JLColor colorWithString:@"#E47771"] CGColor],  nil]];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    [gradientLayer setMask:_progressLayer];     //用progressLayer来截取渐变层
    [self.endBtnBackgroundView.layer addSublayer:gradientLayer];
}

- (void)startTimer {
    if (_timer) return;
    self.sportTime = 0;
    self.isTimerRun = YES;
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer timerWithTimeInterval:1.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
        weakSelf.sportTime += 1;
        weakSelf.timeLabel.text = [NSString timeFormatted:weakSelf.sportTime];
        if (weakSelf.doingSportMapViewController) {
            [weakSelf.doingSportMapViewController setSportTime:weakSelf.sportTime];
        }
    }];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)timerInvalidate {
    if ([self.timer isValid]) {
        [self.timer invalidate];
        _timer = nil;
        [[JLAudioToolBox sharedInstance] playAudioWithFileUrlString:[[NSBundle mainBundle] pathForResource:@"stop" ofType:@"wav"]];
    }
}

- (void)startEndPressTimer {
    self.isLongPressEndBtn = YES;
    self.endTimeCount = 0;
    [self.endBtnTipLabel setHidden:NO];
    [self.endBtnTipImageView setHidden:NO];
    __weak typeof(self) weakSelf = self;
    self.endTimer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (!weakSelf.isLongPressEndBtn) {
            [weakSelf endTimerInvalidate];
            return ;
        }
        weakSelf.endTimeCount += TIMER_INTERVAL;
        weakSelf.progressLayer.strokeEnd = weakSelf.endTimeCount / LONGPRESS_MAX_TIME;
        [weakSelf.progressLayer removeAllAnimations];
        if (weakSelf.endTimeCount > LONGPRESS_MAX_TIME) {
            [weakSelf endTimerInvalidate];
            self.progressLayer.strokeEnd = 0;
            [self.progressLayer removeAllAnimations];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:kJL_TXT("提示") preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *endAction = [UIAlertAction actionWithTitle:kJL_TXT("结束运动") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [[JLCoreMotionManager sharedInstance] stopPedometerUpdates];
//                [weakSelf finishSportSpeedPerKm];
                if (kJL_BLE_EntityM == nil) {
                    [weakSelf finishLocalSport];
                } else {
//                    NSLog(@"[JLWearSync share] w_SportFinishWith");
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if ([weakSelf.navigationController.topViewController isKindOfClass:[JLSportDetailViewController class]]) {
                            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                        }
                    });
                    [[JLWearSync share] w_SportFinishWith:kJL_BLE_EntityM];
                }
            }];
            [alertController addAction:endAction];
            UIAlertAction *continueAction = [UIAlertAction actionWithTitle:kJL_TXT("继续运动") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self continueBtnFunc:self.continueBtn];
            }];
            [alertController addAction:continueAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
    [[NSRunLoop currentRunLoop] addTimer:_endTimer forMode:NSRunLoopCommonModes];
}

- (void)endTimerInvalidate {
    if ([self.endTimer isValid]) {
        [self.endBtnTipLabel setHidden:YES];
        [self.endBtnTipImageView setHidden:YES];
        [self.endTimer invalidate];
        self.endTimer = nil;
        self.progressLayer.strokeEnd = 0;
        [self.progressLayer removeAllAnimations];
        self.isLongPressEndBtn = NO;
    }
}

/**
 *  开始动画
 */
- (void)startAnimationWithCompletion:(void (^ __nullable)(void))completion {
    if (self.isPlayAnimation) return;
    self.isPlayAnimation = YES;
    self.animateImageView.image = [UIImage imageNamed:@"nub_3"];
    [self.animateImageView setHidden:NO];
    [[JLAudioToolBox sharedInstance] playAudioWithFileUrlString:[[NSBundle mainBundle] pathForResource:@"num_3" ofType:@"wav"]];
    NSLog(@"startAnimationWithCompletion3");
    [UIView animateWithDuration:1.0f animations:^{
        self.animateImageView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        NSLog(@"startAnimationWithCompletion2");
        [self.animateImageView setHidden:YES];
        self.animateImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.animateImageView.image = [UIImage imageNamed:@"nub_2"];
        [self.animateImageView setHidden:NO];
        [[JLAudioToolBox sharedInstance] playAudioWithFileUrlString:[[NSBundle mainBundle] pathForResource:@"num_2" ofType:@"wav"]];
        [UIView animateWithDuration:1.0f animations:^{
            self.animateImageView.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            NSLog(@"startAnimationWithCompletion1");
            [self.animateImageView setHidden:YES];
            self.animateImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.animateImageView.image = [UIImage imageNamed:@"nub_1"];
            [self.animateImageView setHidden:NO];
            [[JLAudioToolBox sharedInstance] playAudioWithFileUrlString:[[NSBundle mainBundle] pathForResource:@"num_1" ofType:@"wav"]];
            [UIView animateWithDuration:1.0f animations:^{
                self.animateImageView.transform = CGAffineTransformMakeScale(1, 1);
            } completion:^(BOOL finished) {
                NSLog(@"startAnimationWithCompletion0");
                [self.animateImageView setHidden:YES];
                self.animateImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                self.animateImageView.image = [UIImage imageNamed:@"nub_0"];
                [self.animateImageView setHidden:NO];
                [[JLAudioToolBox sharedInstance] playAudioWithFileUrlString:[[NSBundle mainBundle] pathForResource:@"go" ofType:@"wav"]];
                [UIView animateWithDuration:1.0f animations:^{
                    self.animateImageView.transform = CGAffineTransformMakeScale(1, 1);
                } completion:^(BOOL finished) {
                    NSLog(@"startAnimationWithCompletiongo");
                    [self.animateImageView setHidden:YES];
                    [[JLAudioToolBox sharedInstance] playAudioWithFileUrlString:[[NSBundle mainBundle] pathForResource:@"begin" ofType:@"wav"]];
                    completion();
                }];
            }];
        }];
    }];
}

- (void)noteDeviceChange:(NSNotification*)note {
    JLDeviceChangeType type = [note.object intValue];
    if (type == JLDeviceChangeTypeInUseOffline || type == JLDeviceChangeTypeBleOFF) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self timerInvalidate];
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }
}

#pragma mark - JLWearSyncProtocol

- (void)jlWearSyncRealTimeData:(JLWearSyncRealTimeModel * _Nonnull)model With:(JL_EntityM * _Nonnull)entity {
    //    /// 类型
    //    @property(nonatomic,assign)UInt8 type;
    //    /// 运动步数
    //    @property(nonatomic,assign)UInt32 sportStep;
    //    /// 运动距离，单位：0.01公里
    //    @property(nonatomic,assign)UInt16 distance;
    //    /// 运动时长：单位：秒
    //    @property(nonatomic,assign)UInt32 exerciseTime;
    //    /// 速度，单位0：0.01公里/小时，（倒数为配速，单位：秒/公里）
    //    @property(nonatomic,assign)UInt16 speed;
    //    /// 热量，单位：千卡
    //    @property(nonatomic,assign)UInt16 calories;
    //    /// 步频，单位：步/分钟
    //    @property(nonatomic,assign)UInt16 cadence;
    //    ///步幅,单位:厘米
    //    @property(nonatomic,assign)UInt16 stride;
    //    ///实时运动强度状态
    //    @property(nonatomic,assign)WatchExerciseIntensityType statusType;
    //    ///运动实时心率
    //    @property(nonatomic,assign)UInt8 heartRate;
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    if ([unitStr isEqualToString:@("英制")]){
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f", (double)((model.distance / 100) * 0.621)];
    } else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f", (double)model.distance / 100];
    }
    if ((model.exerciseTime > 0) && ((self.sportTime > (model.exerciseTime + 2)) || (self.sportTime < (model.exerciseTime - 2)))) self.sportTime = model.exerciseTime;
    self.timeLabel.text = [NSString timeFormatted:self.sportTime];
    self.speedLabel.text = [NSString stringWithFormat:@"%.2f", (double)model.speed / 100];
    self.calorieLabel.text = [NSString stringWithFormat:@"%d", model.calories];
    self.stepNumberLabel.text = [NSString stringWithFormat:@"%ld", (NSInteger)model.sportStep];
    self.stepFrequencyLabel.text = [NSString stringWithFormat:@"%d", model.cadence];
    self.heartRateLabel.text = [NSString stringWithFormat:@"%d", model.heartRate];
    self.doingSportMapViewController.calories = model.calories;
    self.doingSportMapViewController.speed = model.speed;
//    NSLog(@"实时运动：\n步幅,单位:厘米 : %d", model.stride);
    switch (model.statusType) {
        case WatchExercise_Level1:
            self.sportStatusView.backgroundColor = [JLColor colorWithString:@"#87C1EF"];
            self.sportStatusLabel.text = self.heartRateType == WatchHeartRate_Max ? kJL_TXT("热身") : kJL_TXT("有氧基础");
            break;
        case WatchExercise_Level2:
            self.sportStatusView.backgroundColor = [JLColor colorWithString:@"#92D58B"];
            self.sportStatusLabel.text = self.heartRateType == WatchHeartRate_Max ? kJL_TXT("燃脂") : kJL_TXT("有氧进阶");
            break;
        case WatchExercise_Level3:
            self.sportStatusView.backgroundColor = [JLColor colorWithString:@"#F6E970"];
            self.sportStatusLabel.text = self.heartRateType == WatchHeartRate_Max ? kJL_TXT("有氧耐力") : kJL_TXT("乳酸阈值");
            break;
        case WatchExercise_Level4:
            self.sportStatusView.backgroundColor = [JLColor colorWithString:@"#F9B478"];
            self.sportStatusLabel.text = self.heartRateType == WatchHeartRate_Max ? kJL_TXT("无氧耐力") : kJL_TXT("无氧基础");
            break;
        case WatchExercise_Level5:
            self.sportStatusView.backgroundColor = [JLColor colorWithString:@"#F07B71"];
            self.sportStatusLabel.text = self.heartRateType == WatchHeartRate_Max ? kJL_TXT("极限") : kJL_TXT("无氧进阶");
            break;
        default:
            self.sportStatusView.backgroundColor = [JLColor colorWithString:@"#BABABA"];
            self.sportStatusLabel.text = kJL_TXT("非运动");
            break;
    }
}

- (void)jlWearSyncStatusContiuneWith:(JL_EntityM * _Nonnull)entity {
    [self continueUI];
    [[JLAudioToolBox sharedInstance] playAudioWithFileUrlString:[[NSBundle mainBundle] pathForResource:@"resume" ofType:@"wav"]];
    [self.timer setFireDate:[NSDate date]];
    [self.realTimeSportInfoTimer setFireDate:[NSDate date]];
    self.doingSportMapViewController.isPauseSport = false;
}

- (void)jlWearSyncStatusPauseWith:(JL_EntityM * _Nonnull)entity {
    [self pauseUI];
    [[JLAudioToolBox sharedInstance] playAudioWithFileUrlString:[[NSBundle mainBundle] pathForResource:@"pause" ofType:@"wav"]];
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.realTimeSportInfoTimer setFireDate:[NSDate distantFuture]];
    self.doingSportMapViewController.isPauseSport = true;
}

- (void)jlWearSyncStopMotion:(JLWearSyncFinishModel * _Nonnull)model With:(JL_EntityM * _Nonnull)entity {
    [self timerInvalidate];
    __weak typeof(self) weakSelf = self;
    NSLog(@"jlWearSyncStopMotion sportid:%d", model.sportId);
    if (model.fileSize == 0) {
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kJL_TXT("提示") message:kJL_TXT("运动距离过短，将不保存记录备份") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:kJL_TXT("确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // nothing
        }];
        [alertController addAction:okAction];
        [JLApplicationDelegate.navigationController presentViewController:alertController animated:YES completion:nil];
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([weakSelf.navigationController.topViewController isKindOfClass:[JLSportDetailViewController class]]) {
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }
    });
    [[SyncDataManager share] syncSportRecordData:kJL_BLE_EntityM BySportId:model.sportId with:^(JLSportRecordModel * _Nullable model) {
        JL_SRM_DataFormat *firstData = model.dataArray.firstObject;
        NSTimeInterval startTimeInterval = [firstData.startDate timeIntervalSince1970];
        NSLog(@"[SyncDataManager share] syncSportRecordData, sportid:%f", startTimeInterval);
        if (startTimeInterval == self.sportID) {
            // 保存到数据表
            [JLSqliteSportRunningRecord s_checkoutWithSportID:startTimeInterval Result:^(JL_SportRecord_Chart * _Nullable chart) {
                if (chart) {
                    NSLog(@"JLSqliteSportRunningRecord s_checkoutWithSportID chart");
                    if  (weakSelf.sportHistoryDetailViewController && [weakSelf.navigationController.viewControllers containsObject:self.sportHistoryDetailViewController]) {
                        return;
                    }
                    JLSportHistoryDetailViewController *sportHistoryDetailVC = [[JLSportHistoryDetailViewController alloc] init];
                    sportHistoryDetailVC.chart = chart;
                    sportHistoryDetailVC.needPopToRootViewController = YES;
                    weakSelf.sportHistoryDetailViewController = sportHistoryDetailVC;
                    [weakSelf.navigationController pushViewController:sportHistoryDetailVC animated:YES];
                }
            }];
        }
    }];
}

#pragma mark - JLCoreMotionManagerDelegate

- (void)numberOfSteps:(NSNumber *)numberOfSteps distance:(NSNumber *)distance {
    if (_localDistance > distance.doubleValue || _localDistance == 0) {
        _localDistance += distance.doubleValue;
        _perKmStartTime = [NSDate date];
    } else {
        _localDistance = distance.doubleValue;
    }
    double currentPerKmIndex = _localDistance / 1000.0;
    if (currentPerKmIndex > _perKmIndex) {
        _perKmIndex = currentPerKmIndex;
        [JLSqliteSportSpeedPerKm s_insert:[[JL_SportSpeedPerKm alloc] initWithSportID:self.sportID withDistance:1000 withStartDate:_perKmStartTime withEndDate:[NSDate date]]];
    }
    if (kJL_BLE_EntityM == nil) {
        NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
        if ([unitStr isEqualToString:@("英制")]){
            self.distanceLabel.text = [NSString stringWithFormat:@"%.2f", (_localDistance / 1000)*0.621];
        }else{
            self.distanceLabel.text = [NSString stringWithFormat:@"%.2f", _localDistance / 1000];
        }
        self.stepNumberLabel.text = [NSString stringWithFormat:@"%@", numberOfSteps];
    }
}

/**
 *  结束运动的时候，计算剩下的配速
 */
- (void)finishSportSpeedPerKm {
    [JLCoreMotionManager sharedInstance].delegate = nil;
    double finalDistance = _localDistance - _perKmIndex * 1000;
    if (finalDistance < 0) {
        finalDistance = _localDistance;
    }
    if (finalDistance > 0) {
        [JLSqliteSportSpeedPerKm s_insert:[[JL_SportSpeedPerKm alloc] initWithSportID:self.sportID withDistance:finalDistance withStartDate:_perKmStartTime withEndDate:[NSDate date]]];
    }
}

#pragma mark - JLUnlockSliderViewDelegate

- (void)sliderEndValueChanged:(JLUnlockSliderView *)slider {
    if (slider.value == 1) {
        if (self.isTimerRun == YES) {
            [self continueUI];
        } else {
            [self pauseUI];
        }
        [self.lockBtn setHidden:NO];
        if (self.sportType != WatchSportType_InDoor)
        [self.goMapBtn setHidden:NO];
        [self.unlockSliderContainerView setHidden:YES];
    }
}

@end
