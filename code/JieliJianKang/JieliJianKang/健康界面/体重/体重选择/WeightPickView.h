//
//  WeightPickView.h
//  JieliJianKang
//
//  Created by kaka on 2021/2/23.
//

#import <UIKit/UIKit.h>

#define kWeightPickViewGAP  30.0

@class WeightPickView;
@protocol WeightPickViewDelegate <NSObject>
@optional
-(void)onWeightPickView:(WeightPickView*)view didChange:(NSInteger)pickPoint;
-(void)onWeightPickView:(WeightPickView*)view didSelect:(NSInteger)pickPoint;
@end

@interface WeightPickView : UIView
@property(nonatomic,weak)id<WeightPickViewDelegate>delegate;
-(instancetype)initWithFrame:(CGRect)frame
                   StartPoint:(NSInteger)sPoint
                     EndPoint:(NSInteger)ePoint;

-(void)setWeightPoint:(NSInteger)point;
@end
