//
//  SleepDataView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/29.
//

#import "SleepDataView.h"
#import <TYCoreText/TYCoreText.h>
#import "JL_RunSDK.h"

@interface SleepDataView (){
    TYAttributedLabel *deepLab;
    TYAttributedLabel *shallowLab;
    TYAttributedLabel *remLab;
    TYAttributedLabel *scoreLab;
    NSString *deepUnits;
    NSString *shallowUnits;
    NSString *remUnits;
    NSString *scoreUnits;
    NSString *proportionUnits;
    NSString *goalUnits;
}
@end

@implementation SleepDataView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = SleepDataType_Day;
        
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        deepLab = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(0, 10,width/2, height/2)];
        deepLab.textAlignment = kCTTextAlignmentCenter;
        deepLab.backgroundColor = [UIColor clearColor];
        [self addSubview:deepLab];
        
        shallowLab = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(width/2, 10,width/2, height/2)];
        shallowLab.textAlignment = kCTTextAlignmentCenter;
        shallowLab.backgroundColor = [UIColor clearColor];
        [self addSubview:shallowLab];
        
        remLab = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(0, height/2+10,width/2, height/2)];
        remLab.textAlignment = kCTTextAlignmentCenter;
        remLab.backgroundColor = [UIColor clearColor];
        [self addSubview:remLab];
        
        scoreLab = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(width/2, height/2+10,width/2, height/2)];
        scoreLab.textAlignment = kCTTextAlignmentCenter;
        scoreLab.backgroundColor = [UIColor clearColor];
        [self addSubview:scoreLab];
        
        self.layer.cornerRadius = 16;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

-(void)setType:(SleepDataType)type{
    _type = type;
    [self initData];
}

-(void)initData{
    if (self.type == SleepDataType_Day) {
        deepUnits = kJL_TXT("深度睡眠");
        shallowUnits = kJL_TXT("浅度睡眠");
        remUnits = kJL_TXT("快速眼动");
        scoreUnits = kJL_TXT("睡眠得分");
        proportionUnits = kJL_TXT("占");
    }else{
        deepUnits = kJL_TXT("平均深睡");
        shallowUnits = kJL_TXT("平均浅睡");
        remUnits = kJL_TXT("平均快速眼动");
        scoreUnits = kJL_TXT("平均睡眠得分");
        proportionUnits = kJL_TXT("占");
    }
    goalUnits = kJL_TXT("分数");
}

-(NSString *)beString:(NSInteger)length{
    int h = (int)length/3600;
    int m = ((int)length%3600)/60;
    return [NSString stringWithFormat:@"%d%@%d%@",h,kJL_TXT("小时"),m,kJL_TXT("分钟")];
}


-(void)deepSleep:(NSString *)percent length:(NSInteger)length{
    deepLab.textContainer =  [self setAllText:percent length:length Units:deepUnits];
}
-(void)shallowSleep:(NSString *)percent length:(NSInteger)length{
    shallowLab.textContainer = [self setAllText:percent length:length Units:shallowUnits];
}
-(void)remSleep:(NSString *)percent length:(NSInteger)length{
    remLab.textContainer = [self setAllText:percent length:length Units:remUnits];
}

-(void)setTitleHidden:(BOOL)hiden{
    deepLab.hidden = hiden;
    shallowLab.hidden = hiden;
    remLab.hidden = hiden;
    scoreLab.hidden = hiden;
}



-(void)setGoal:(int)score{
    SleepData_Interval interval = SleepData_Normal;
    if (score>80) {
        interval = SleepData_Normal;
    }else{
        interval = SleepData_Low;
    }
    NSString *typeStr = kJL_TXT("正常");
    UIColor *color = kDF_RGBA(119, 206, 64, 1);
    switch (interval) {
        case SleepData_Normal:{
            typeStr = kJL_TXT("正常");
            color = kDF_RGBA(119, 206, 64, 1);
        }break;
        case SleepData_Low:{
            typeStr = kJL_TXT("偏低");
            color = kDF_RGBA(253, 184, 90, 1);
        }break;
        case SleepData_Hight:{
            typeStr = kJL_TXT("睡眠偏高");
            color = kDF_RGBA(224, 109,99, 1);
        }break;
            
        default:
            break;
    }
    NSString *allText = [NSString stringWithFormat:@"%d%@\n%@\n%@",score,goalUnits,scoreUnits,typeStr];
    TYTextContainer *container = [[TYTextContainer alloc] init];
    container.text = allText;
    container.textAlignment = 2;
    container.font = [UIFont systemFontOfSize:12];
    container.textColor = kDF_RGBA(145, 145, 145, 1);
    
    TYTextStorage *st0 = [[TYTextStorage alloc] init];
    st0.font = [UIFont systemFontOfSize:26];
    st0.textColor = kDF_RGBA(72, 82, 203, 1);
    st0.range = [allText rangeOfString:[NSString stringWithFormat:@"%d",score]];
    [container addTextStorage:st0];
    
    TYTextStorage *st1 = [[TYTextStorage alloc] init];
    st1.font = [UIFont systemFontOfSize:12];
    st1.textColor = color;
    st1.range = [allText rangeOfString:typeStr];
    [container addTextStorage:st1];
    
    TYTextStorage *st2 = [[TYTextStorage alloc] init];
    st2.font = [UIFont systemFontOfSize:15];
    st2.textColor = kDF_RGBA(88, 88, 88, 1);
    st2.range = [allText rangeOfString:scoreUnits];
    [container addTextStorage:st2];
    scoreLab.textContainer = container;
}


-(TYTextContainer *)setAllText:(NSString *)present length:(NSInteger)length Units:(NSString *)units{
    NSString *hour = [NSString stringWithFormat:@"%d",(int)length/3600];
    NSString *minute = [NSString stringWithFormat:@"%d",((int)length%3600)/60];
    NSString *allText = [NSString stringWithFormat:@"%@\n%@\n%@%@",[self beString:length],units,proportionUnits,present];
    TYTextContainer *container = [[TYTextContainer alloc] init];
    container.text = allText;
    container.textAlignment = 2;
    container.font = [UIFont systemFontOfSize:15];
    container.textColor = kDF_RGBA(145, 145, 145, 1);
    
    TYTextStorage *st0 = [[TYTextStorage alloc] init];
    st0.font = [UIFont systemFontOfSize:26];
    st0.textColor = kDF_RGBA(72, 82, 203, 1);
    st0.range = [allText rangeOfString:hour];
    [container addTextStorage:st0];
    
    TYTextStorage *st1 = [[TYTextStorage alloc] init];
    st1.font = [UIFont systemFontOfSize:26];
    st1.textColor = kDF_RGBA(72, 82, 203, 1);
    st1.range = [allText rangeOfString:[NSString stringWithFormat:@"%@%@",minute,kJL_TXT("分钟")]];
    [container addTextStorage:st1];
    
    TYTextStorage *st2 = [[TYTextStorage alloc] init];
    st2.font = [UIFont systemFontOfSize:15];
    st2.textColor = kDF_RGBA(88, 88, 88, 1);
    st2.range = [allText rangeOfString:units];
    [container addTextStorage:st2];
    
    TYTextStorage *st3 = [[TYTextStorage alloc] init];
    st3.font = [UIFont systemFontOfSize:15];
    st3.textColor = kDF_RGBA(88, 88, 88, 1);
    st3.range = [allText rangeOfString:kJL_TXT("分钟")];
    [container addTextStorage:st3];
    return container;
}



@end
