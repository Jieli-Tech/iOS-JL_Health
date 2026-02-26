//
//  SelectWeekView.h
//  ysyy_pat
//
//  Created by apple on 2016/10/11.
//  Copyright © 2016年 张博. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height

typedef void(^SelectWeekBlock)(NSString *weekStr);

@interface SelectWeekView : UIView

@property (nonatomic, copy) SelectWeekBlock selectBlock;

- (void)show;

- (void)dismiss;

@end
