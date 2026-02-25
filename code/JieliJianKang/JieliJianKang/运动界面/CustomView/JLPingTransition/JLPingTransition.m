//
//  JLPingTransition.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/9.
//

#import "JLPingTransition.h"
#import "SportVC.h"
#import "JLPagerView.h"
#import "JLOutdoorSportThumbnailViewController.h"
#import "JLSportDetailViewController.h"

@interface JLPingTransition() <CAAnimationDelegate>

@property (weak, nonatomic) id transitionContext;

@end

@implementation JLPingTransition

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    self.transitionContext = transitionContext;
    
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *btn = fromVC.view;
    if ([NSStringFromClass(toVC.class) isEqualToString:NSStringFromClass([JLSportDetailViewController class])]) {
        btn = JLApplicationDelegate.sportVC.pagerView.outdoorSportThumbnailViewController.startBtnView;
    }
    
    [containerView addSubview:toVC.view];
    
    UIBezierPath *originPath = [UIBezierPath bezierPathWithOvalInRect:btn.frame];
    CGPoint extremePoint = CGPointMake(btn.center.x - 0, btn.center.y - CGRectGetHeight(toVC.view.bounds));
    
    float radius = sqrtf(extremePoint.x * extremePoint.x + extremePoint.y * extremePoint.y);
    UIBezierPath *finalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(btn.frame, -radius*2.0, -radius*2.0)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = finalPath.CGPath;
    toVC.view.layer.mask = maskLayer;

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue = (__bridge id _Nullable)(originPath.CGPath);
    animation.toValue = (__bridge id _Nullable)(finalPath.CGPath);
    animation.duration = [self transitionDuration:transitionContext];
    animation.delegate = self;
    [maskLayer addAnimation:animation forKey:@"path"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
    [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
}

@end
