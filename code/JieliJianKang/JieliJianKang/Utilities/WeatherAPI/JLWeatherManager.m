//
//  JLWeatherManager.m
//  JieliJianKang
//
//  Created by EzioChan on 2022/11/3.
//

#import "JLWeatherManager.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

@interface JLWeatherManager ()<AMapLocationManagerDelegate,AMapSearchDelegate>{
    AMapSearchAPI *search;
    AMapLocationManager *locationManager;
    JL_MSG_Weather *watchWeather;
    NSDictionary *windDirectionHash;
    NSDictionary *weatherHash;
    JL_EntityM *entity;
}

@end





@implementation JLWeatherManager

+(instancetype)share{
    static JLWeatherManager *w;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        w = [[JLWeatherManager alloc] init];
    });
    return w;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
        watchWeather = [[JL_MSG_Weather alloc] init];
        [AMapServices sharedServices].apiKey = @"a815e58ecb9ce231ccd730a5c503ff2d";
        [AMapLocationManager updatePrivacyAgree:true];
        [AMapLocationManager updatePrivacyShow:true privacyInfo:true];

        locationManager = [[AMapLocationManager alloc] init];
        [locationManager setAllowsBackgroundLocationUpdates:YES];
        [locationManager setDelegate:self];
        
        search = [[AMapSearchAPI alloc] init];
        search.delegate = self;
    }
    return self;
}


-(void)syncWeather:(JL_EntityM *)sendEntity{
    entity = sendEntity;
    [self getNowLocal];
}

-(void)getNowLocal{
    [locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [locationManager setPausesLocationUpdatesAutomatically:NO];
    [locationManager setAllowsBackgroundLocationUpdates:YES];
    locationManager.locationTimeout = 2;
    locationManager.reGeocodeTimeout = 2;
    
    [locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        if (error){
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        
        NSLog(@"get location:%@", location);
        
        if (regeocode)
        {
            NSLog(@"reGeocode:%@", regeocode);
            self->watchWeather.province = regeocode.province;
            self->watchWeather.city = regeocode.city;
            AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc] init];
            request.city = regeocode.adcode;
            request.type = AMapWeatherTypeLive;
            [self->search AMapWeatherSearch:request];
        }
    }];
}



- (void)amapLocationManager:(AMapLocationManager *)manager doRequireLocationAuth:(CLLocationManager *)locationManager
{
    [locationManager requestAlwaysAuthorization];
}

- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response{
    NSLog(@"AMapWeatherSearchResponse:%@",response);
    if(response.lives.count>0){
        AMapLocalWeatherLive *weather = response.lives[0];
        watchWeather.temperature = [weather.temperature intValue];
        watchWeather.humidity = [weather.humidity intValue];
        if([weather.windPower isEqualToString:@"≤3"]){
            watchWeather.wind = 3;
        }else{
            watchWeather.wind = [weather.windPower intValue];
        }
        watchWeather.code = [weatherHash[weather.weather] intValue];
        watchWeather.direction = [windDirectionHash[weather.windDirection] intValue];
        watchWeather.date = [NSDate new];
        BOOL value = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BT_WEATHER"] boolValue];
        if(value){
            [[JLWearable sharedInstance] w_syncWeather:watchWeather withEntity:entity result:^(BOOL succeed) {
                NSLog(@"执行同步天气结果：%d",succeed);
            }];
        }
    }
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}


-(void)initData{
    windDirectionHash = @{
        @"无风向":@(0),
        @"东北":@(1),
        @"东":@(2),
        @"东南":@(3),
        @"南":@(4),
        @"西南":@(5),
        @"西":@(6),
        @"西北":@(7),
        @"北":@(8),
        @"旋转不定":@(9)
    };
    weatherHash = @{
        @"晴":@(0),
        @"少云":@(1),
        @"晴间多云":@(2),
        @"多云":@(3),
        @"阴":@(4),
        @"有风":@(5),
        @"平静":@(6),
        @"微风":@(7),
        @"和风":@(8),
        @"清风":@(9),
        @"强风/劲风":@(10),
        @"疾风":@(11),
        @"大风":@(12),
        @"烈风":@(13),
        @"风暴":@(14),
        @"狂爆风":@(15),
        @"飓风":@(16),
        @"热带风暴":@(17),
        @"霾":@(18),
        @"中度霾":@(19),
        @"重度霾":@(20),
        @"严重霾":@(21),
        @"阵雨":@(22),
        @"雷阵雨":@(23),
        @"雷阵雨并伴有冰雹":@(24),
        @"小雨":@(25),
        @"中雨":@(26),
        @"大雨":@(27),
        @"暴雨":@(28),
        @"大暴雨":@(29),
        @"特大暴雨":@(30),
        @"强阵雨":@(31),
        @"强雷阵雨":@(32),
        @"极端降雨":@(33),
        @"毛毛雨/细雨":@(34),
        @"雨":@(35),
        @"小雨-中雨":@(36),
        @"中雨-大雨":@(37),
        @"大雨-暴雨":@(38),
        @"暴雨-大暴雨":@(39),
        @"大暴雨-特大暴雨":@(40),
        @"雨雪天气":@(40),
        @"雨夹雪":@(42),
        @"阵雨夹雪":@(43),
        @"冻雨":@(44),
        @"雪":@(45),
        @"阵雪":@(46),
        @"小雪":@(47),
        @"中雪":@(48),
        @"大雪":@(49),
        @"暴雪":@(50),
        @"小雪-中雪":@(51),
        @"中雪-大雪":@(52),
        @"大雪-暴雪":@(53),
        @"浮尘":@(54),
        @"扬沙":@(55),
        @"沙尘暴":@(56),
        @"强沙尘暴":@(57),
        @"龙卷风":@(58),
        @"雾":@(59),
        @"浓雾":@(60),
        @"强浓雾":@(61),
        @"轻雾":@(62),
        @"大雾":@(63),
        @"特强浓雾":@(64),
        @"热":@(65),
        @"冷":@(66),
        @"未知":@(67)
    };
    
}






@end
