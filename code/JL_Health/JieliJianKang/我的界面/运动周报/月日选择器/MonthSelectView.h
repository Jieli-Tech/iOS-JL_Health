//
//  DateLabelView.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/23.
//

#import <UIKit/UIKit.h>
#import <TYCoreText/TYCoreText.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MonthSelectViewDelegate <NSObject>

-(void)monthLabelViewNextBtnAction;

-(void)monthLabelViewPreviousBtnAction;

@end

@interface MonthSelectView : UIView
@property(nonatomic,weak)id<MonthSelectViewDelegate> delegate;

-(void)setTitleLab:(NSString *)title SecondLabel:(NSString *)text;
-(void)setTextWithContainer:(TYTextContainer *)container;

@end

NS_ASSUME_NONNULL_END
