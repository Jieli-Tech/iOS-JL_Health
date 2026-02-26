//
//  JLAnimationTool.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/31.
//

#import "JLAnimationTool.h"

@implementation JLAnimationTool

static NSMutableArray *imageArray = nil;
+(void)loadImageResource{
    imageArray = [NSMutableArray new];
    for (int i = 0; i <= 61; i++) {
        NSString *txt = @"";
        if (i < 10) {
            txt = [NSString stringWithFormat:@"search_0%d.png",i];
        }else{
            txt = [NSString stringWithFormat:@"search_%d.png",i];
        }
        
        NSString *path = [DFFile find:txt];
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfFile:path
                                                                     options:NSDataReadingMappedIfSafe
                                                                       error:nil]];
        [imageArray addObject:img];
    }
}

+(void)unloadImageResource{
    [imageArray removeAllObjects];
    [self removeView];
}

+(void)removeView{
    [searchImage stopAnimating];
    [searchImage removeFromSuperview];
    searchImage = nil;
    
    [animationView removeFromSuperview];
    animationView = nil;
}


static UIView *animationView = nil;
static UIImageView *searchImage = nil;
+(void)startSearchAnimationTime:(float)time{
    if (animationView) {
        [animationView removeFromSuperview];
        animationView = nil;
    }
    
    if (searchImage) {
        [searchImage removeFromSuperview];
        searchImage = nil;
    }
    float sW = [DFUITools screen_2_W];
    float sH = [DFUITools screen_2_H];
    UIWindow *win = [DFUITools getWindow];
    animationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sW, sH)];
    animationView.backgroundColor = [UIColor clearColor];
    [win addSubview:animationView];

//    UILabel *label = [[UILabel alloc] init];
//    label.frame = CGRectMake(sW/2-150/2,kJL_HeightNavBar+48,180,28);
//    label.numberOfLines = 0;
//    [animationView addSubview:label];
//    label.contentMode = UIViewContentModeCenter;
//    label.font =  [UIFont fontWithName:@"PingFangSC" size: 20];
//    label.text =  kJL_TXT("正在搜索可用设备");
//    label.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    searchImage = [UIImageView new];
    searchImage.center = CGPointMake(sW/2.0, sH/2.0);
    searchImage.contentMode = UIViewContentModeCenter;
    [animationView addSubview:searchImage];
    
    searchImage.animationImages = imageArray;
    searchImage.animationDuration = 2.0;
    [searchImage startAnimating];
    
    [JL_Tools delay:time Task:^{
        [self removeView];
    }];
}

@end
