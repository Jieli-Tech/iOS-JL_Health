//
//  OxygenDataView.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/31.
//

#import <UIKit/UIKit.h>
#import <TYCoreText/TYCoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface OxygenDataView : UIView

-(void)oxyLastTime:(NSDate *)date Value:(int)value;
-(void)oxyMaxValue:(int)max minValue:(int)min;
-(void)oxyMyMinValue:(int)min;
-(void)oxyMyMaxValue:(int)max;

@property(nonatomic,strong)TYAttributedLabel *lastLabel;
@property(nonatomic,strong)TYAttributedLabel *rangeLabel;

@end

NS_ASSUME_NONNULL_END
