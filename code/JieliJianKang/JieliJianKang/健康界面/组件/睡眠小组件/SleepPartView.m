//
//  SleepPartView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/17.
//

#import "SleepPartView.h"
#import <TYCoreText/TYCoreText.h>
#import "JL_RunSDK.h"

@interface SleepPartView()<LanguagePtl>{
    UIImageView *heartImgv;
    UILabel *titleLab;
    UILabel *dayLab;
    
    UILabel *noDataLab;
    TYAttributedLabel *timeLab;
    
    NSArray *percentArray;
    NSArray *colorsArray;
    
    int mDuration;
}
@end

@implementation SleepPartView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        heartImgv = [[UIImageView alloc] initWithFrame:CGRectMake(12, 14.0, 24, 24)];
        heartImgv.image = [UIImage imageNamed:@"health_icon_record_nol(4)"];
        [self addSubview:heartImgv];
        [[LanguageCls share] add:self];
        titleLab = [[UILabel alloc] initWithFrame:CGRectMake(44, 16, 65, 20)];
        titleLab.textColor = kDF_RGBA(36, 36, 36, 1);
        titleLab.text = kJL_TXT("睡眠");
        titleLab.font = [UIFont systemFontOfSize:14];
        [self addSubview:titleLab];
        
        dayLab = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-120-16, 16, 120, 20)];
        dayLab.textAlignment = NSTextAlignmentRight;
        dayLab.textColor = kDF_RGBA(175, 175, 175, 1);
        dayLab.font = [UIFont systemFontOfSize:12];
        dayLab.text = [NSString stringWithFormat:@"%@%@%@%@",@"-",kJL_TXT("月"),@"-",kJL_TXT("日")];
        [self addSubview:dayLab];
        
        timeLab = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(40, 44, 200, 35)];
        timeLab.backgroundColor = [UIColor clearColor];
        [self addSubview:timeLab];
        [self setSleepLab:[NSString stringWithFormat:@"-%@-%@",kJL_TXT("小时"),kJL_TXT("分钟")]];
        
        noDataLab = [[UILabel alloc] initWithFrame:CGRectMake(39, self.frame.size.height-37, 200, 21)];
        noDataLab.font = [UIFont systemFontOfSize:15];
        noDataLab.textColor = kDF_RGBA(36, 36, 36, 1);
        noDataLab.text = kJL_TXT("今日暂无数据");
        [self addSubview:noDataLab];
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchForJump)];
        [self addGestureRecognizer:ges];
    }
    return self;
}

-(void)touchForJump{
    if ([_delegate respondsToSelector:@selector(jumpByObject:)]) {
        [_delegate jumpByObject:SleepTime];
    }
}


-(void)initData{
    colorsArray = @[kDF_RGBA(242, 196, 90, 1),
                    kDF_RGBA(246, 188, 169, 1),
                    kDF_RGBA(243, 150, 150, 1),
                    kDF_RGBA(209, 157, 247, 1),
                    kDF_RGBA(136, 86, 248, 1)];
}

-(void)setDateLabel:(NSDate *)date{
    NSDateFormatter *fm = [EcTools cachedFm];
    fm.dateFormat = [NSString stringWithFormat:@"MM%@dd%@",kJL_TXT("月"),kJL_TXT("日")];
    NSString *str = [fm stringFromDate:date];
    if (str) {
        dayLab.text = str;
    }else{
        dayLab.text = [NSString stringWithFormat:@"%@%@%@%@",@"-",kJL_TXT("月"),@"-",kJL_TXT("日")];
    }
}

-(void)setDuration:(NSInteger)duration{
    mDuration = (int)duration;
}

-(void)setDataArray:(NSArray<ECDiagramPoint *> *)dataArray{
    _dataArray = dataArray;
    //NSTimeInterval t0 = [dataArray.lastObject.start timeIntervalSince1970] - [dataArray.firstObject.start timeIntervalSince1970];
    if (dataArray.count>0) {
        [self timeToString:mDuration];
    }else{
        [self setSleepLab:[NSString stringWithFormat:@"-%@-%@",kJL_TXT("小时"),kJL_TXT("分钟")]];
    }
    
    NSTimeInterval t1 = 0.0;
    NSTimeInterval t2 = 0.0;
    NSTimeInterval t3 = 0.0;
    NSTimeInterval t4 = 0.0;
    NSTimeInterval t5 = 0.0;
    for (ECDiagramPoint *point in dataArray) {
        switch (point.type) {
            case SleepType_Awake:{
                t1+=point.length;
            }break;
            case SleepType_Shallow:{
                t2+=point.length;
            }break;
            case SleepType_Deep:{
                t3+=point.length;
            }break;
            case SleepType_Rem:{
                t4+=point.length;
            }break;
            case SleepType_SporadicNap:{
                t5+=point.length;
            }break;
            default:
                break;
        }
    }
    float f1 = t1/mDuration;
    float f2 = t4/mDuration;
    float f3 = t5/mDuration;
    float f4 = t2/mDuration;
    float f5 = t3/mDuration;
    percentArray = @[@(f1),@(f2),@(f3),@(f4),@(f5)];
    [self setNeedsDisplay];
}




-(void)drawTheLine{
    CGFloat width = self.frame.size.width-32;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat ecLeft = 16;
    if (self.dataArray.count>0) {
        CGFloat addW = 16.0;
        for (int i = 0; i<percentArray.count; i++) {
            CGFloat w = width*[percentArray[i] floatValue];
            CGRect r = CGRectMake(addW, 87, w, 10);
            [ECDrawTools drawRectangle:context rect:r fillColor:colorsArray[i] lineWidth:1 StrokeColor:[UIColor whiteColor]];
            addW+=w;
        }
        CGFloat w0 = width/percentArray.count;
        UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
        NSDictionary *dict = @{NSFontAttributeName:font,NSForegroundColorAttributeName:kDF_RGBA(145, 145, 145, 1),NSBackgroundColorAttributeName:[UIColor clearColor]};
        NSArray *textArray = @[kJL_TXT("清醒"),kJL_TXT("快速眼动"),kJL_TXT("零星小睡"),kJL_TXT("浅睡"),kJL_TXT("深睡")];
        for (int i = 0; i<5; i++) {
            CGSize textSize = [textArray[i] sizeWithAttributes:@{NSFontAttributeName:font}];
            CGFloat w1 = w0*i+ecLeft+(w0-textSize.width)/2;
            if(i==2 || i==3){
                w1= w1+12;
            }
            CGRect r2 = CGRectMake(w1-13, 122, 10, 10);
            [ECDrawTools drawRectangle:context rect:r2 fillColor:colorsArray[i] lineWidth:0.5 StrokeColor:colorsArray[i]];
            [textArray[i] drawInRect:CGRectMake(w1, 118, w0, 17) withAttributes:dict];
        }
        noDataLab.hidden = YES;
    }else{
        CGRect r = CGRectMake(ecLeft, 87, width, 10);
        [ECDrawTools drawRectangle:context rect:r fillColor:kDF_RGBA(185, 164, 240, 1) lineWidth:1 StrokeColor:[UIColor whiteColor]];
        noDataLab.hidden = NO;
    }
    
}


-(void)drawRect:(CGRect)rect{
    [self drawTheLine];
}

-(void)timeToString:(int)t{
    int minutes = ((int)t / 60) % 60;
    int hours = (int)t / 3600;
    
    NSString *targetStr;
    if(hours<1){
        targetStr = [NSString stringWithFormat:@"%d%@",minutes,kJL_TXT("分钟")];
    }else{
        targetStr = [NSString stringWithFormat:@"%d%@%d%@",hours,kJL_TXT("小时"),minutes,kJL_TXT("分钟")];
    }
    [self setSleepLab:targetStr];
}

-(void)setSleepLab:(NSString *)targetStr{
    
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    textContainer.linesSpacing = 3;
    textContainer.text = targetStr;
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [targetStr rangeOfString:targetStr];
    textStorage.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24];;
    textStorage.textColor = kDF_RGBA(36, 36, 36, 1);
    [textContainer addTextStorage:textStorage];
    
    
    TYTextStorage *textStorage1 = [[TYTextStorage alloc]init];
    textStorage1.range = [targetStr rangeOfString:kJL_TXT("小时")];
    textStorage1.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    textStorage1.textColor = kDF_RGBA(96, 96, 96, 1);
    [textContainer addTextStorage:textStorage1];
    
    TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
    textStorage2.range = [targetStr rangeOfString:kJL_TXT("分钟")];
    textStorage2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    textStorage2.textColor = kDF_RGBA(96, 96, 96, 1);
    [textContainer addTextStorage:textStorage2];
    
    timeLab.textContainer = textContainer;
}

- (void)languageChange {
    titleLab.text = kJL_TXT("睡眠");
    noDataLab.text = kJL_TXT("今日暂无数据");
    [self setNeedsDisplay];
}


@end
