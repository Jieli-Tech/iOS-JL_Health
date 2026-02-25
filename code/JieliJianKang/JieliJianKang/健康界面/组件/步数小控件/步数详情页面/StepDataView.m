//
//  StepDataView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/24.
//

#import "StepDataView.h"
#import <TYCoreText/TYCoreText.h>
#import "JL_RunSDK.h"

@interface StepDataView(){
    TYAttributedLabel *leftLabel;
    TYAttributedLabel *rightLabel;
}
@end

@implementation StepDataView

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
        leftLabel = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(0, 16, self.frame.size.width/2, self.frame.size.height)];
        leftLabel.backgroundColor = [UIColor clearColor];

        [self addSubview:leftLabel];
        
        rightLabel = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 16, self.frame.size.width/2, self.frame.size.height)];
        rightLabel.backgroundColor = [UIColor clearColor];

        [self addSubview:rightLabel];
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 16.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

-(void)setTabLab:(NSString *)tabLab1 TabLab2:(NSString *)tabLab2 Value1:(NSString *)v1 Unit1:(NSString *)u1 Value2:(NSString *)v2 Unit2:(NSString *)u2{
    TYTextContainer *t0 = [self getContainer:v1 Unit:u1 tabLab:tabLab1];
    TYTextContainer *t1 = [self getContainer:v2 Unit:u2 tabLab:tabLab2];
    leftLabel.textContainer = t0;
    rightLabel.textContainer = t1;
}

-(TYTextContainer *)getContainer:(NSString *)v1 Unit:(NSString *)u1 tabLab:(NSString *)tabLab1{
    // 属性文本生成器
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    NSString *stepStr = [NSString stringWithFormat:@"%@%@\n%@",v1,u1,tabLab1];
    textContainer.text = stepStr;
    // 整体设置属性
    textContainer.linesSpacing = 2;
    textContainer.paragraphSpacing = 5;
    textContainer.textAlignment = kCTTextAlignmentCenter;
    // 文字样式
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [stepStr rangeOfString:v1];
    textStorage.font = [UIFont fontWithName:@"PingFangSC-Medium" size:26];
    textStorage.textColor = kDF_RGBA(36, 36, 36, 1);
    [textContainer addTextStorage:textStorage];
    
    // 文字样式
    TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
    textStorage2.range = [stepStr rangeOfString:u1];
    textStorage2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    textStorage2.textColor = kDF_RGBA(145, 145, 145, 1);
    [textContainer addTextStorage:textStorage2];
    
    // 文字样式
    TYTextStorage *textStorage3 = [[TYTextStorage alloc]init];
    textStorage3.range = [stepStr rangeOfString:tabLab1];
    textStorage3.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
    textStorage3.textColor = kDF_RGBA(145, 145, 145, 1);
    [textContainer addTextStorage:textStorage3];
    return textContainer;
}

@end
