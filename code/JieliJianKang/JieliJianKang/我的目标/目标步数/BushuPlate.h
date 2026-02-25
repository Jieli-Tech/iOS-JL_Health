//
//  BushuPlate.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/4.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>

#define kBushu_GAP    35.0
#define kBushu_SCALE  1.0

NS_ASSUME_NONNULL_BEGIN

@interface BushuPlate : UIView
@property(nonatomic,assign)NSInteger startPiont;

- (instancetype)initWithIndex:(NSInteger)index WithHeight:(float)height;
- (UIImage *)snapshotImage;

@end

NS_ASSUME_NONNULL_END
