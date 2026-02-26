//
//  DateLabelView.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/23.
//

#import <UIKit/UIKit.h>
#import <TYCoreText/TYCoreText.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DateLabelViewDelegate <NSObject>

-(void)dateLabelViewNextBtnAction;

-(void)dateLabelViewPreviousBtnAction;

@end

@interface DateLabelView : UIView
@property(nonatomic,weak)id<DateLabelViewDelegate> delegate;

@property(nonatomic,strong) UIButton *leftBtn;
@property(nonatomic,strong) UIButton *rightBtn;

-(void)setTitleLab:(NSString *)title SecondLabel:(NSString *)text;
-(void)setSecondLab:(NSString *)text;
-(void)setTextWithContainer:(TYTextContainer *)container;

@end

NS_ASSUME_NONNULL_END
