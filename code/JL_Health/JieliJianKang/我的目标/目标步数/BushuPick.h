//
//  BushuPick.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/4.
//

#import <UIKit/UIKit.h>

#define kBushuPickGAP  40.0


NS_ASSUME_NONNULL_BEGIN


@class BushuPick;
@protocol BushuPickDelegate <NSObject>
@optional
-(void)onBushuPick:(BushuPick*)view didChange:(NSInteger)point;
-(void)onBushuPick:(BushuPick*)view didSelect:(NSInteger)point;
@end

@interface BushuPick : UIView
@property(nonatomic,weak)id<BushuPickDelegate>delegate;
-(instancetype)initWithFrame:(CGRect)frame
                   StartPoint:(NSInteger)sPoint
                     EndPoint:(NSInteger)ePoint;

-(void)setBushuPoint:(NSInteger)point;
@end

NS_ASSUME_NONNULL_END
