//
//  TizhongPlate.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/8.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>

#define kTizhong_GAP    10.0
#define kTizhong_SCALE  10.0

NS_ASSUME_NONNULL_BEGIN

@interface TizhongPlate : UIView
@property(nonatomic,assign)NSInteger startPiont;

- (instancetype)initWithIndex:(NSInteger)index WithHeight:(float)height;
- (UIImage *)snapshotImage;
@end

NS_ASSUME_NONNULL_END
