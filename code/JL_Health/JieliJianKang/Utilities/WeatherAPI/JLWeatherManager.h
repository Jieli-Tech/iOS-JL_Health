//
//  JLWeatherManager.h
//  JieliJianKang
//
//  Created by EzioChan on 2022/11/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLWeatherManager : NSObject

+(instancetype)share;

-(void)syncWeather:(JL_EntityM *)sendEntity;

@end

NS_ASSUME_NONNULL_END
