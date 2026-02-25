//
//  SelectTitleBar.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/23.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DateType) {
    DateType_Day,
    DateType_Week,
    DateType_Month,
    DateType_Year
};

NS_ASSUME_NONNULL_BEGIN

@protocol SelectActionDelegate <NSObject>

-(void)barDidSelectIndex:(NSInteger)index;

@end

@interface SelectTitleBar : UIView
@property(nonatomic,strong)UIColor *selectColor;
@property(nonatomic,strong)UIColor *normalColor;
@property(nonatomic,strong)UIColor *bgColor;
@property(nonatomic,strong)UIColor *selectBgColor;
@property(nonatomic,strong)NSArray *textArray;
@property(nonatomic,weak)id<SelectActionDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
