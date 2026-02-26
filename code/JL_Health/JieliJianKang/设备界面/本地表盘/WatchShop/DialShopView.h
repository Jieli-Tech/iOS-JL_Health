//
//  MyTotalView.h
//  JieliJianKang
//
//  Created by 李放 on 2022/5/9.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>
#import <JL_BLEKit/JL_BLEKit.h>
#import "DialModel.h"
#import "JLPhoneUISetting.h"

NS_ASSUME_NONNULL_BEGIN

@interface DialShopView : UIView
@property (weak, nonatomic) UIViewController *superVC;

- (instancetype)initByFrame:(CGRect)frame IsPayment:(BOOL)isPayment;
-(void)loadServerWatchIsPayment:(BOOL)isPayment
                        SuperVC:(UIViewController *)superVC;
@end

NS_ASSUME_NONNULL_END
