//
//  JLTestGpsViewController.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/9.
//

#import "JLTestGpsViewController.h"

@interface JLTestGpsViewController () <CLLocationManagerDelegate>

@property (nonatomic ,strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation JLTestGpsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.textView setEditable:NO];
    [self initializeLocationService];
}

- (void)initializeLocationService {
    // 初始化定位管理器
    _locationManager = [[CLLocationManager alloc] init];
    // 设置代理
    _locationManager.delegate = self;
    // 设置定位精确度到米
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    // 设置过滤器为无
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    // 开始定位
    // 取得定位权限，有两个方法，取决于你的定位使用情况
    // 一个是requestAlwaysAuthorization，一个是requestWhenInUseAuthorization
    [_locationManager requestWhenInUseAuthorization];//这句话ios8以上版本使用。
    [_locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations.lastObject;
    if (location) {
//        kJLLog(JLLOG_DEBUG, @"horizontalAccuracy: %f======verticalAccuracy: %f======speedAccuracy: %f", location.horizontalAccuracy, location.verticalAccuracy, location.speedAccuracy);
        NSString *result = [NSString stringWithFormat:@"%@horizontalAccuracy: %f======verticalAccuracy: %f======speedAccuracy: %f\n", self.textView.text, location.horizontalAccuracy, location.verticalAccuracy, location.speedAccuracy];
        self.textView.text = result;
    }
}

@end
