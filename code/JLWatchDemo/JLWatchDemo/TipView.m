//
//  TipView.m
//  JLWatchDemo
//
//  Created by 杰理科技 on 2022/3/7.
//

#import "TipView.h"

@implementation TipView

static DFTips *loadingTp;

+(void)startLoadingView:(NSString*)text Delay:(NSTimeInterval)delay{
    [loadingTp removeFromSuperview];
    loadingTp = nil;
    
    UIWindow *win = [DFUITools getWindow];
    loadingTp = [DFUITools showHUDWithLabel:text onView:win
                                      color:[UIColor blackColor]
                             labelTextColor:[UIColor whiteColor]
                     activityIndicatorColor:[UIColor whiteColor]];
    [loadingTp hide:YES afterDelay:delay];
}

+(void)setLoadingText:(NSString*)text Delay:(NSTimeInterval)delay{
    loadingTp.labelText = text;
    [loadingTp hide:YES afterDelay:delay];
}

+(void)setLoadingText:(NSString *)text{
    loadingTp.labelText = text;
}

+(void)removeLoading{
    [loadingTp removeFromSuperview];
    loadingTp = nil;
}

@end
