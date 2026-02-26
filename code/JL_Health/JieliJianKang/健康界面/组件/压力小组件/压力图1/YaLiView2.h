//
//  YaLiView2.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/30.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"



NS_ASSUME_NONNULL_BEGIN

@protocol YaLiView2Delegate <NSObject>

-(void)YaLiView2ClickIndex:(long) index;

@end

@interface YaLiView2 : UIView

@property(weak,nonatomic)id<YaLiView2Delegate> delegate;

@property(strong,nonatomic)NSArray *dataArray;
@property(assign,nonatomic)NSInteger subIndex;
@property(strong,nonatomic)UIColor *lineColor;

-(void)loadUI;
@end

NS_ASSUME_NONNULL_END
