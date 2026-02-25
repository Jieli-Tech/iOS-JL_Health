//
//  YaliCircleView.h
//  QCY_Demo
//
//  Created by 杰理科技 on 2021/3/29.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface YaliCircleView : UIView
@property(assign,nonatomic)float value_0;
@property(assign,nonatomic)float value_1;
@property(assign,nonatomic)float value_2;
@property(assign,nonatomic)float value_3;

-(instancetype)initByFrame:(CGRect)frame;
-(void)updateUI;

@end

NS_ASSUME_NONNULL_END
