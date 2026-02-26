//
//  YaLiView2.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/30.
//

#import "YaLiView2.h"
#import "YaliSubView.h"

#define kCOLOR_Y    kDF_RGBA(247, 226, 148, 1)

@interface YaLiView2()<YaliSubViewDelegate>{
    float   sW;
    float   sH;
    float   gap_T;
    float   gap_L;
    float   gap_R;
    float   gap_B;
    
    YaliSubView     *lineView;
    UIImageView     *blueImage;
    NSMutableArray  *pArr;
}

@end

@implementation YaLiView2

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        sW = frame.size.width;
        sH = frame.size.height;
        self.frame = frame;
        
        gap_T = 20.0;
        gap_L = 30.0;
        gap_B = 60.0;
        gap_R = 50.0;
        

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
    lineView.frame = CGRectMake(gap_L, gap_T, sW-gap_L-gap_R*LB_GAP_R, sH-gap_T-gap_B);
    lineView.delegate = self;
    [self addSubview:lineView];
}

-(void)loadUI{
    [self resetUI];
    
    NSInteger ct = self.dataArray.count;
    if(ct == 1){
        return;
    }
    float gap_label = (sW - gap_L - gap_R*LB_GAP_R)/(ct-1);
    
    for (int i = 0; i < ct; i++) {
        UILabel *lb = [UILabel new];
        lb.textAlignment = NSTextAlignmentCenter;
        //lb.backgroundColor = [UIColor blackColor];
        lb.textColor = kDF_RGBA(255, 255, 255, 0.7);
        lb.font = [UIFont systemFontOfSize:10.0];
        
        /*--- 日，小时线 ---*/
        if (ct == 24) {
            NSString *txt = [NSString stringWithFormat:@"%d:00",i+1];
            if ((i+1)==1)   lb.text = txt;
            if ((i+1)%6==0) lb.text = txt;
        }else{
        /*--- 月，日期线 ---*/
            NSString *txt = [NSString stringWithFormat:@"%d日",i+1];
            if ((i+1)==1)  lb.text = txt;
            if ((i+1)==8)  lb.text = txt;
            if ((i+1)==15) lb.text = txt;
            if ((i+1)==22) lb.text = txt;
            if ((i+1)==ct) lb.text = txt;
        }
        
        lb.bounds = CGRectMake(0, 0, 40.0, 20.0);
        lb.center = CGPointMake(gap_L+i*gap_label, sH-gap_B/2.0);
        [self addSubview:lb];
    }
            
    NSArray *yArrTxt = @[@"0",@"20",@"40",@"60",@"80",@"100"];
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
        lb.center = CGPointMake(sW-gap_R/2.0, sH-gap_B-j*gap_label_1);
        [self addSubview:lb];
        
        UIImageView *image = [UIImageView new];
        image.frame = CGRectMake(gap_L-20.0, lb.center.y, sW-gap_L-gap_R+30.0, 1);
        image.image = [UIImage imageNamed:@"press_line_02"];
        image.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:image];
    }

    pArr = [NSMutableArray new];
    NSInteger ct_2 = self.dataArray.count;
    float w = lineView.frame.size.width;
    float h = lineView.frame.size.height;
    float gap = w/(ct_2-1);
    
    for (int i = 0 ; i < ct_2; i++) {
        float num = [self.dataArray[i] floatValue];
        float x = i*gap;
        float y = h - h*(num/100.0f);

        NSDictionary *pDict = @{kYALI_KEY_X:@(x),
                                kYALI_KEY_Y:@(y)};
        [pArr addObject:pDict];
    }
    
    if (blueImage == nil) {
        blueImage = [UIImageView new];
        blueImage.image = [UIImage imageNamed:@"press_line_01"];
        blueImage.contentMode = UIViewContentModeScaleToFill;
        blueImage.bounds = CGRectMake(0, 0, 3, sH-gap_T-gap_B+30.0);
        [lineView addSubview:blueImage];
    }
    [self drawLine];
    
    NSDictionary *dict = pArr[0];
    float x = [dict[kYALI_KEY_X] floatValue];
    blueImage.center = CGPointMake(x, (sH-gap_T-gap_B)/2.0);
}

-(void)drawLine{
    float h = lineView.frame.size.height;
    
    for (int i = 0 ; i < pArr.count; i++) {
        NSDictionary *dict = pArr[i];
        float x = [dict[kYALI_KEY_X] floatValue];
        float y = [dict[kYALI_KEY_Y] floatValue];
        float line_h = h-y;
        
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.frame = CGRectMake(x-2.0, y, 4.0, line_h);
        
        if (self.lineColor == nil) {
            layer.fillColor = kCOLOR_Y.CGColor;//背景填充色
        }else{
            layer.fillColor = self.lineColor.CGColor;//背景填充色
        }
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 4.0, line_h)
                                                   byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(1.5, 1.5)];
        layer.path = [path CGPath];
        [lineView.layer addSublayer:layer];
    }
}

-(void)setSubIndex:(NSInteger)subIndex{
    if (_subIndex == subIndex) {
        return;
    }
    _subIndex = subIndex;

    NSDictionary *dict = pArr[subIndex];
    float x = [dict[kYALI_KEY_X] floatValue];
    
    blueImage.center = CGPointMake(x, (sH-gap_T-gap_B)/2.0);
    AudioServicesPlaySystemSound(1519);
    kJLLog(JLLOG_DEBUG, @"----> YaLi_2 Index : %ld",(long)subIndex+1);
    
    if([_delegate respondsToSelector:@selector(YaLiView2ClickIndex:)]){
        [_delegate YaLiView2ClickIndex:(long)subIndex+1];
    }
}

-(void)onYaliSubViewMovePoint:(CGPoint)point Type:(UInt8)type{
    float x = point.x;
    if (x < 0.0 || x >lineView.frame.size.width) return;
    
    NSInteger ct = self.dataArray.count;
    float gap = (sW - gap_L - gap_R*LB_GAP_R)/(ct-1);
    
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
