//
//  HeartBitPartView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/16.
//

#import "HeartBitPartView.h"
#import <CoreDraw/CoreDraw.h>
#import <TYCoreText/TYCoreText.h>
#import "JL_RunSDK.h"


@interface HeartBitPartView()<JL_WatchProtocol,LanguagePtl>{
    UIImageView *heartImgv;
    UILabel *titleLab;
    UILabel *dayLab;
    TYAttributedLabel *bitLab;
    CGFloat max;
    CGFloat min;
    CGFloat allHeight;
    CGFloat allWidth;
    CGFloat ecBottom;
    
    NSMutableArray *allFillArray;
    NSMutableArray *pointsArray;
    NSMutableArray *tgArray;
}
@end

@implementation HeartBitPartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        allWidth = self.frame.size.width;
        allHeight = self.frame.size.height;
        allFillArray = [NSMutableArray new];
        pointsArray = [NSMutableArray new];
        tgArray = [NSMutableArray new];
        self.maxValue = 220;
        self.minValue = 50;
        [[LanguageCls share] add:self];
        ecBottom = 36;
        
        heartImgv = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12.0, 28, 28)];
        heartImgv.image = [UIImage imageNamed:@"health_icon_heart_nol"];
        [self addSubview:heartImgv];
        
        titleLab = [[UILabel alloc] initWithFrame:CGRectMake(44, 16, 120, 20)];
        titleLab.textColor = kDF_RGBA(36, 36, 36, 1);
        titleLab.text = kJL_TXT("心率");
        titleLab.font = [UIFont systemFontOfSize:14];
        [self addSubview:titleLab];
        
        dayLab = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-120-16, 16, 120, 20)];
        dayLab.textAlignment = NSTextAlignmentRight;
        dayLab.textColor = kDF_RGBA(175, 175, 175, 1);
        dayLab.font = [UIFont systemFontOfSize:12];
        dayLab.text = [NSString stringWithFormat:@"%@%@%@%@",@"-",kJL_TXT("月"),@"-",kJL_TXT("日")];
        [self addSubview:dayLab];
        
        bitLab = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(41, self.frame.size.height-16-33, 200, 35)];
        bitLab.backgroundColor = [UIColor clearColor];
        [self addSubview:bitLab];
        //[self setHeartBeat:46 forDay:[NSDate new]];
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchForJump)];
        [self addGestureRecognizer:ges];
    }
    return self;
}

-(void)touchForJump{
//    [self requireDataFromDevice];
    if ([_delegate respondsToSelector:@selector(jumpByObject:)]) {
        [_delegate jumpByObject:HeartBeat];
    }
}


-(void)requireDataFromDevice{
    JLWearable *w = [JLWearable sharedInstance];
    NSMutableArray *array = [NSMutableArray new];
    
    [array addObject:[JL_SDM_HeartRate requireRealTime:YES Resting:YES Max:YES]];
//    [array addObject:[JL_SDM_HeartRate requireDiagram]];
    [w w_addDelegate:self];

    [w w_requestSportData:array withEntity:kJL_BLE_EntityM];
}

-(void)setHeartBeat:(NSInteger )beat forDay:(NSDate *)date{
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    NSString *tmpStr = @"- -";
    if (beat!=0) {
        tmpStr = [NSString stringWithFormat:@"%d",(int)beat];
    }
    NSString *targetStr = [NSString stringWithFormat:@"%@%@",tmpStr,kJL_TXT("次/分钟")];
    textContainer.text = targetStr;
    TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
    textStorage2.range = [targetStr rangeOfString:tmpStr];
    textStorage2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:24];
    textStorage2.textColor = kDF_RGBA(36, 36, 36, 1);
    [textContainer addTextStorage:textStorage2];
    
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [targetStr rangeOfString:kJL_TXT("次/分钟")];
    textStorage.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    textStorage.textColor = kDF_RGBA(96, 96, 96, 1);
    [textContainer addTextStorage:textStorage];
    bitLab.textContainer = textContainer;
    
    NSDateFormatter *fm = [EcTools cachedFm];
    fm.dateFormat = [NSString stringWithFormat:@"MM%@dd%@",kJL_TXT("月"),kJL_TXT("日")];
    NSString *str = [fm stringFromDate:date];
    if (str) {
        dayLab.text = str;
    }else{
        dayLab.text = [NSString stringWithFormat:@"%@%@%@%@",@"-",kJL_TXT("月"),@"-",kJL_TXT("日")];
    }
    
}



-(void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    [self initDataArray];
    [self setNeedsDisplay];
}


-(void)jlWatchHeartRate:(JL_SDM_HeartRate *)heartRate{
   // NSLog(@"%lu",(unsigned long)heartRate.chartModel.dataArray.count);
}


-(void)initDataArray{
    CGFloat ecLeft = 16;
    
    CGFloat w = (allWidth-16*2)/self.dtNumber;
    CGFloat h = (allHeight-54-ecBottom)/(self.maxValue-self.minValue);
    
    [allFillArray removeAllObjects];
    [pointsArray removeAllObjects];
    [tgArray removeAllObjects];
    
    [pointsArray addObject:[NSMutableArray new]];
    
    for (int i = 0;i<self.dataArray.count;i++) {
        NSValue *value0 = self.dataArray[i];
        NSValue *value1;
        if (i+1<self.dataArray.count) {
            value1 = self.dataArray[i+1];
        }else{
            value1 = self.dataArray[i];
        }
        CGPoint pt = [value0 CGPointValue];
        CGPoint pt1 = [value1 CGPointValue];
        if (pt1.x-pt.x>1) {
        
            CGPoint pti = CGPointMake(pt.x*w+ecLeft, allHeight-h*(pt.y-self.minValue)-ecBottom);
            NSValue *vv = [NSValue valueWithCGPoint:pti];
            [allFillArray addObject:vv];
            NSMutableArray *tmpArray = [pointsArray lastObject];
            [tmpArray addObject:vv];
            
            [pointsArray addObject:[NSMutableArray new]];
            int k = pt1.x - pt.x;
            for (int j = 0; j<=k; j++) {
                CGPoint pti = CGPointMake((pt.x+j)*w+ecLeft, allHeight-ecBottom);
                NSValue *vv = [NSValue valueWithCGPoint:pti];
                [allFillArray addObject:vv];
            }
        }else if((pt1.x - pt.x) == 0){

            CGPoint pti0 = CGPointMake(pt.x*w+ecLeft, allHeight-h*(pt.y-self.minValue)-ecBottom);
            NSValue *vv0 = [NSValue valueWithCGPoint:pti0];
            [allFillArray addObject:vv0];
            
            CGPoint pti = CGPointMake(pt.x*w+ecLeft, allHeight-ecBottom);
            NSValue *vv = [NSValue valueWithCGPoint:pti];
            [allFillArray addObject:vv];
            
            NSMutableArray *tmpArray = [pointsArray lastObject];
            [tmpArray addObject:vv0];
            
        }else{
            if (allFillArray.count == 0) {
                CGPoint pti0 = CGPointMake(pt.x*w+ecLeft, allHeight-ecBottom);
                NSValue *vv0 = [NSValue valueWithCGPoint:pti0];
                [allFillArray addObject:vv0];
            }
            CGPoint pti = CGPointMake(pt.x*w+ecLeft, allHeight-(pt.y-self.minValue)-ecBottom);
            NSValue *vv = [NSValue valueWithCGPoint:pti];
            [allFillArray addObject:vv];

            
            NSMutableArray *tmpArray = [pointsArray lastObject];
            [tmpArray addObject:vv];
            
        }
    }

}

-(void)drawView{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    NSValue *v0 = allFillArray.firstObject;
    CGPoint p0 = [v0 CGPointValue];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, p0.x, p0.y);
    for (int i = 1; i<allFillArray.count; i++) {
        NSValue *value = allFillArray[i];
        CGPoint p = [value CGPointValue];
        CGPathAddLineToPoint(path, NULL, p.x, p.y);
    }
    CGPathCloseSubpath(path);
    CGContextAddPath(context, path);
    CGContextClip(context);
    NSArray *colors = @[(__bridge id)kDF_RGBA(255, 95, 95, 1).CGColor, (__bridge id)[UIColor colorWithRed:255 green:1 blue:1 alpha:0.01].CGColor];
    CGFloat k[] = {0.4,1.0};
    [ECDrawTools drawGradienLine:context colors:(CFArrayRef)colors locations:k rect:CGRectMake(0, 0,2, allHeight-ecBottom)];
    CGPathRelease(path);
    CGContextRestoreGState(context);
}
-(void)drawPointLine{
//    CGContextRef context = UIGraphicsGetCurrentContext();
    for (NSArray *arr in pointsArray) {
        [self drawBrokenLine:arr];
//        [ECDrawTools drawBrokenLine:arr lineWidth:1.5 pathColor:kDF_RGBA(255, 95, 95, 1) context:context];
    }
}
-(void)drawBrokenLine:(NSArray *)array{
    UIColor *lineColor = kDF_RGBA(255, 95, 95, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextSetLineWidth(context, 1.2);
    int k = 0;
    BOOL isHave = NO;
    while (k<array.count) {
        CGPoint p0 = [array[k] CGPointValue];
        if (p0.y < (allHeight - ecBottom)) {
            if (isHave == NO) {
                isHave = YES;
                CGContextSaveGState(context);
                CGContextMoveToPoint(context, p0.x, p0.y);
                k++;
                continue;
            }else{
                CGContextAddLineToPoint(context, p0.x, p0.y);
                k++;
            }
        }else{
            if (isHave == NO) {
                k++;
            }else{
                isHave = NO;
                CGContextStrokePath(context);
                CGContextRestoreGState(context);
                k++;
            }
        }
    }
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawView];
    [self drawPointLine];
}


- (void)languageChange{
    titleLab.text = kJL_TXT("心率");
    [self setNeedsDisplay];
}


@end
