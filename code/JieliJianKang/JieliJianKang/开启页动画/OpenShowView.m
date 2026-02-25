//
//  OpenShowView.m
//  Created by kaka on 2021/3/15.
//

#import "OpenShowView.h"
#import "JL_RunSDK.h"

@interface OpenShowView()

@property (weak, nonatomic) IBOutlet UILabel *mLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mImageView;

@end


@implementation OpenShowView

- (instancetype)init
{
    self = [DFUITools loadNib:@"OpenShowView"];
    if (self) {
        float sW = [DFUITools screen_1_W];
        float sH = [DFUITools screen_2_H];
        self.frame = CGRectMake(0, 0, sW, sH);

        self.mLabel.text = kJL_TXT("宜动健康");
        self.mLabel.transform = CGAffineTransformMakeScale(0, 0);
        self.mLabel.alpha = 0.0;
        self.mImageView.transform = CGAffineTransformMakeScale(0, 0);
        self.mImageView.alpha = 0.0;
    }
    return self;
}

static OpenShowView *openView = nil;

-(void)actionAnimationDuration:(float)duration{

    [UIView animateWithDuration:duration animations:^{
        self.mImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.mLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.mImageView.alpha = 1.0;
        self.mLabel.alpha = 1.0;
    }];
    [DFAction delay:duration+1.0 Task:^{
        [UIView animateWithDuration:1.0 animations:^{
            self.alpha = 0.0;
        }];
    }];
    [DFAction delay:duration+2.0 Task:^{
        [self removeFromSuperview];
        openView = nil;
    }];
}

+(void)startOpenAnimation{
    UIWindow *win = [DFUITools getWindow];
    openView = [[OpenShowView alloc] init];
    [win addSubview:openView];
    [openView actionAnimationDuration:1.5];
}

@end
