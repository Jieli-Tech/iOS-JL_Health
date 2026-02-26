//
//  JLGPSIntensityManager.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JLPSSignalStrength)
{
    JLPSSignalStrengthUnknow = 0,    //0 信号强度未知
    JLPSSignalStrengthWeak = 1,      //1 信号弱
    JLPSSignalStrengthSimple = 2,    //2 信号普通
    JLPSSignalStrengthStrong = 3,    //3 信号强
};

@protocol JLGPSIntensityManagerDelegate <NSObject>

- (void)gpsIntensityManagerDidReceiveSignalStrength:(JLPSSignalStrength)gpsSignalStrength;

@end

typedef void(^CLPlacemarkBlock)(CLPlacemark *placemark);

@interface JLGPSIntensityManager : NSObject

@property(weak, nonatomic, nullable) id<JLGPSIntensityManagerDelegate> delegate;
@property(strong, nonatomic, nullable) CLLocation *currentLocation;

+ (instancetype)sharedInstance;
+ (void)reverseGeocodeLocation:(CLLocation *)location withCallback:(CLPlacemarkBlock)block;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (id)copy NS_UNAVAILABLE;
- (id)mutableCopy NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
