//
//  JLSportHistoryListTableViewCell.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/13.
//

#import "JLSportHistoryListTableViewCell.h"
#import "NSString+Time.h"
#import "JLPointAnnotation.h"

@interface JLSportHistoryListTableViewCell () <MAMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *sportCateImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportCateLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceUnitLabel;

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieLabel;
@property (weak, nonatomic) IBOutlet UIView *mapContainerView;
@property (strong, nonatomic) MAMapView *mapView;

@end

@implementation JLSportHistoryListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)configureCell {
    self.containerView.layer.cornerRadius = 8;
    self.sportCateLabel.layer.cornerRadius = 20 / 2;
    self.sportCateLabel.layer.borderColor = [JLColor colorWithString:@"#805BEB"].CGColor;
    self.sportCateLabel.layer.borderWidth = 0.5;
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setChart:(JL_SportRecord_Chart *)chart {
    _chart = chart;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:chart.sport_id];
    self.dateLabel.text = [NSString stringWithFormat:@"%@ %@", date.toYYYYMMdd, date.toHHmm];
    NSString *type = kJL_TXT("户外");
    switch (chart.modelType) {
        case 0x01:
            self.sportCateImageView.image = [UIImage imageNamed:@"record_icon_outdoor_nol"];
            type = kJL_TXT("户外");
            break;
        default:
            self.sportCateImageView.image = [UIImage imageNamed:@"record_icon_indoor_nol"];
            type = kJL_TXT("室内");
            break;
    }
    self.sportCateLabel.text = type;
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    if ([unitStr isEqualToString:@("英制")]) {
        self.distanceUnitLabel.text = kJL_TXT("英里");
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f", (double)((chart.distance / 100)*0.621)];
    } else {
        self.distanceUnitLabel.text = kJL_TXT("公里");
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f", (double)(chart.distance / 100)];
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%@", [NSString timeFormatted:chart.duration]];
    self.speedLabel.text = [chart getSpeed];
    self.calorieLabel.text = [NSString stringWithFormat:@"%ld", (long)chart.calories];
    [self.mapContainerView setHidden:YES];
    [_mapView removeFromSuperview];
    _mapView = nil;
    
    if ((chart.modelType == 0x01) && (chart.locationCoordsCount > 2)) {
        //设置高德地图
        [self.mapContainerView setHidden:NO];
        MAMapView *mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.mapContainerView.width, self.mapContainerView.height)];
        _mapView = mapView;
        mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        mapView.userInteractionEnabled = NO;
        mapView.showsCompass = NO;
        mapView.logoCenter = CGPointMake(100, -100);
        [self.mapContainerView addSubview:mapView];
        if ([[LanguageCls checkLanguage] isEqualToString:@"en-GB"] || [[LanguageCls checkLanguage] isEqualToString:@""]) {
            [self.mapView setMapLanguage:@(1)];
        } else {
            [self.mapView setMapLanguage:@(0)];
        }
        mapView.delegate = self;
        [mapView addOverlay:chart.polyline];
        [mapView setVisibleMapRect:chart.polyline.boundingMapRect animated:NO];
        // 设置大头针
        if (self.chart.firstSportLocation) {
            JLPointAnnotation *pointAnnotation = [[JLPointAnnotation alloc] init];
            CLLocationCoordinate2D coord;
            coord.latitude = self.chart.firstSportLocation.latitude;
            coord.longitude = self.chart.firstSportLocation.longitude;
            pointAnnotation.coordinate = coord;
            pointAnnotation.type = JLPointAnnotationTypeStart;
            [mapView addAnnotation:pointAnnotation];
        }
        if (self.chart.lastSportLocation) {
            JLPointAnnotation *pointAnnotation = [[JLPointAnnotation alloc] init];
            CLLocationCoordinate2D coord;
            coord.latitude = self.chart.lastSportLocation.latitude;
            coord.longitude = self.chart.lastSportLocation.longitude;
            pointAnnotation.coordinate = coord;
            pointAnnotation.type = JLPointAnnotationTypeEnd;
            [mapView addAnnotation:pointAnnotation];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
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
