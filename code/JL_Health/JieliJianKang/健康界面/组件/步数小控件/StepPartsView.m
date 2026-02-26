//
//  StepPartsView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/12.
//

#import "StepPartsView.h"
#import "IACircularSlider.h"
#import "JL_RunSDK.h"
#import <TYCoreText/TYCoreText.h>
#import <CoreDraw/CoreDraw.h>

#define RGB(r,g,b,a)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface StepPartsView()<LanguagePtl>{
    UILabel *stepLab;
    TYAttributedLabel *targetStepLab;
    TYAttributedLabel *todayStepLab;
    UIImageView *stepImgv;
    TYAttributedLabel *kmLab;
    TYAttributedLabel *kaLab;
    TYAttributedLabel *mLab;
    IACircularSlider *slider;
    float kmSelf;
    float kclSelf;
    float mSelf;
}
@end



@implementation StepPartsView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.backgroundColor = [UIColor purpleColor];
        
        stepLab = [[UILabel alloc] init];
        stepLab.text = kJL_TXT("今日步数");
        [stepLab sizeToFit];
        stepLab.textColor = [UIColor whiteColor];
        stepLab.font = [UIFont systemFontOfSize:15];
        stepLab.adjustsFontSizeToFitWidth = true;
        stepLab.alpha = 0.7;
        [self addSubview:stepLab];
        
        [stepLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(28);
            make.top.equalTo(self).offset(20);
            make.height.equalTo(@(20));
        }];
        
        stepImgv = [UIImageView new];
        stepImgv.image = [UIImage imageNamed:@"health_icon_step_nol"];
        [self addSubview:stepImgv];
        [stepImgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(stepLab.mas_right).offset(6);
            make.width.height.equalTo(@(20));
            make.centerY.equalTo(stepLab.mas_centerY);
        }];
        
        
        todayStepLab = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(28, 61, 180, 56)];
        todayStepLab.backgroundColor = [UIColor clearColor];
        [self addSubview:todayStepLab];
        

        targetStepLab = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(self.frame.size.width-122, (self.frame.size.height-86)/2, 100, 86)];
        targetStepLab.backgroundColor = [UIColor clearColor];
        [self addSubview:targetStepLab];
        
        
        slider = [[IACircularSlider alloc] initWithFrame:CGRectMake(self.frame.size.width-130, 20, 110, 110)];
        slider.trackHighlightedTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        slider.thumbTintColor = [UIColor whiteColor];
        slider.trackTintColor = [JLColor colorWithString:@"#FFFFFF" alpha:0.3];//kDF_RGBA(163, 121, 251, 1.0);
        slider.thumbHighlightedTintColor = [UIColor whiteColor];
        slider.trackWidth = 8;
        slider.thumbWidth = 0;
        slider.userInteractionEnabled = false;
        
        slider.maximumValue = 100;
        slider.minimumValue = 0;
        slider.startAngle = 3*M_PI/4;
        slider.endAngle = M_PI/4;
        slider.clockwise = YES;
        CGPoint start = CGPointMake(200, 100);
        CGPoint end = CGPointMake(0, 100);
        [slider setGradientColorForHighlightedTrackWithFirstColor:[UIColor whiteColor] secondColor:[UIColor whiteColor] colorsLocations:CGPointMake(0.5, 0.5) startPoint:start andEndPoint:end];
        [self addSubview:slider];
        slider.value = 0;
        
        
        CGFloat w = frame.size.width/3;
        UIView *lineView0 = [[UIView alloc] initWithFrame:CGRectMake(w-1, frame.size.height-50, 2, 24)];
        lineView0.layer.cornerRadius = 0.5;
        lineView0.alpha = 0.6;
        lineView0.backgroundColor = [UIColor whiteColor];
        [self addSubview:lineView0];
        
        UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(w*2-1, frame.size.height-50, 2, 24)];
        lineView1.layer.cornerRadius = 0.5;
        lineView1.alpha = 0.6;
        lineView1.backgroundColor = [UIColor whiteColor];
        [self addSubview:lineView1];
        
        kmLab = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-57, w, 40)];
        kmLab.backgroundColor = [UIColor clearColor];
        [self addSubview:kmLab];
        
        kaLab = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(w, self.frame.size.height-57, w, 40)];
        kaLab.backgroundColor = [UIColor clearColor];
        [self addSubview:kaLab];
        
        mLab = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(w*2, self.frame.size.height-57, w, 40)];
        mLab.backgroundColor = [UIColor clearColor];
        [self addSubview:mLab];
        
        [self setK:0 Kcl:0 m:0];
        [self setTargetStepAction:0];
        [self setWalkStep:0];
        
        
        self.layer.cornerRadius = 12.0;
        self.layer.masksToBounds = YES;
        self.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:7/255.0 blue:23/255.0 alpha:0.28].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,4);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 8;
        
        [self setNeedsDisplay];
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchForJump)];
        [self addGestureRecognizer:ges];
        [[LanguageCls share] add:self];
    }
    return self;
}

-(void)touchForJump{
    if ([_delegate respondsToSelector:@selector(jumpByObject:)]) {
        [_delegate jumpByObject:StepCount];
    }
}

- (void)setWalkStep:(float)todayStep{
    _todayStep = todayStep;
    // 属性文本生成器
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    NSString *step = [NSString stringWithFormat:@"%d",(int)self.todayStep];
    NSString *stepStr = [NSString stringWithFormat:@"%@%@",step,kJL_TXT("步")];
    textContainer.text = stepStr;
    // 整体设置属性
    textContainer.linesSpacing = 2;
    textContainer.paragraphSpacing = 5;
    
    // 文字样式
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [stepStr rangeOfString:step];
    textStorage.font = [UIFont systemFontOfSize:40];
    textStorage.textColor = [UIColor whiteColor];
    [textContainer addTextStorage:textStorage];
    
    TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
    textStorage2.range = [stepStr rangeOfString:kJL_TXT("步")];
    textStorage2.font = [UIFont systemFontOfSize:10];
    textStorage2.textColor = RGB(255, 255, 255, 0.7);
    [textContainer addTextStorage:textStorage2];
    
    todayStepLab.textContainer = textContainer;
    
    if(_targetStep>0){
        float f = _todayStep/_targetStep;
        slider.value =f*100.0f;
        if(f>1.0){
            slider.value = 100.0;
        }
    }
}

-(void)setTargetStepAction:(float)target{
    _targetStep = target;
    TYTextContainer *ttContainer = [[TYTextContainer alloc] init];
    NSString *step = [NSString stringWithFormat:@"%d",(int)_targetStep];
    if (_targetStep == 0) {
        step = @"- -";
    }
    NSString *stepStr = [NSString stringWithFormat:@"%@:\n%@%@",kJL_TXT("目标"),step,kJL_TXT("步")];
    ttContainer.text = stepStr;
    // 整体设置属性
    ttContainer.linesSpacing = 2;
    ttContainer.paragraphSpacing = 0;
    ttContainer.textAlignment = kCTTextAlignmentCenter;
    // 文字样式
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [stepStr rangeOfString:[NSString stringWithFormat:@"%@:",kJL_TXT("目标")]];
    textStorage.font = [UIFont systemFontOfSize:14];
    textStorage.textColor = RGB(255, 255, 255, 0.7);
    [ttContainer addTextStorage:textStorage];
    
    TYTextStorage *textStorage0 = [[TYTextStorage alloc]init];
    textStorage0.range = [stepStr rangeOfString:step];
    textStorage0.font = [UIFont systemFontOfSize:14];
    textStorage0.textColor = [UIColor whiteColor];
    [ttContainer addTextStorage:textStorage0];
    
    TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
    textStorage2.range = [stepStr rangeOfString:kJL_TXT("步")];
    textStorage2.font = [UIFont systemFontOfSize:14];
    textStorage2.textColor = RGB(255, 255, 255, 0.7);
    [ttContainer addTextStorage:textStorage2];
    
    targetStepLab.textContainer = ttContainer;
    
}

-(void)setK:(float)km Kcl:(float)kcl m:(float)m{
    NSString *myUnits;
    kmSelf = km;
    kclSelf = kcl;
    mSelf = m;
    
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    if([unitStr isEqualToString:@("英制")]){
        myUnits = kJL_TXT("英里");
    }else{
        myUnits = kJL_TXT("公里");
    }
    
    NSString *unitsStr = [NSString stringWithFormat:@"%@%@%@",kJL_TXT("距离"),@"/",myUnits];
    [self labText:km secondText:unitsStr withLab:kmLab type:0];
    [self labText:kcl secondText:kJL_TXT("热量/千卡") withLab:kaLab type:1];
}

-(void)labText:(float)first secondText:(NSString *)second withLab:(TYAttributedLabel*)lab type:(int)type{
    TYTextContainer *ttContainer = [[TYTextContainer alloc] init];
    
    NSString *step = [NSString stringWithFormat:@"%.2f",first];
    switch (type) {
        case 0:{
            step = [NSString stringWithFormat:@"%.2f",first];
        }break;
        case 1:{
            step = [NSString stringWithFormat:@"%.0f",first];
        }break;
        case 2:{
            step = [NSString stringWithFormat:@"%.1f",first];
        }break;
            
        default:
            break;
    }
    NSString *stepStr = [NSString stringWithFormat:@"%@\n%@",step,second];
    ttContainer.text = stepStr;
    // 整体设置属性
    ttContainer.linesSpacing = 2;
    ttContainer.paragraphSpacing = 0;
    ttContainer.textAlignment = kCTTextAlignmentCenter;
    // 文字样式
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [stepStr rangeOfString:step];
    textStorage.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    textStorage.textColor = RGB(255, 255, 255, 1);
    [ttContainer addTextStorage:textStorage];
    
    TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
    textStorage2.range = [stepStr rangeOfString:second];
    textStorage2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    textStorage2.textColor = RGB(255, 255, 255, 0.7);
    [ttContainer addTextStorage:textStorage2];
    lab.textContainer = ttContainer;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawBgc];
}

-(void)drawBgc{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [ECDrawTools drawBackgroundColor2:RGB(154, 100, 255, 1) endColor:RGB(108, 63, 236, 1) Rect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ctx:context];
}

- (void)languageChange {
    stepLab.text = kJL_TXT("今日步数");
    [self setWalkStep:_todayStep];
    [self setTargetStepAction:_targetStep];
    [self setK:kmSelf Kcl:kclSelf m:mSelf];
}

@end
