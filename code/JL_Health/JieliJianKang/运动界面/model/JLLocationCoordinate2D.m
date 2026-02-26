//
//  JLLocationCoordinate2D.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/17.
//

#import "JLLocationCoordinate2D.h"

@implementation JLLocationCoordinate2D

- (instancetype)initWithLatitude:(CLLocationDegrees)latitude withLongitude:(CLLocationDegrees)longitude; {
    self = [super init];
    if (self) {
        self.latitude = latitude;
        self.longitude = longitude;
    }
    return self;
}

@end
