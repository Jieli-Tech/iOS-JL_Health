//
//  TizhongPick.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/8.
//

#import "TizhongPick.h"
#import "TizhongPlate.h"

@interface TizhongPick()<UIScrollViewDelegate>{
    UIScrollView    *sView;
    TizhongPlate    *iPlate;
    NSInteger       fm_num;

    CGFloat         view_W;
    CGFloat         view_H;
    NSInteger       fm_sPoint_1;
    NSInteger       fm_sPoint;
    NSInteger       fm_ePoint;
}

@end

@implementation TizhongPick

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
        iPlate = [[TizhongPlate alloc] initWithIndex:fm_num WithHeight:view_H];
        iPlate.startPiont = fm_sPoint;
        
        sView = [[UIScrollView alloc] init];
        sView.frame = CGRectMake(0, 0, view_W, view_H);
        sView.showsVerticalScrollIndicator = NO;
        sView.showsHorizontalScrollIndicator = NO;
        sView.alwaysBounceHorizontal = YES;
        sView.contentSize = CGSizeMake(fm_num*kTizhong_SCALE*kTizhong_GAP+kTizhongPickGAP, 0);
        sView.contentInset = UIEdgeInsetsMake(0, view_W/2.0-kTizhongPickGAP/2.0, 0, view_W/2.0-kTizhongPickGAP/2.0);
        sView.backgroundColor = [UIColor clearColor];
        sView.delegate = self;
        [sView addSubview:iPlate];
        [self addSubview:sView];
        
        
        UIImageView *redImage = [[UIImageView alloc] initWithFrame:CGRectMake(view_W/2.0-1.0, -25, 4.0, view_H-20.0)];
        redImage.contentMode = UIViewContentModeScaleAspectFill;
        redImage.image = [UIImage imageNamed:@"icon_triangle_nol"];
        //redImage.backgroundColor = [UIColor blueColor];
        [self addSubview:redImage];
    }
    return self;
}




#pragma mark UIScrollViewDelegate
static BOOL isSpeed = NO;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float s_x = scrollView.contentOffset.x + view_W/2.0-kTizhongPickGAP/2.0;
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
        float s_x = scrollView.contentOffset.x + view_W/2.0-kTizhongPickGAP/2.0;
        [self fixedOffset:s_x];
        //NSLog(@"无速度：%.2f",s_x);
    }
}

#pragma mark --> (有速度)偏移UI
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float s_x = scrollView.contentOffset.x + view_W/2.0-kTizhongPickGAP/2.0;
    [self fixedOffset:s_x];
    //NSLog(@"有速度：%.2f",s_x);
}


-(void)fixedOffset:(int)point{
    int minGap = kTizhong_GAP;
    
    int rest = point%minGap;
    int mPoint = 0;
    if (rest > minGap/2) {
        mPoint = (point - rest)+minGap;
    }else{
        mPoint = (point - rest);
    }
    [sView setContentOffset:CGPointMake(mPoint+kTizhongPickGAP/2.0-view_W/2.0, 0) animated:YES];
    
    /*--- 描述刻度LB ---*/
    float fm_point = mPoint/kTizhong_GAP + fm_sPoint;
    if (fm_point < 100.f || fm_point > 3400.0f) return;
    
    //NSString *text_num = [NSString stringWithFormat:@"%.1f",fm_point];
    //NSLog(@"0 ==> fmLabel.text:%@",text_num);

    if([_delegate respondsToSelector:@selector(onTizhongPick:didSelect:)]){
        NSInteger outPoint = (NSInteger)fm_point;
        [_delegate onTizhongPick:self didSelect:outPoint];
    }
}

-(void)fixedOffset_1:(int)point{
    int minGap = kTizhong_GAP;

    int rest = point%minGap;
    int mPoint = 0;
    if (rest > minGap/2) {
        mPoint = (point - rest)+minGap;
    }else{
        mPoint = (point - rest);
    }

    /*--- 描述刻度LB ---*/
    float fm_point = mPoint/kTizhong_GAP + fm_sPoint_1;
    if (fm_point < 100.f || fm_point > 3400.0f) return;
    
    //NSString *text_num = [NSString stringWithFormat:@"%.1f",fm_point];
    //NSLog(@"1 ==> fmLabel.text:%@",text_num);

    if([_delegate respondsToSelector:@selector(onTizhongPick:didChange:)]){
        NSInteger outPoint = (NSInteger)fm_point;
        [_delegate onTizhongPick:self didChange:outPoint];
    }
}

-(void)setTizhongPickPoint:(NSInteger)point{    
    if (point < fm_sPoint*10.0) {
        point = fm_sPoint*10.0;
    }
    if (point > fm_ePoint*10.0) {
        point = fm_ePoint*10.0;
    }

    float mPoint = (point - fm_sPoint)*kTizhong_GAP;
    [sView setContentOffset:CGPointMake(mPoint+kTizhongPickGAP/2.0-view_W/2.0, 0) animated:YES];
}



@end
