//
//  JLSportLocationPermissionView.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/25.
//

#import "JLSportLocationPermissionView.h"
#import <QuartzCore/QuartzCore.h>

@interface JLSportLocationPermissionView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueStartBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation JLSportLocationPermissionView

+ (instancetype)sportLocationPermissionView {
    JLSportLocationPermissionView *sportLocationPermissionView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([JLSportLocationPermissionView class]) owner:nil options:nil] lastObject];
    [sportLocationPermissionView.settingBtn.layer setMasksToBounds:YES];
    sportLocationPermissionView.settingBtn.layer.cornerRadius = 20;
    sportLocationPermissionView.settingBtn.backgroundColor = [JLColor colorWithString:@"#805BEB"];
    sportLocationPermissionView.settingBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
    sportLocationPermissionView.settingBtn.titleLabel.textColor = [JLColor colorWithString:@"#4B4B4B"];
    [sportLocationPermissionView.continueStartBtn.layer setMasksToBounds:YES];
    sportLocationPermissionView.continueStartBtn.layer.cornerRadius = 20;
    sportLocationPermissionView.continueStartBtn.backgroundColor = [JLColor colorWithString:@"#919191" alpha:0.16f];
    sportLocationPermissionView.continueStartBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
    sportLocationPermissionView.continueStartBtn.titleLabel.textColor = [JLColor colorWithString:@"#FFFFFF"];
    sportLocationPermissionView.titleLabel.text = kJL_TXT("开启位置权限");
    sportLocationPermissionView.tipsLabel.text = kJL_TXT("使用运动轨迹、地图相关功能，需授权「设备位置信息」");
    sportLocationPermissionView.continueStartBtn.titleLabel.text = kJL_TXT("继续运动");
    sportLocationPermissionView.settingBtn.titleLabel.text = kJL_TXT("去设置");
    sportLocationPermissionView.cancelBtn.titleLabel.text = kJL_TXT("暂不运动");
    sportLocationPermissionView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    sportLocationPermissionView.contentView.layer.cornerRadius = 16;
    return sportLocationPermissionView;
}

- (IBAction)cancelBtnFunc:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cancelBtnFunction)]) {
        [self.delegate cancelBtnFunction];
    }
}

- (IBAction)continueStartBtnFunc:(id)sender {
    if ([self.delegate respondsToSelector:@selector(continueStartBtnFunction)]) {
        [self.delegate continueStartBtnFunction];
    }
}

- (IBAction)settingBtnFunc:(id)sender {
    if ([self.delegate respondsToSelector:@selector(settingBtnFunction)]) {
        [self.delegate settingBtnFunction];
    }
}

@end
