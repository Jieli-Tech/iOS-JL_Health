//
//  JLUnlockSliderView.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/12.
//

#import "JLUnlockSliderView.h"
#define kSliderW self.bounds.size.width
#define kSliderH self.bounds.size.height
#define kBorderWidth 0.2 //默认边框为2
#define kAnimationSpeed 0.5 //默认动画移速
#define kForegroundColor [UIColor orangeColor] //默认滑过颜色
#define kBackgroundColor [UIColor darkGrayColor] //默认未滑过颜色
#define kThumbColor [UIColor lightGrayColor] //默认Thumb颜色
#define kBorderColor [UIColor blackColor] //默认边框颜色
#define kThumbW 15 //默认的thumb的宽度
#define kTouchViewW 100 //默认的点击范围的宽度

@interface JLUnlockSliderView ()

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIImageView *thumbImageView;
@property (strong, nonatomic) UIView *thumbImageViewBgView;
@property (strong, nonatomic) UIView *foregroundView;
@property (strong, nonatomic) UIView *touchView;

@end

@implementation JLUnlockSliderView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _label = [[UILabel alloc] initWithFrame:CGRectMake(27, 0, self.width - 32, self.height)];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    
    _foregroundView = [[UIView alloc] init];
    [self addSubview:_foregroundView];
    _thumbImageViewBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kTouchViewW, self.height)];
    [self addSubview:_thumbImageViewBgView];
    [self centerYWith:_thumbImageViewBgView with:self];
    _thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kTouchViewW, self.height)];
    [_thumbImageViewBgView addSubview:_thumbImageView];
    [self centerYWith:_thumbImageView with:_thumbImageViewBgView];
    self.layer.cornerRadius = self.height / 2;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = kBorderWidth;
    [self setSliderValue:0.0];
    //默认配置
    self.thumbBack = YES;
    self.backgroundColor = kBackgroundColor;
    _foregroundView.backgroundColor = kForegroundColor;
    _thumbImageView.backgroundColor = kThumbColor;
    _thumbImageViewBgView.backgroundColor = kThumbColor;
    [self.layer setBorderColor:kBorderColor.CGColor];
    _touchView = _thumbImageViewBgView;
    
}

#pragma mark - Public Method
- (void)setText:(NSString *)text {
    _text = text;
    _label.text = text;
    if (!_label.superview) {
        [self addSubview:_label];
        [self sendSubviewToBack:_label];
        [self bringSubviewToFront:_foregroundView];
    }
}

- (void)setFont:(UIFont *)font {
    _font = font;
    _label.font = font;
}

- (void)setSliderValue:(CGFloat)value {
    [self setSliderValue:value animation:NO completion:nil];
}

- (void)setSliderValue:(CGFloat)value animation:(BOOL)animation completion:( void(^ _Nullable )(BOOL finish))completion {
    if (value > 1) {
        value = 1;
    }
    if (value < 1) {
        value = 0;
    }
    CGPoint point = CGPointMake(value * kSliderW, 0);
    typeof(self) weakSelf = self;
    if (animation) {
        [UIView animateWithDuration:kAnimationSpeed animations:^{
            [weakSelf fillForeGroundViewWithPoint:point];
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [self fillForeGroundViewWithPoint:point];
    }
}

- (void)setColorForBackgroud:(UIColor *)backgroud foreground:(UIColor *)foreground imageBackgroundColor:(UIColor *)imageBackgroundColor border:(UIColor *)border textColor:(UIColor *)textColor {
    self.backgroundColor = backgroud;
    _foregroundView.backgroundColor = foreground;
    _thumbImageView.backgroundColor = imageBackgroundColor;
    _thumbImageViewBgView.backgroundColor = imageBackgroundColor;
    [self.layer setBorderColor:border.CGColor];
    _label.textColor = textColor;
}

- (void)setThumbImage:(UIImage *)thumbImage {
    _thumbImage = thumbImage;
    _thumbImageView.image = thumbImage ;
//    [_thumbImageView sizeToFit];
    [self setSliderValue:0.0];
}

- (void)setThumbBeginImage:(UIImage *)beginImage finishImage:(UIImage *)finishImage {
    self.thumbImage = beginImage;
    self.finishImage = finishImage;
}

- (void)removeRoundCorners:(BOOL)corners border:(BOOL)border {
    if (corners) {
        self.layer.cornerRadius = 0.0;
        self.layer.masksToBounds = NO;
        _thumbImageView.layer.cornerRadius = 0.0;
        _thumbImageView.layer.masksToBounds = NO;
    }
    if (border) {
        [self.layer setBorderWidth:0.0];
    }
}

- (void)setThumbHidden:(BOOL)thumbHidden {
    _thumbHidden = thumbHidden;
    _touchView = thumbHidden ? self : _thumbImageViewBgView;
    _thumbImageView.hidden = thumbHidden;
    _thumbImageViewBgView.hidden = thumbHidden;
}


#pragma mark - Private Method

- (void)fillForeGroundViewWithPoint:(CGPoint)point {
    if (point.x < 0) return;
    CGFloat thunmbW = self.thumbImage ? self.thumbImage.size.width : kThumbW;
    CGPoint p = point;
    //修正
    p.x += thunmbW/2;
    if (p.x > kSliderW) {
        p.x = kSliderW;
    }
    if (p.x < 0) {
        p.x = 0;
    }
    if (self.finishImage) {
        _thumbImageView.image = point.x  < (kSliderW - thunmbW/2) ? self.thumbImage : self.finishImage;
    }
    self.value = p.x  / kSliderW;
    _foregroundView.frame = CGRectMake(0, 0, point.x, kSliderH);
    CGFloat startPointx = point.x - kTouchViewW;
    if (startPointx < 0) startPointx = 0;
    kJLLog(JLLOG_DEBUG, @"point.x : %f, _foregroundView.width : %f", point.x, _foregroundView.width);
    if (_foregroundView.frame.size.width <= 0) {
        _thumbImageViewBgView.frame = CGRectMake(0, 0, kTouchViewW, self.height);
    } else if (_foregroundView.frame.size.width >= kSliderW) {
        _thumbImageViewBgView.frame = CGRectMake(startPointx, kBorderWidth, kTouchViewW, self.height);
    } else {
        _thumbImageViewBgView.frame = CGRectMake(startPointx, kBorderWidth, kTouchViewW, self.height);
    }
    [self centerYWith:_thumbImageViewBgView with:self];
}

- (id)centerYWith:(UIView *)v1 with:(UIView *)v2
{
    CGPoint c = [v1.superview convertPoint:v2.center fromView:v2.superview];
    c.x = v1.center.x;
    v1.center = c;
    return v1;
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (_touchView == _thumbImageViewBgView) {
        return;
    }
    CGPoint point = [touch locationInView:self];
    [self fillForeGroundViewWithPoint:point];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.view != _touchView) {
        return;
    }
    CGPoint point = [touch locationInView:self];
    [self fillForeGroundViewWithPoint:point];
    if ([self.delegate respondsToSelector:@selector(sliderValueChanging:)] ) {
        [self.delegate sliderValueChanging:self];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.view != _touchView) {
        return;
    }
    CGPoint __block point = [touch locationInView:self];
    if ([self.delegate respondsToSelector:@selector(sliderEndValueChanged:)]) {
        [self.delegate sliderEndValueChanged:self];
    }
    typeof(self) weakSelf = self;
    if (_thumbBack) {
        [UIView animateWithDuration:0.5 animations:^{
            point.x = 0;
            [weakSelf fillForeGroundViewWithPoint:point];
        }];
    }
}

@end
