//
//  BirthDayInfoView.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol BirthDayInfoDelegate <NSObject>

-(void)birthdayAction:(NSString *)birthYear Month:(NSString *)birthMonth Day:(NSString *)day SelectDate:(NSString *)date;

@end
@interface BirthDayInfoView : UIView
@property(nonatomic,weak)id<BirthDayInfoDelegate> delegate;
@property(nonatomic, assign) NSString *selectValue;
@property(strong, nonatomic) UILabel  *labelTitleName;   

@end

NS_ASSUME_NONNULL_END
