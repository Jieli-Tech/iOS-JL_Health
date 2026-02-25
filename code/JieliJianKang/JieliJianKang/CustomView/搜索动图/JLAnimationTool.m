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
    searchImage.hidden = YES;
    [searchImage stopAnimating];
    [searchImage removeFromSuperview];
    searchImage = nil;
    
    animationView.hidden = YES;
    [animationView removeFromSuperview];
    animationView = nil;
}


static UIView *animationView = nil;
static UIImageView *searchImage = nil;
static UILabel *noDevLabel = nil;
static NSTimer *showTimer  = nil;
static int      showSeek   = 0;
static int      showTimeout= 0;

+(void)startSearchAnimationTime:(float)time{
    if (animationView) {
        [animationView removeFromSuperview];
        animationView = nil;
    }
    
    if (searchImage) {
        [searchImage removeFromSuperview];
        searchImage = nil;
    }
    showTimeout = time;
    float sW = [DFUITools screen_2_W];
    float sH = [DFUITools screen_2_H];
    UIWindow *win = [DFUITools getWindow];
    animationView = [[UIView alloc] initWithFrame:CGRectMake(0, kJL_HeightNavBar, sW, sH-kJL_HeightTabBar-100.0)];
    animationView.backgroundColor = [UIColor clearColor];
    [win addSubview:animationView];

    noDevLabel = [[UILabel alloc] init];
    noDevLabel.bounds = CGRectMake(0, 0, sW, 50);
    noDevLabel.center = CGPointMake(sW/2.0, 48);
    noDevLabel.numberOfLines = 0;
    noDevLabel.lineBreakMode = NSLineBreakByCharWrapping;
    noDevLabel.textAlignment = NSTextAlignmentCenter;
    noDevLabel.font =  [UIFont fontWithName:@"PingFang-SC-Regular" size: 20];
    noDevLabel.text =  kJL_TXT("正在搜索可用设备");
    noDevLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    noDevLabel.layer.masksToBounds = YES;
    noDevLabel.layer.cornerRadius = 10.0;
    noDevLabel.backgroundColor = kDF_RGBA(245, 245, 245, 0.8);
    [animationView addSubview:noDevLabel];
    
    searchImage = [UIImageView new];
    searchImage.center = CGPointMake(animationView.frame.size.width/2.0, animationView.frame.size.height/2.0);
    searchImage.contentMode = UIViewContentModeCenter;
    [animationView addSubview:searchImage];
    
    searchImage.animationImages = imageArray;
    searchImage.animationDuration = 2.0;
    [searchImage startAnimating];
    
    if (showTimer == nil) {
        showTimer  = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES
                                                       block:^(NSTimer * _Nonnull timer) {
            if (showSeek == showTimeout) {
                [DFAction timingPause:showTimer];
                showSeek = 0;
                [self removeView];
                return;
            }
            showSeek++;
        }];
    }
    [DFAction timingContinue:showTimer];
//    [JL_Tools delay:time Task:^{
//        [self removeView];
//    }];
}

+(void)stopSearchAnimation{
    
    [DFAction timingStop:showTimer];
    showSeek = 0;
    [self removeView];
}


@end
