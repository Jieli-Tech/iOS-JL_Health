//
//  OxygenDataView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/31.
//

#import "OxygenDataView.h"
#import "JL_RunSDK.h"

@interface OxygenDataView()
@end

@implementation OxygenDataView

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
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        _lastLabel = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(0, 10, width/2 , height-20)];
        _lastLabel.textAlignment = kCTTextAlignmentCenter;
        _lastLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_lastLabel];
        
        _rangeLabel = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(width/2, 10, width/2, height-20)];
        _rangeLabel.textAlignment = kCTTextAlignmentCenter;
        _rangeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_rangeLabel];
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 6;
        self.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,0);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 10;
        
    }
    return self;
}


-(void)oxyLastTime:(NSDate *)date Value:(int)value{
    NSDateFormatter *fm = [EcTools cachedFm];
    fm.dateFormat = @"HH:mm";
    NSString *s1 = [NSString stringWithFormat:@"%@%@",kJL_TXT("最新"),[fm stringFromDate:date]];
    NSString *s2 = [NSString stringWithFormat:@"%d%@",value,@"%"];
    if (value == 0){
        s2 = @"-";
    }
    [self setText:s1 And:s2 Lab:0];
}
-(void)oxyMaxValue:(int)max minValue:(int)min{
    NSString *s1 = [NSString stringWithFormat:@"%@-%@",kJL_TXT("最低值"),kJL_TXT("最高值")];
    NSString *s2 = [NSString stringWithFormat:@"%d%@-%d%@",min,@"%",max,@"%"];
    if (max == 0 && min == 0){
        s2 = @"- -";
    }
    [self setText:s1 And:s2 Lab:1];
}

-(void)oxyMyMinValue:(int)min{
    NSString *s1 = [NSString stringWithFormat:@"%@",kJL_TXT("最低值")];
    NSString *s2 = [NSString stringWithFormat:@"%d%@",min,@"%"];
    if (min == 0){
        s2 = @"-";
    }
    [self setText:s1 And:s2 Lab:0];
}

-(void)oxyMyMaxValue:(int)max{
    NSString *s1 = [NSString stringWithFormat:@"%@",kJL_TXT("最高值")];
    NSString *s2 = [NSString stringWithFormat:@"%d%@",max,@"%"];
    if (max == 0){
        s2 = @"-";
    }
    [self setText:s1 And:s2 Lab:1];
}

-(void)setText:(NSString *)lab0 And:(NSString *)lab1 Lab:(int)v{
    TYTextContainer *container = [[TYTextContainer alloc] init];
    container.paragraphSpacing = 10;
    NSString *text =  [NSString stringWithFormat:@"%@\n%@",lab0,lab1];
    container.text =  text;
    container.font = [UIFont systemFontOfSize:13];
    container.textColor = kDF_RGBA(145, 145, 145, 1);
    container.textAlignment = kCTTextAlignmentCenter;
    
    TYTextStorage *storage = [[TYTextStorage alloc] init];
    storage.font = [UIFont fontWithName:@"PingFangSC-Medium" size:20];
    storage.range = [text rangeOfString:lab1];
    storage.textColor = kDF_RGBA(36, 36, 36, 1);
    [container addTextStorage:storage];

    if (v==0) {
        _lastLabel.textContainer = container;
    }else{
        _rangeLabel.textContainer = container;
    }
}


@end
