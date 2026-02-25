//
//  JLSportHistoryDetailViewController.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/14.
//

#import "JLSportHistoryDetailViewController.h"
#import "JLSportHistoryUserSpeedTableViewCell.h"
#import "JLSportHistoryUserFootstepFrequencyTableViewCell.h"
#import "JLSportHistoryUserHeartRateTableViewCell.h"
#import "JLSportHistoryUserDataView.h"
#import "Masonry.h"
#import "JLPointAnnotation.h"
#import "JLSportTableViewModel.h"

@interface JLSportHistoryDetailViewController () <MAMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIView *tableHeaderContainerView;
@property (strong, nonatomic) MAMapView *mapView;
@property (strong, nonatomic) JLSportHistoryUserDataView *userDataView;

@property (strong, nonatomic) NSMutableArray<JLSportTableViewModel *> *sportTableViewModelArray;
@property (strong, nonatomic) NSMutableArray<JL_SRM_DataFormat *> *speedPerKMArray;

@end

@implementation JLSportHistoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    _sportTableViewModelArray = [NSMutableArray array];
    _speedPerKMArray = [NSMutableArray array];
    NSInteger totalHeartRate = 0;
    NSInteger heartRateCount = 0;
    NSInteger avgHeartRateCount = 0;
    // 每公里配速，平均心率
    for (JL_SRM_DataFormat *dataFormat in self.chart.dataArray) {
        if (dataFormat.type == JL_SRM_Pace) {
            [_speedPerKMArray addObject:dataFormat];
        }
        if (dataFormat.type == JL_SRM_Basic) {
            if (dataFormat.heartRate > 0) {
                totalHeartRate += dataFormat.heartRate;
                heartRateCount++;
            }
        }
    }
    if (heartRateCount > 0) {
        avgHeartRateCount = totalHeartRate / heartRateCount;
    }
    // 每公里配速
    [_sportTableViewModelArray addObject:[[JLSportTableViewModel alloc] initWithType:JLSportTableViewModelTypeSpeedPerKM]];
    // 步频
    [_sportTableViewModelArray addObject:[[JLSportTableViewModel alloc] initWithType:JLSportTableViewModelTypeStepFrequency]];
    // 心率
    [_sportTableViewModelArray addObject:[[JLSportTableViewModel alloc] initWithType:JLSportTableViewModelTypeHeartRate]];
    
    _userDataView = [JLSportHistoryUserDataView userDataView];
    [_userDataView setChart:_chart withAvgHeartRate:avgHeartRateCount];
    self.titleLabel.text = self.chart.modelType == WatchSportType_OutDoor ? kJL_TXT("户外跑步") : kJL_TXT("室内跑步");
    if ((self.chart.modelType == WatchSportType_OutDoor) && (self.chart.locationCoordsCount > 2)) {
        self.tableHeaderContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 625)];
        //设置高德地图
        self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.tableHeaderContainerView.width, 425)];
        self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        self.mapView.userInteractionEnabled = NO;
        [self.tableHeaderContainerView addSubview:self.mapView];
        [self.tableHeaderContainerView addSubview:_userDataView];
        [_userDataView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(10);
            make.height.mas_equalTo(242);
            make.trailing.mas_equalTo(-10);
            make.bottom.mas_equalTo(-10);
        }];
        if ([[LanguageCls checkLanguage] isEqualToString:@"en-GB"] || [[LanguageCls checkLanguage] isEqualToString:@""]) {
            [self.mapView setMapLanguage:@(1)];
        } else {
            [self.mapView setMapLanguage:@(0)];
        }
        self.mapView.delegate = self;
        self.mapView.showsCompass = NO;
        [self.mapView addOverlay:self.chart.polyline];
        [self.mapView setVisibleMapRect:self.chart.polyline.boundingMapRect animated:YES];
        // 设置大头针
        if (self.chart.firstSportLocation) {
            JLPointAnnotation *pointAnnotation = [[JLPointAnnotation alloc] init];
            CLLocationCoordinate2D coord;
            coord.latitude = self.chart.firstSportLocation.latitude;
            coord.longitude = self.chart.firstSportLocation.longitude;
            pointAnnotation.coordinate = coord;
            pointAnnotation.type = JLPointAnnotationTypeStart;
            [self.mapView addAnnotation:pointAnnotation];
        }
        if (self.chart.lastSportLocation) {
            JLPointAnnotation *pointAnnotation = [[JLPointAnnotation alloc] init];
            CLLocationCoordinate2D coord;
            coord.latitude = self.chart.lastSportLocation.latitude;
            coord.longitude = self.chart.lastSportLocation.longitude;
            pointAnnotation.coordinate = coord;
            pointAnnotation.type = JLPointAnnotationTypeEnd;
            [self.mapView addAnnotation:pointAnnotation];
        }
    } else {
        self.tableHeaderContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 260)];
        [self.tableHeaderContainerView addSubview:_userDataView];
        [_userDataView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(10);
            make.top.mas_equalTo(10);
            make.trailing.mas_equalTo(-10);
            make.bottom.mas_equalTo(-10);
        }];
    }
    self.tableHeaderContainerView.backgroundColor = [JLColor colorWithString:@"#F6F7F8"];
    self.tableView.tableHeaderView = self.tableHeaderContainerView;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [JLColor colorWithString:@"#F6F7F8"];
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(JLSportHistoryUserSpeedTableViewCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(JLSportHistoryUserSpeedTableViewCell.class)];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(JLSportHistoryUserFootstepFrequencyTableViewCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(JLSportHistoryUserFootstepFrequencyTableViewCell.class)];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(JLSportHistoryUserHeartRateTableViewCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(JLSportHistoryUserHeartRateTableViewCell.class)];
}

#pragma mark - IBAction Method

- (IBAction)backBtnFunc:(id)sender {
    if (self.needPopToRootViewController) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Private Method

- (void)setChart:(JL_SportRecord_Chart *)chart {
    _chart = chart;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sportTableViewModelArray.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    JLSportTableViewModel *sportTableViewModel = self.sportTableViewModelArray[indexPath.row];
    if (sportTableViewModel.type == JLSportTableViewModelTypeSpeedPerKM) {
        JLSportHistoryUserSpeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(JLSportHistoryUserSpeedTableViewCell.class)];
        if (cell == nil) {
            cell = [[JLSportHistoryUserSpeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(JLSportHistoryUserSpeedTableViewCell.class)];
        }
        cell.speedPerKMArray = self.speedPerKMArray;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;

    } else if (sportTableViewModel.type == JLSportTableViewModelTypeHeartRate) {
        JLSportHistoryUserHeartRateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(JLSportHistoryUserHeartRateTableViewCell.class)];
        if (cell == nil) {
            cell = [[JLSportHistoryUserHeartRateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(JLSportHistoryUserHeartRateTableViewCell.class)];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.chart = _chart;
        return cell;
    } else {
        JLSportHistoryUserFootstepFrequencyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(JLSportHistoryUserFootstepFrequencyTableViewCell.class)];
        if (cell == nil) {
            cell = [[JLSportHistoryUserFootstepFrequencyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(JLSportHistoryUserFootstepFrequencyTableViewCell.class)];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.chart = _chart;
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JLSportTableViewModel *sportTableViewModel = self.sportTableViewModelArray[indexPath.row];
    if (sportTableViewModel.type == JLSportTableViewModelTypeSpeedPerKM) {
        return 145 + self.speedPerKMArray.count * 30;
    } else if (sportTableViewModel.type == JLSportTableViewModelTypeHeartRate) {
        return 340 + self.chart.exerciseIntensArray.count * 46;
    }
    return 340;
}

#pragma mark - MAMapViewDelegate

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

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[JLPointAnnotation class]])
    {
        JLPointAnnotation *pointAnnotation = annotation;
        static NSString *reuseIndetifier = @"JLPointAnnotationReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
reuseIdentifier:reuseIndetifier];
        }
        if (pointAnnotation.type == JLPointAnnotationTypeStart) {
            annotationView.image = [UIImage imageNamed:@"run_icon_start_nol"];
        } else {
            annotationView.image = [UIImage imageNamed:@"run_icon_end_nol"];
        }
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
//        annotationView.centerOffset = CGPointMake(0, -18);
        return annotationView;
    }
    return nil;
}

@end
