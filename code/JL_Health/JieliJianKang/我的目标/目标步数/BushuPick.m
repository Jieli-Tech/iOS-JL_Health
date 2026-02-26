//
//  BushuPick.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/4.
//

#import "BushuPick.h"
#import "BushuPlate.h"

@interface BushuPick()<UIScrollViewDelegate>{
    
    UIScrollView    *sView;
    BushuPlate      *iPlate;
    NSInteger       fm_num;

    CGFloat         view_W;
    CGFloat         view_H;
    NSInteger       fm_sPoint_1;
    NSInteger       fm_sPoint;
    NSInteger       fm_ePoint;
}

@end

@implementation BushuPick

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
        fm_sPoint_1 = sPoint;
        fm_sPoint = sPoint;
        fm_ePoint = ePoint;
        
        fm_num = fm_ePoint - fm_sPoint;
        iPlate = [[BushuPlate alloc] initWithIndex:fm_num WithHeight:view_H];
        iPlate.startPiont = fm_sPoint;
        
        sView = [[UIScrollView alloc] init];
        sView.frame = CGRectMake(0, 0, view_W, view_H);
        sView.showsVerticalScrollIndicator = NO;
        sView.showsHorizontalScrollIndicator = NO;
        sView.alwaysBounceHorizontal = YES;
        sView.contentSize = CGSizeMake(fm_num*kBushu_SCALE*kBushu_GAP+kBushuPickGAP, 0);
        sView.contentInset = UIEdgeInsetsMake(0, view_W/2.0-kBushuPickGAP/2.0, 0, view_W/2.0-kBushuPickGAP/2.0);
        sView.backgroundColor = [UIColor clearColor];
        sView.delegate = self;
        [sView addSubview:iPlate];
        [self addSubview:sView];
        
        
        UIImageView *redImage = [[UIImageView alloc] initWithFrame:CGRectMake(view_W/2.0-7.0, -15.0, 14.0, 45)];
        redImage.contentMode = UIViewContentModeScaleToFill;
        redImage.image = [UIImage imageNamed:@"icon_triangle_nol"];
        //redImage.backgroundColor = [UIColor blueColor];
        [self addSubview:redImage];
    }
    return self;
}




#pragma mark UIScrollViewDelegate
static BOOL isSpeed = NO;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float s_x = scrollView.contentOffset.x + view_W/2.0-kBushuPickGAP/2.0;
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
        float s_x = scrollView.contentOffset.x + view_W/2.0-kBushuPickGAP/2.0;
        [self fixedOffset:s_x];
        //NSLog(@"无速度：%.2f",s_x);
    }
}

#pragma mark --> (有速度)偏移UI
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float s_x = scrollView.contentOffset.x + view_W/2.0-kBushuPickGAP/2.0;
    [self fixedOffset:s_x];
    //NSLog(@"有速度：%.2f",s_x);
}


-(void)fixedOffset:(int)point{
    int minGap = kBushu_GAP;
    
    int rest = point%minGap;
    int mPoint = 0;
    if (rest > minGap/2) {
        mPoint = (point - rest)+minGap;
    }else{
        mPoint = (point - rest);
    }
    [sView setContentOffset:CGPointMake(mPoint+kBushuPickGAP/2.0-view_W/2.0, 0) animated:YES];
    float fm_point = mPoint/kBushu_GAP + fm_sPoint;
    
    /*--- 描述刻度LB ---*/
    //NSString *text_num = [NSString stringWithFormat:@"%.1f",fm_point];
    //NSLog(@"0 ==> fmLabel.text:%@",text_num);
    
    if (fm_point < 0.0f || fm_point > 20.0f) return;

    if([_delegate respondsToSelector:@selector(onBushuPick:didSelect:)]){
        NSInteger outPoint = (NSInteger)fm_point*1000.0;
        [_delegate onBushuPick:self didSelect:outPoint];
    }
}

-(void)fixedOffset_1:(int)point{
    int minGap = kBushu_GAP;

    int rest = point%minGap;
    int mPoint = 0;
    if (rest > minGap/2) {
        mPoint = (point - rest)+minGap;
    }else{
        mPoint = (point - rest);
    }
    float fm_point = mPoint/kBushu_GAP + fm_sPoint_1;
    //NSString *text_num = [NSString stringWithFormat:@"%.1f",fm_point];
    //NSLog(@"1 ==> fmLabel.text:%@",text_num);
    
    /*--- 描述刻度LB ---*/
    if (fm_point < 0.0f || fm_point > 20.0f) return;

    if([_delegate respondsToSelector:@selector(onBushuPick:didChange:)]){
        NSInteger outPoint = (NSInteger)fm_point*1000.0;
        [_delegate onBushuPick:self didChange:outPoint];
    }
}

-(void)setBushuPoint:(NSInteger)point{
    
    if (point < fm_sPoint) {
        point = fm_sPoint;
    }
    if (point > fm_ePoint) {
        point = fm_ePoint;
    }

    float mPoint = (point - fm_sPoint)*kBushu_GAP;
    [sView setContentOffset:CGPointMake(mPoint+kBushuPickGAP/2.0-view_W/2.0, 0) animated:YES];
}


@end
