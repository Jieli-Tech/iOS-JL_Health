//
//  JLSportMapViewController.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/12.
//

#import "JLSportMapViewController.h"
#import "NSString+Time.h"
#import "JLLocationCoordinate2D.h"

#import "JLGPSIntensityManager.h"

@interface JLSportMapViewController ()  <MAMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieUnitLabel;

@property (strong, nonatomic) MAMapView *mapView;
@property (strong, nonatomic) NSMutableArray *userLocationCoordinateArr;

@end

@implementation JLSportMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.distanceUnitLabel.text = kJL_TXT("公里");
    self.distanceUnitLabel.numberOfLines=2;
    self.speedUnitLabel.text = kJL_TXT("配速");
    self.speedUnitLabel.numberOfLines=2;
    self.timeUnitLabel.text = kJL_TXT("运动时长");
    self.timeUnitLabel.numberOfLines=2;
    self.calorieUnitLabel.text = kJL_TXT("消耗（千卡）");
    self.calorieUnitLabel.numberOfLines=2;
    
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.layer.cornerRadius = 8;
    self.containerView.layer.cornerRadius = 12;
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.layer.shadowOffset = CGSizeMake(0, -4);
    self.containerView.layer.shadowOpacity = 0.2;
    self.containerView.layer.shadowRadius = 4;
    self.distanceLabel.textColor = [JLColor colorWithString:@"#805BEB"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)dealloc {
    NSLog(@"JLDoingSportMapViewController dealloc");
}

#pragma mark - Public Method

- (void)setSportTime:(CGFloat)sportTime {
    _sportTime = sportTime;
    self.timeLabel.text = [NSString timeFormatted:sportTime];
}

- (void)setCalories:(UInt16)calories {
    _calories = calories;
    self.calorieLabel.text = [NSString stringWithFormat:@"%d", calories];
}

- (void)setSpeed:(UInt16)speed {
    _speed = speed;
    self.speedLabel.text = [NSString stringWithFormat:@"%.2f", (double)speed / 100];
}

- (void)initMapView {
    if (self.mapView) return;
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.showsCompass = NO;
    self.mapView.delegate = self;
    self.mapView.allowsBackgroundLocationUpdates = YES;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.zoomLevel = 26;
    if ([[LanguageCls checkLanguage] isEqualToString:@"en-GB"] || [[LanguageCls checkLanguage] isEqualToString:@""]) {
        [self.mapView setMapLanguage:@(1)];
    } else {
        [self.mapView setMapLanguage:@(0)];
    }
    self.userLocationCoordinateArr = [NSMutableArray array];
//    self.sportLocationArr = [NSMutableArray array];
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    // 插入运动开始包
    [JLSqliteSportLocation s_insertStartPacketWithSportID:self.sportID];
//    [self.sportLocationArr addObject:[[JL_SportLocation alloc] initWithSportID:0 withType:JLSportLocationTypeStartPacket withLongitude:0 withLatitude:0 withSpeed:0 withDate:[NSDate date]]];
}

- (void)setIsPauseSport:(Boolean)isPauseSport {
    _isPauseSport = isPauseSport;
    if (!isPauseSport) {
        // 插入运动开始包
        [JLSqliteSportLocation s_insertStartPacketWithSportID:self.sportID];
//        [self.sportLocationArr addObject:[[JL_SportLocation alloc] initWithSportID:0 withType:JLSportLocationTypeStartPacket withLongitude:0 withLatitude:0 withSpeed:0 withDate:[NSDate date]]];
    }
    [self.userLocationCoordinateArr addObject:[NSObject new]];
}

#pragma mark - Controls Method

- (IBAction)backBtnFunc:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)gpsBtnFunc:(id)sender {
    if(self.mapView.userLocation.updating && self.mapView.userLocation.location) {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    }
}

#pragma mark - MAMapViewDelegate

- (void)mapViewRequireLocationAuth:(CLLocationManager *)locationManager {
    [locationManager requestAlwaysAuthorization];
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (_isPauseSport) return;
    if (updatingLocation && mapView == self.mapView) {
        JLLocationCoordinate2D *lastUserLocationCoordinate = self.userLocationCoordinateArr.lastObject;
        if (lastUserLocationCoordinate && [lastUserLocationCoordinate isKindOfClass:[JLLocationCoordinate2D class]]) {
            if (lastUserLocationCoordinate.latitude != userLocation.coordinate.latitude && lastUserLocationCoordinate.longitude != userLocation.coordinate.longitude) {
                CLLocationCoordinate2D coords[2];
                coords[0].latitude = lastUserLocationCoordinate.latitude;
                coords[0].longitude = lastUserLocationCoordinate.longitude;
                coords[1] = userLocation.coordinate;
                MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coords count:2];
                [self.mapView addOverlay:polyline];
                CLLocation *currentLocation = [JLGPSIntensityManager sharedInstance].currentLocation;
                
                // 插入轨迹数据表
                [JLSqliteSportLocation s_insert:[[JL_SportLocation alloc] initWithSportID:self.sportID withType:JLSportLocationTypeDataPacket withLongitude:userLocation.coordinate.longitude withLatitude:userLocation.coordinate.latitude withSpeed:currentLocation.speed withDate:[NSDate date]]];
//                [self.sportLocationArr addObject:[[JL_SportLocation alloc] initWithSportID:0 withType:JLSportLocationTypeDataPacket withLongitude:userLocation.coordinate.longitude withLatitude:userLocation.coordinate.latitude withSpeed:currentLocation.speed withDate:[NSDate date]]];
            } else {
                return;
            }
        }
        [self.userLocationCoordinateArr addObject:[[JLLocationCoordinate2D alloc] initWithLatitude:userLocation.location.coordinate.latitude withLongitude:userLocation.location.coordinate.longitude]];
    }
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]] && mapView == self.mapView)
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        polylineRenderer.lineWidth = 3.f;
        polylineRenderer.strokeColor = [JLColor colorWithString:@"#BF9CFF"];
        return polylineRenderer;
    }
    return nil;
}

@end
