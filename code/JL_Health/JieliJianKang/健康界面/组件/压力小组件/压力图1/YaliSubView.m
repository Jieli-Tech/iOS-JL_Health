//
//  YaliSubView.m
//  QCY_Demo
//
//  Created by 杰理科技 on 2021/3/23.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import "YaliSubView.h"

@implementation YaliSubView

//MovedView
//重写touchesMoved方法(触摸滑动过程中持续调用)
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //获取触摸对象
    UITouch *touch = [touches anyObject];

    //获取当前触摸点位置
    CGPoint curPoint = [touch locationInView:self];

    //kJLLog(JLLOG_DEBUG, @"---> X:%.2f Y:%.2f",curPoint.x,curPoint.y);
    if ([_delegate respondsToSelector:@selector(onYaliSubViewMovePoint:Type:)]) {
        [_delegate onYaliSubViewMovePoint:curPoint Type:0];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //获取触摸对象
    UITouch *touch = [touches anyObject];

    //获取当前触摸点位置
    CGPoint curPoint = [touch locationInView:self];
    //kJLLog(JLLOG_DEBUG, @"END---> X:%.2f Y:%.2f",curPoint.x,curPoint.y);
    
    if ([_delegate respondsToSelector:@selector(onYaliSubViewMovePoint:Type:)]) {
        [_delegate onYaliSubViewMovePoint:curPoint Type:1];
    }
}



@end
