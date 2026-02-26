//
//  OxygenRefView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/30.
//

#import "OxygenRefView.h"
#import "JL_RunSDK.h"
#import <CoreDraw/CoreDraw.h>

@interface OxygenRefView(){
    NSArray *colors;
}

@end

@implementation OxygenRefView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)initData{
    colors = @[kDF_RGBA(51, 224, 237, 1),kDF_RGBA(255, 187, 42, 1),kDF_RGBA(138, 202, 146, 1),kDF_RGBA(255, 187, 42, 1)];
    self.textArray = @[@"<70%",@"70-89%",@"90-100%",kJL_TXT("有较低血氧")];
}

-(void)drawText{
    CGFloat w = self.frame.size.width/self.textArray.count;
    CGFloat tx = 0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size: 10];
    for (int i = 0; i<self.textArray.count; i++) {
        CGSize textSize = [self.textArray[i] sizeWithAttributes:@{NSFontAttributeName:font}];
        tx = (w-textSize.width)/2;
        CGFloat w1 = w*i+tx;
        CGRect r = CGRectMake(w1, 2, w, 19);
        NSDictionary *dict = @{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor whiteColor],NSBackgroundColorAttributeName:[UIColor clearColor]};
        [self.textArray[i] drawInRect:r withAttributes:dict];
        if (i!=3) {
            [ECDrawTools drawRoundFill:context radius:5 Rect:CGPointMake(w1-8, self.frame.size.height/2) color:colors[i]];
        }else{
            [ECDrawTools drawTriangle:colors[i] Rect:CGRectMake(w1-10, self.frame.size.height/2-4, 8, 8) Oriental:ECOrientation_Down];
        }
    }
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawText];
}


@end
