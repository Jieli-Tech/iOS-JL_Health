//
//  SelectTitleBar.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/23.
//

#import "SelectTitleBar.h"
#import <CoreDraw/CoreDraw.h>
#import "JL_RunSDK.h"

@interface SelectTitleBar(){
    CGFloat width;
    CGFloat height;
    UIView *bgView;
    int nowIndex;
}
@end
@implementation SelectTitleBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        width = self.frame.size.width/4;
        height = self.frame.size.height;
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.alpha = 0.35;
        [self addSubview:bgView];
        
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = self.frame.size.height/2;
        self.layer.masksToBounds = YES;
    }
    return self;
}

-(void)initData{
    self.bgColor = [UIColor whiteColor];
    self.selectBgColor = [UIColor whiteColor];
    self.selectColor = kDF_RGBA(128, 91, 235, 1);
    self.normalColor = kDF_RGBA(255, 255, 255, 1);
    self.textArray = @[kJL_TXT("日"),kJL_TXT("周"),kJL_TXT("月"),kJL_TXT("年")];
}
-(void)setTextArray:(NSArray *)textArray{
    _textArray = textArray;
    [self setNeedsDisplay];
}

-(void)drawText{
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size: 14];
    for (int i = 0; i<self.textArray.count; i++) {
        UIColor *color = self.normalColor;
        if (i == nowIndex) {
            color = self.selectColor;
            font = [UIFont fontWithName:@"PingFangSC-Medium" size: 14];
        }
        CGSize textSize = [_textArray[i] sizeWithAttributes:@{NSFontAttributeName:font}];
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.alignment = NSTextAlignmentCenter;
        
        NSDictionary *dict = @{NSFontAttributeName:font,NSForegroundColorAttributeName:color,NSBackgroundColorAttributeName:[UIColor clearColor],NSParagraphStyleAttributeName :style};
        [self.textArray[i] drawInRect:CGRectMake(i*width, height/2-textSize.height/2, width, height) withAttributes:dict];
    }
}



-(void)drawSelectView{
    CGContextRef context = UIGraphicsGetCurrentContext();
//    [UIView animateWithDuration:0.1 animations:^{
        [ECDrawTools drawCell2:context rect:CGRectMake(self->nowIndex * self->width, 0, self->width, self->height) color:[UIColor whiteColor] radius:self.frame.size.height/2];
//    }];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawSelectView];
    [self drawText];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    // 当前触摸点
    CGPoint currentPoint = [touch locationInView:self.superview];
    [self caculateData:currentPoint];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    // 当前触摸点
    CGPoint currentPoint = [touch locationInView:self.superview];
    [self caculateData:currentPoint];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    // 当前触摸点
    CGPoint currentPoint = [touch locationInView:self.superview];
    [self caculateData:currentPoint];
    if ([_delegate respondsToSelector:@selector(barDidSelectIndex:)]) {
        [_delegate barDidSelectIndex:nowIndex];
    }
}

-(void)caculateData:(CGPoint)currentPoint{
    nowIndex = currentPoint.x/width;
    [self setNeedsDisplay];
}


@end
