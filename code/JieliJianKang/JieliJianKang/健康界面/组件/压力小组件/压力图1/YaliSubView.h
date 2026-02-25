//
//  YaliSubView.h
//  QCY_Demo
//
//  Created by 杰理科技 on 2021/3/23.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LB_GAP_R    1.2
#define MLB_GAP_R   0.3
#define kYALI_KEY_X @"YALI_KEY_X"
#define kYALI_KEY_Y @"YALI_KEY_Y"
#define kCOLOR_1    kDF_RGBA(241, 135, 83, 1)
#define kCOLOR_2    kDF_RGBA(103, 148, 230, 1)

NS_ASSUME_NONNULL_BEGIN

@class YaliSubView;
@protocol YaliSubViewDelegate <NSObject>
@optional
-(void)onYaliSubViewMovePoint:(CGPoint)point Type:(UInt8)type;
@end

@interface YaliSubView : UIView
@property(weak,nonatomic)id<YaliSubViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
