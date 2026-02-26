//
//  SportView.h
//  JieliJianKang
//
//  Created by 李放 on 2021/3/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SportView: UIView

@property (strong, nonatomic) NSArray *textArray;
@property (strong, nonatomic) NSArray *realDataArray;
@property (strong, nonatomic) NSArray *dataArray;
/// 线的阴影颜色
@property (nonatomic, strong) UIColor *lineShadowStartColor;
@property (nonatomic, strong) UIColor *lineShadowEndColor;
-(void)loadUI;

@end

NS_ASSUME_NONNULL_END
