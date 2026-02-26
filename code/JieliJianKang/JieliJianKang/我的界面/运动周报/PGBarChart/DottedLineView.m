//
//  DottedLineView.m
//  JieliJianKang
//
//  Created by EzioChan on 2023/9/22.
//

#import "DottedLineView.h"

@implementation DottedLineView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setNeedsDisplay];
    }
    return self;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetStrokeColorWithColor(context, kDF_RGBA(231, 231, 231, 1).CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGFloat lengths[] = {2,2};
    CGContextSetLineDash(context, 0, lengths, 1);
    CGContextAddLineToPoint(context, self.frame.size.width, 0);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}


@end
