//
//  YaLiView.h
//  QCY_Demo
//
//  Created by 杰理科技 on 2021/3/22.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YaLiViewDelegate <NSObject>

-(void)YaLiViewClickIndex:(long) index;

@end

@interface YaLiView : UIView

@property(weak,nonatomic)id<YaLiViewDelegate> delegate;

@property(strong,nonatomic)NSArray *textArray;
@property(strong,nonatomic)NSArray *dateArray;
@property(strong,nonatomic)NSArray *temDateArray;
@property(assign,nonatomic) int type;
@property(strong,nonatomic)NSArray *dataArray;
@property(assign,nonatomic)NSInteger subIndex;
@property(strong,nonatomic)UIColor *nColor;
@property(strong,nonatomic)UIColor *pColor;
@property(assign,nonatomic)float   gap_L;
@property(assign,nonatomic)float   gap_R;
-(void)loadUI;
-(void)resetUI;
@end

NS_ASSUME_NONNULL_END
