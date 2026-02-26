//
//  FMPickView.m
//  AiRuiSheng
//
//  Created by kaka on 2021/2/23.
//

#import "WeightPickView.h"
#import "IndexPlate.h"


@interface WeightPickView()<UIScrollViewDelegate>{

    UIScrollView    *sView;
    IndexPlate      *iPlate;
    NSInteger       weight_num;

    CGFloat         view_W;
    CGFloat         view_H;
    NSInteger       weight_sPoint_1;
    NSInteger       weight_sPoint;
    NSInteger       weight_ePoint;
//    UILabel         *fmLabel;
}

@end


@implementation WeightPickView

- (instancetype)initWithFrame:(CGRect)frame
                   StartPoint:(NSInteger)sPoint
                     EndPoint:(NSInteger)ePoint
{
    self = [super init];
    if (self) {
        self.frame = frame;
        //self.backgroundColor = [UIColor lightGrayColor];
        view_W = frame.size.width;
        view_H = frame.size.height;
        weight_sPoint_1 = sPoint;
        weight_sPoint = sPoint;
        weight_ePoint = ePoint;
        
        weight_num = ePoint - sPoint;
        iPlate = [[IndexPlate alloc] initWithIndex:weight_num WithHeight:view_H];
        iPlate.startPiont = sPoint;
        
        sView = [[UIScrollView alloc] init];
        sView.frame = CGRectMake(0, 0, view_W, view_H);
        sView.showsVerticalScrollIndicator = NO;
        sView.showsHorizontalScrollIndicator = NO;
        sView.alwaysBounceHorizontal = YES;
        sView.contentSize = CGSizeMake(weight_num*10.0*kMIN_GAP+kWeightPickViewGAP, 0);
        sView.backgroundColor = [UIColor clearColor];
        sView.contentInset = UIEdgeInsetsMake(0, view_W/2.0-10*kMIN_GAP-kWeightPickViewGAP/2.0, 0, view_W/2.0-kWeightPickViewGAP/2.0);
        sView.delegate = self;
        [sView addSubview:iPlate];
        [self addSubview:sView];
        
        UIImageView *redImage = [[UIImageView alloc] initWithFrame:CGRectMake(view_W/2.0-7.0, -26.0, 14.0, 75)];
        redImage.image = [UIImage imageNamed:@"icon_triangle_nol"];
        redImage.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:redImage];
    }
    return self;
}




#pragma mark UIScrollViewDelegate
static BOOL isSpeed = NO;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float s_x = scrollView.contentOffset.x + view_W/2.0-kWeightPickViewGAP/2.0;
    [self fixedOffset_1:s_x];
}

#pragma mark -->（无减速）完成拖拽(手指刚刚松开)
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{

    isSpeed = NO;
    [self performSelector:@selector(scrollAction:) withObject:scrollView afterDelay:0.1];
}

#pragma mark -->（有减速）完成拖拽(手指松开后执行动画的方法)
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    isSpeed = YES;
}

#pragma mark --> (无速度)偏移UI
-(void)scrollAction:(UIScrollView*)scrollView{
    if (isSpeed == NO) {
        float s_x = scrollView.contentOffset.x + view_W/2.0-kWeightPickViewGAP/2.0;
        [self fixedOffset:s_x];
        //NSLog(@"无速度：%.2f",s_x);
    }
}

#pragma mark --> (有速度)偏移UI
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float s_x = scrollView.contentOffset.x + view_W/2.0-kWeightPickViewGAP/2.0;
    [self fixedOffset:s_x];
    //NSLog(@"有速度：%.2f",s_x);
}


-(void)fixedOffset:(int)point{
    int rest = point%10;
    int mPoint = 0;
    if (rest > 5) {
        mPoint = (point - rest)+10;
    }else{
        mPoint = (point - rest);
    }
    [sView setContentOffset:CGPointMake(mPoint+kWeightPickViewGAP/2.0-view_W/2.0, 0) animated:YES];
    NSInteger weight_point = mPoint/kMIN_GAP + weight_sPoint*10;
    
    /*--- 描述刻度LB ---*/
    float m_weight_point = (float)weight_point;
    
    if (m_weight_point<weight_sPoint*10 || m_weight_point>weight_ePoint*10) return;
    
    m_weight_point = m_weight_point/10;
    //NSString *text_num = [NSString stringWithFormat:@"%.1f",f_fm_point];
    //fmLabel.text = text_num;
    //NSLog(@"==> fmLabel.text:%@",text_num);
    
    if([_delegate respondsToSelector:@selector(onWeightPickView:didSelect:)]){
        [_delegate onWeightPickView:self didSelect:weight_point];
    }
}

-(void)fixedOffset_1:(int)point{
    int rest = point%10;
    int mPoint = 0;
    if (rest > 5) {
        mPoint = (point - rest)+10;
    }else{
        mPoint = (point - rest);
    }
    NSInteger fm_point = mPoint/kMIN_GAP + weight_sPoint_1*10;
    
    /*--- 描述刻度LB ---*/
    float f_fm_point = (float)fm_point;
    if (f_fm_point<weight_sPoint*10 || f_fm_point>weight_ePoint*10) return;
        
    if([_delegate respondsToSelector:@selector(onWeightPickView:didChange:)]){
        [_delegate onWeightPickView:self didChange:f_fm_point];
    }
}


-(void)setWeightPoint:(NSInteger)point{
    if (point < 10) return;
    
    if (point < weight_sPoint*10) {
        point = weight_sPoint*10;
    }
    if (point > weight_ePoint*10) {
        point = weight_ePoint*10;
    }

    float mPoint = (point - weight_sPoint*10)*kMIN_GAP;
    [sView setContentOffset:CGPointMake(mPoint+kWeightPickViewGAP/2.0-view_W/2.0, 0) animated:YES];

    /*--- 描述刻度LB ---*/
    float f_fm_point = (float)point;
    f_fm_point = f_fm_point/10;
    //NSString *text_num = [NSString stringWithFormat:@"%.1f",f_fm_point];
    //fmLabel.text = text_num;
}

@end
