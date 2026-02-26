//
//  JLWeatherHttp.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/17.
//

#import "JLWeatherHttp.h"
#import "JLGPSIntensityManager.h"

@interface JLWeatherHttp ()

@end

@implementation JLWeatherHttp

+ (void)syncCurrentLocationWeatherToDevice {
    if (kJL_BLE_EntityM == nil) {
        return;
    }
    [JLGPSIntensityManager sharedInstance];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [JLGPSIntensityManager reverseGeocodeLocation:[JLGPSIntensityManager sharedInstance].currentLocation withCallback:^(CLPlacemark * _Nonnull placemark) {
            NSString *accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
            NSDictionary *headers = @{@"content-type": @"application/json",
                                      @"jwt-token": accessToken?:@"",
                                      @"cache-control": @"no-cache"};
            NSDictionary *parameter = @{@"province": [NSString stringWithFormat:@"%@", placemark.administrativeArea], @"city": [NSString stringWithFormat:@"%@", placemark.locality]};
            NSString *url = [NSString stringWithFormat:@"%@/health/v1/api/open/weather", BaseURL];
//            NSLog(@"weather location : %@, %@", placemark.administrativeArea, placemark.locality);
            [manager GET:url parameters:parameter headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable responseObject) {
//                NSLog(@"weather success : %@", responseObject);
                if ([[responseObject allKeys] containsObject:@"data"]) {
                    NSDictionary *dataDict = responseObject[@"data"];
                    // 获取当天数据
                    if (![dataDict isKindOfClass:[NSNull class]] && [[dataDict allKeys] containsObject:@"observe"]) {
                        NSDictionary *observeDict = responseObject[@"observe"];
                        // 发送到设备
                        JL_MSG_Weather *weather = [JL_MSG_Weather new];
                        weather.province = [NSString stringWithFormat:@"%@", placemark.administrativeArea];
                        weather.city = [NSString stringWithFormat:@"%@", placemark.locality];
                        if ([[observeDict allKeys] containsObject:@"weather"]) {
                            weather.code = [self weatherTypeFromString:[observeDict[@"weather"] stringValue]];
                        }
                        if ([[observeDict allKeys] containsObject:@"degree"]) {
                            weather.temperature = [observeDict[@"degree"] integerValue];
                        }
                        if ([[observeDict allKeys] containsObject:@"humidity"]) {
                            weather.humidity = [observeDict[@"humidity"] integerValue];
                        }
                        if ([[observeDict allKeys] containsObject:@"wind_direction"]) {
                            weather.direction = [self wDirectionTypeFromInteger:[observeDict[@"wind_direction"] integerValue]];
                        }
                        if ([[observeDict allKeys] containsObject:@"wind_power"]) {
                            weather.wind = [observeDict[@"wind_power"] integerValue];
                        }
                        weather.date = [NSDate date];
                        [[JLWearable sharedInstance] w_syncWeather:weather withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
//                            NSLog(@"weather sync to device isSuccess:%d", succeed);
                        }];
                    }
                }
            } failure:nil];
        }];
        
    });
}

+ (JLWeatherType)weatherTypeFromString:(NSString *)string {
    if ([string isEqualToString:@"晴"]) {
        return JLWeatherTypeSunny;
    } else if ([string isEqualToString:@"少云"]) {
        return JLWeatherTypeCloudLess;
    } else if ([string isEqualToString:@"晴间多云"]) {
        return JLWeatherTypePartlyCloudy;
    } else if ([string isEqualToString:@"多云"]) {
        return JLWeatherTypeCloudiness;
    } else if ([string isEqualToString:@"阴"]) {
        return JLWeatherTypeOvercastSky;
    } else if ([string isEqualToString:@"有风/和风/清风/微风"]) {
        return JLWeatherTypeBreeze;
    } else if ([string isEqualToString:@"平静"]) {
        return JLWeatherTypeCalmWind;
    } else if ([string isEqualToString:@"大风/强风/劲风/疾风"]) {
        return JLWeatherTypeHighWind;
    } else if ([string isEqualToString:@"飓风/狂爆风"]) {
        return JLWeatherTypeHurricane;
    } else if ([string isEqualToString:@"热带风暴/风暴"]) {
        return JLWeatherTypeTropicalStorm;
    } else if ([string isEqualToString:@"霾/中度霾/重度霾/严重霾"]) {
        return JLWeatherTypeHaze;
    } else if ([string isEqualToString:@"阵雨"]) {
        return JLWeatherTypeShower;
    } else if ([string isEqualToString:@"雷阵雨"]) {
        return JLWeatherTypeThunderShower;
    } else if ([string isEqualToString:@"雷阵雨并伴有冰雹"]) {
        return JLWeatherTypeHallThunderShower;
    } else if ([string isEqualToString:@"雨/小雨/毛毛雨/细雨/小雨-中雨"]) {
        return JLWeatherTypeLightRain;
    } else if ([string isEqualToString:@"中雨/中雨-大雨"]) {
        return JLWeatherTypeModerateRain;
    } else if ([string isEqualToString:@"大雨/大雨-暴雨"]) {
        return JLWeatherTypeHeavyRain;
    } else if ([string isEqualToString:@"暴雨/暴雨-大暴雨"]) {
        return JLWeatherTypeDownpour;
    } else if ([string isEqualToString:@"大暴雨/大暴雨-特大暴雨"]) {
        return JLWeatherTypeExtraordinaryRainstorm;
    } else if ([string isEqualToString:@"特大暴雨"]) {
        return JLWeatherTypeHeavyDownpour;
    } else if ([string isEqualToString:@"强阵雨"]) {
        return JLWeatherTypeStrongRainShower;
    } else if ([string isEqualToString:@"强雷阵雨"]) {
        return JLWeatherTypeStrongThunderShower;
    } else if ([string isEqualToString:@"极端降雨"]) {
        return JLWeatherTypeExtremeRainfall;
    } else if ([string isEqualToString:@"雨夹雪/阵雨夹雪/冻雨/雨雪天气"]) {
        return JLWeatherTypeRainySnowy;
    } else if ([string isEqualToString:@"雪"]) {
        return JLWeatherTypeSnowy;
    } else if ([string isEqualToString:@"阵雪"]) {
        return JLWeatherTypeSnowShower;
    } else if ([string isEqualToString:@"小雪/小雪-中雪"]) {
        return JLWeatherTypeLightSnow;
    } else if ([string isEqualToString:@"中雪/中雪-大雪"]) {
        return JLWeatherTypeModerateSnow;
    } else if ([string isEqualToString:@"大雪/大雪-暴雪"]) {
        return JLWeatherTypeHeavySnow;
    } else if ([string isEqualToString:@"暴雪"]) {
        return JLWeatherTypeSnowstorm;
    } else if ([string isEqualToString:@"浮尘"]) {
        return JLWeatherTypeDust;
    } else if ([string isEqualToString:@"扬沙"]) {
        return JLWeatherTypeblowingSand;
    } else if ([string isEqualToString:@"沙尘暴"]) {
        return JLWeatherTypedustStorm;
    } else if ([string isEqualToString:@"强沙尘暴"]) {
        return JLWeatherTypeSevereSandstorm;
    } else if ([string isEqualToString:@"龙卷风"]) {
        return JLWeatherTypeTornado;
    } else if ([string isEqualToString:@"雾/轻雾/浓雾/强浓雾/特强浓雾"]) {
        return JLWeatherTypeFog;
    } else if ([string isEqualToString:@"未知2"]) {
        return JLWeatherTypeUnknown1;
    } else if ([string isEqualToString:@"冷"]) {
        return JLWeatherTypeCold;
    } else {
        return JLWeatherTypeUnknow;
    }
}

+ (JLWindDirectionType)wDirectionTypeFromInteger:(NSInteger)integer {
    if (integer == 1) {
        return JLWindDirectionTypeEast;
    } else if (integer == 2) {
        return JLWindDirectionTypeSouth;
    } else if (integer == 3) {
        return JLWindDirectionTypeWest;
    } else if (integer == 4) {
        return JLWindDirectionTypeNorth;
    } else if (integer == 5) {
        return JLWindDirectionTypeEastSouth;
    } else if (integer == 6) {
        return JLWindDirectionTypeEastNorth;
    } else if (integer == 7) {
        return JLWindDirectionTypeWestNorth;
    } else if (integer == 8) {
        return JLWindDirectionTypeWestSouth;
    } else if (integer == 9) {
        return JLWindDirectionTypeUnknow;
    } else {
        return JLWindDirectionTypeNone;
    }
}

@end
