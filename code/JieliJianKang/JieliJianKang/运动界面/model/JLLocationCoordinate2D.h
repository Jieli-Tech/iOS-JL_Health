//
//  JLLocationCoordinate2D.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLLocationCoordinate2D : NSObject

@property (assign, nonatomic)CLLocationDegrees latitude;
@property (assign, nonatomic)CLLocationDegrees longitude;

- (instancetype)initWithLatitude:(CLLocationDegrees)latitude withLongitude:(CLLocationDegrees)longitude;

@end

NS_ASSUME_NONNULL_END
