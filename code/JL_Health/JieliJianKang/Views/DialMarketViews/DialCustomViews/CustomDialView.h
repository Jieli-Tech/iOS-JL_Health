//
//  CustomDialView.h
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/20.
//

#import <UIKit/UIKit.h>
#import "CustomDialEditVC.h"

NS_ASSUME_NONNULL_BEGIN
@class CustomDialCellModel;

@protocol CustomDialDelegate <NSObject>

-(void)pushBackAction:(CustomDialEditVC *)vc;

-(void)hiddenAction;

-(void)installDial:(CustomDialCellModel *)model;

@end

@interface CustomDialView : UIView

@property(nonatomic,weak)id<CustomDialDelegate>delegate;

-(void)handleReloadData;

@end

NS_ASSUME_NONNULL_END
