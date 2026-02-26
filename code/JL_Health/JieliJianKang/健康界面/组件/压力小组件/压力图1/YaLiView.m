//
//  YaLiView.m
//  QCY_Demo
//
//  Created by 杰理科技 on 2021/3/22.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import "YaLiView.h"
#import "YaliSubView.h"



@interface YaLiView()<YaliSubViewDelegate>{
    float   sW;
    float   sH;
    float   gap_T;
    float   gap_B;
    
    YaliSubView     *lineView;
    CALayer         *blueLayer;
    UIImageView     *blueImage;
    NSMutableArray  *pArr;
}

@end

@implementation YaLiView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = [kCOLOR_1];
        self.backgroundColor = [UIColor clearColor];
        sW = frame.size.width;
        sH = frame.size.height;
        self.frame = frame;
        
        gap_T = 20.0;
        gap_B = 60.0;
    }
    return self;
}

-(void)resetUI{
    if (blueImage) {
        [blueImage removeFromSuperview];
        blueImage = nil;
    }
    [lineView removeFromSuperview];
    lineView = nil;
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    lineView = [[YaliSubView alloc] init];
    lineView.frame = CGRectMake(self.gap_L, gap_T, sW-self.gap_L-self.gap_R*LB_GAP_R, sH-gap_T-gap_B);
    lineView.delegate = self;
    [self addSubview:lineView];
}

-(void)loadUI{
    [self resetUI];
    
    NSInteger ct = self.textArray.count;
    if(self.type == 1){
        float w = (sW - self.gap_L - self.gap_R)/(ct);
        CGFloat tx = 0;
        UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size: 10];
        
        for (int i = 0; i < ct; i++) {
            CGSize textSize = [self.textArray[i] sizeWithAttributes:@{NSFontAttributeName:font}];
            tx = (w-textSize.width)/2;
            CGFloat w1 = w*i+10+tx;
            
            UILabel *lb = [UILabel new];
            lb.textAlignment = NSTextAlignmentCenter;
            //lb.backgroundColor = [UIColor blackColor];
            lb.textColor = kDF_RGBA(255, 255, 255, 0.7);
            lb.font = [UIFont systemFontOfSize:10.0];
            lb.text = self.textArray[i];
            lb.bounds = CGRectMake(0, 0, 40.0, 20.0);
            lb.center = CGPointMake(w1+10, sH-gap_B/2.0);
            [self addSubview:lb];
        }
    }else{
        float gap_label = (sW - self.gap_L - self.gap_R*LB_GAP_R)/(ct-1);
        
        for (int i = 0; i < ct; i++) {
            UILabel *lb = [UILabel new];
            lb.textAlignment = NSTextAlignmentCenter;
            //lb.backgroundColor = [UIColor blackColor];
            lb.textColor = kDF_RGBA(255, 255, 255, 0.7);
            lb.font = [UIFont systemFontOfSize:10.0];
            lb.text = self.textArray[i];
            lb.bounds = CGRectMake(0, 0, 40.0, 20.0);
            lb.center = CGPointMake(self.gap_L+i*gap_label, sH-gap_B/2.0);
            [self addSubview:lb];
        }
    }
    
    NSArray *yArrTxt;
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    if([unitStr isEqualToString:@("英制")]){
        yArrTxt = @[@"22",@"163",@"314",@"466",@"551"];
    }else{
        yArrTxt = @[@"10",@"74",@"143",@"211",@"250"];
    }

    NSInteger ct_1 = yArrTxt.count;
    float gap_label_1 = (sH - gap_T - gap_B)/(ct_1-1);
    
    for (int j = 0 ; j < ct_1 ; j++) {
        UILabel *lb = [UILabel new];
        lb.textAlignment = NSTextAlignmentCenter;
        //lb.backgroundColor = [UIColor blackColor];
        lb.textColor = kDF_RGBA(255, 255, 255, 0.7);
        lb.font = [UIFont systemFontOfSize:10.0];
        lb.text = yArrTxt[j];
        lb.bounds = CGRectMake(0, 0, 40.0, 20.0);
        float mGap_R = 40.f;
        lb.center = CGPointMake(sW-mGap_R/2.0, sH-gap_B-j*gap_label_1);
        //[self addSubview:lb];
        
        float mGap_L = 50.f;
        UIImageView *image = [UIImageView new];
        image.frame = CGRectMake(mGap_L-20.0, lb.center.y, sW-self.gap_L-self.gap_R+30.0, 1);
        image.image = [UIImage imageNamed:@"press_line_02"];
        image.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:image];
    }
    
    pArr = [NSMutableArray new];
    NSInteger ct_2 = self.dataArray.count;
    float width = lineView.frame.size.width;
    float h = lineView.frame.size.height;
    float gap = 0.f;
    if(self.type == 1){
        gap = width/(32-1);
    }else{
        gap = width/(ct-1);
    }
    
    float totalNum = 0.f;
    if([unitStr isEqualToString:@("英制")]){
        totalNum = 551.0f;
    }else{
        totalNum = 250.0f;
    }
    for (int i = 0 ; i < ct_2; i++) {
//        float num = [self.dataArray[i] floatValue];
        float x = i*gap;
        float y = h - h*(150/totalNum);
        if(self.dateArray.count>0 && self.dateArray.count>i){
            NSDate *date = self.dateArray[i];
            NSInteger index = 0;
            if(self.type == 0){
                index = date.witchWeekDay;
            }
            if(self.type == 1){
                index = date.witchDay;
            }
            if(self.type == 2){
                index = date.witchMonth;
            }
            x = (index-1)*gap;
            NSDictionary *pDict = @{kYALI_KEY_X:@(x),
                                    kYALI_KEY_Y:@(y)};
            [pArr addObject:pDict];
            
            if (blueImage == nil) {
                blueImage = [UIImageView new];
                blueImage.image = [UIImage imageNamed:@"press_line_01"];
                blueImage.contentMode = UIViewContentModeScaleToFill;
                blueImage.bounds = CGRectMake(0, 0, 3, sH-gap_T-gap_B+30.0);
                [lineView addSubview:blueImage];
            }
            
            [self drawLineView_0];
            [self drawLineView_1];
            
            NSDictionary *dict = pArr[0];
            float x = [dict[kYALI_KEY_X] floatValue];
            float y = [dict[kYALI_KEY_Y] floatValue];
            [self drawBlueArcPoint:CGPointMake(x, y)];
            blueImage.center = CGPointMake(x, (sH-gap_T-gap_B)/2.0);
        }
    }
}

-(void)drawLineView_0{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for (int i = 0 ; i < pArr.count; i++) {
        NSDictionary *dict = pArr[i];
        float x = [dict[kYALI_KEY_X] floatValue];
        float y = [dict[kYALI_KEY_Y] floatValue];
        
        if (i == 0) {
            [path moveToPoint:CGPointMake(x, y)];
        }else{
            [path addLineToPoint:CGPointMake(x, y)];
        }
    }
    CAShapeLayer  *layer = [CAShapeLayer layer];
    layer.lineWidth = 1.5;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.path = [path CGPath];
    [lineView.layer addSublayer:layer];
}

-(void)drawLineView_1{
    for (int i = 0 ; i < pArr.count; i++) {
        NSDictionary *dict = pArr[i];
        float x = [dict[kYALI_KEY_X] floatValue];
        float y = [dict[kYALI_KEY_Y] floatValue];
        [self drawArcPoint:CGPointMake(x, y)];
    }
}


-(void)drawArcPoint:(CGPoint)point{
    CAShapeLayer *layer = [CAShapeLayer new];
    layer.lineWidth = 1.5;
    layer.strokeColor = [UIColor whiteColor].CGColor;//圆环的颜色
    if (self.nColor == nil) {
        layer.fillColor = kCOLOR_1.CGColor;//背景填充色
    }else{
        layer.fillColor = self.nColor.CGColor;//背景填充色
    }
    CGFloat radius = 5;//设置半径为6
    BOOL clockWise = true;//按照顺时针方向
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:radius
                                                    startAngle:0 endAngle:2*M_PI
                                                     clockwise:clockWise];
    layer.path = [path CGPath];
    [lineView.layer addSublayer:layer];
}

-(void)drawBlueArcPoint:(CGPoint)point{
    CAShapeLayer *layer = [CAShapeLayer new];
    layer.lineWidth = 1.5;
    layer.strokeColor = [UIColor whiteColor].CGColor;//圆环的颜色
    if (self.pColor == nil) {
        layer.fillColor = kCOLOR_2.CGColor;//背景填充色
    }else{
        layer.fillColor = self.pColor.CGColor;//背景填充色
    }
    
    CGFloat radius = 5;//设置半径为6
    BOOL clockWise = true;//按照顺时针方向
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:radius
                                                    startAngle:0 endAngle:2*M_PI
                                                     clockwise:clockWise];
    layer.path = [path CGPath];
    [lineView.layer addSublayer:layer];
    
    blueLayer = layer;
}

-(void)setSubIndex:(NSInteger)subIndex{
    
    //    if (_subIndex == subIndex) {
    //        return;
    //    }
    _subIndex = subIndex;
    [blueLayer removeFromSuperlayer];
    
    //if(pArr.count>subIndex){
    int mIndex = (int)[self.temDateArray indexOfObject:@(subIndex)];
    if(mIndex!=-1){
        NSDictionary *dict = pArr[mIndex];
        float x = [dict[kYALI_KEY_X] floatValue];
        float y = [dict[kYALI_KEY_Y] floatValue];
        [self drawBlueArcPoint:CGPointMake(x, y)];
        
        blueImage.center = CGPointMake(x, (sH-gap_T-gap_B)/2.0);
        AudioServicesPlaySystemSound(1519);
        
        kJLLog(JLLOG_DEBUG, @"----> YaLi Index : %ld",(long)subIndex);
        
        if([_delegate respondsToSelector:@selector(YaLiViewClickIndex:)]){
            [_delegate YaLiViewClickIndex:(long)subIndex];
        }
    }
    
    //}
}

-(void)onYaliSubViewMovePoint:(CGPoint)point Type:(UInt8)type{
    float x = point.x;
    if (x < 0.0 || x >lineView.frame.size.width) return;
    
    NSInteger ct = 0;
    if(self.type == 1){
        ct = 32;
    }else{
        ct = self.textArray.count;
    }
    
    float gap = (sW - self.gap_L - self.gap_R*LB_GAP_R)/(ct-1);
    
    float num = x/gap;
    int num_int = (int)num;
    float rest = num-(float)num_int;
    
    if (rest <= 0.5f) {
        [self setSubIndex:num_int];
    }else{
        [self setSubIndex:num_int+1];
    }
}


@end



